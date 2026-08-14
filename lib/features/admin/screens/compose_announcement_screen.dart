import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminComposeAnnouncement extends StatefulWidget {
  const AdminComposeAnnouncement({super.key});

  @override
  State<AdminComposeAnnouncement> createState() =>
      _AdminComposeAnnouncementState();
}

class _AdminComposeAnnouncementState extends State<AdminComposeAnnouncement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _selectedCategory = 'Urgent';
  String _selectedTarget = 'all'; // 'all', 'filiere', 'niveau'

  // Variables pour les sélections dynamiques
  String _selectedFiliere = 'Tous';
  String _selectedNiveau = 'Tous';

  // Fichier PDF sélectionné
  PlatformFile? _selectedFile;
  bool _isPublishing = false;

  // Récupération des filières exactes depuis l'inscription
  final List<String> _filieres = [
    'Tous',
    'ISN',
    'CDN',
    'INS',
  ];

  // Récupération des niveaux exacts depuis l'inscription
  final List<String> _niveaux = [
    'Tous',
    'L1',
    'L2',
    'L3',
    'M1',
    'M2',
  ];

  List<Map<String, dynamic>> _getCategories(ColorScheme colorScheme) => [
    {'label': 'Urgent', 'icon': Icons.campaign, 'color': colorScheme.error},
    {
      'label': 'Information',
      'icon': Icons.info,
      'color': colorScheme.secondary,
    },
    {'label': 'Général', 'icon': Icons.public, 'color': colorScheme.primary},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // Fonction pour appliquer le formatage de texte
  void _applyFormat(String prefix, String suffix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;

    if (selection.start == -1 || selection.end == -1) {
      // Pas de sélection, on ajoute juste à la fin
      _bodyController.text = text + prefix + suffix;
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.start +
            prefix.length +
            selectedText.length +
            suffix.length,
      ),
    );
  }

  // Sélectionner un fichier PDF
  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fichier sélectionné : ${_selectedFile!.name}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du fichier : $e'),
          ),
        );
      }
    }
  }

  Future<void> _publishAnnouncement() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre et le contenu sont requis, mola !'),
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      String categoryKey = 'info';
      if (_selectedCategory == 'Urgent') categoryKey = 'urgent';
      if (_selectedCategory == 'Général') categoryKey = 'general';

      // Détermination de la cible exacte
      String finalTarget = 'all';
      if (_selectedTarget == 'filiere') {
        finalTarget = _selectedFiliere == 'Tous'
            ? 'all'
            : 'filiere_${_selectedFiliere.toLowerCase()}';
      } else if (_selectedTarget == 'niveau') {
        finalTarget = _selectedNiveau == 'Tous'
            ? 'all'
            : 'niveau_${_selectedNiveau.toLowerCase()}';
      }

      final announcementData = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category': categoryKey,
        'targetGroup': finalTarget,
        'createdAt': FieldValue.serverTimestamp(),
        'authorUid': 'admin_uid',
        'authorName': 'Administrateur',
        'attachmentUrl': _selectedFile?.name, // Simulation d'upload
        'status': 'published',
      };

      await _firestore.collection('announcements').add(announcementData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Communiqué publié avec succès !')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: _isPublishing
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildTitleSection(context),
                        const SizedBox(height: 32),
                        _buildCategorySection(context),
                        const SizedBox(height: 32),
                        _buildContentSection(context),
                        const SizedBox(height: 32),
                        _buildTargetSection(context),
                        const SizedBox(height: 32),
                        _buildAttachmentSection(context),
                        const SizedBox(height: 32),
                        _buildNotificationNotice(context),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
          ),
          if (!_isPublishing) _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nouveau communiqué',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Brouillon',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EN-TÊTE',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            Text(
              '${_titleController.text.length}/100',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (v) => setState(() {}),
          style: AppTextStyles.headlineLarge.copyWith(
            color: colorScheme.onSurface,
            fontSize: 22,
          ),
          decoration: InputDecoration(
            hintText: 'Titre de l\'annonce...',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.amber),
            ),
          ),
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = _getCategories(colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATÉGORIE *',
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isActive = _selectedCategory == cat['label'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategory = cat['label']),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cat['color'].withValues(alpha: 0.1)
                          : colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? cat['color'].withValues(alpha: 0.3)
                            : colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'],
                          color: isActive
                              ? cat['color']
                              : colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['label'],
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isActive
                                ? cat['color']
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONTENU DU COMMUNIQUÉ *',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            Text(
              '${_bodyController.text.length}/2000',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.02),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildToolButton(context, Icons.format_bold, () {
                      _applyFormat('**', '**');
                    }),
                    _buildToolButton(context, Icons.format_italic, () {
                      _applyFormat('*', '*');
                    }),
                    _buildToolButton(context, Icons.copy, () {
                      if (_bodyController.text.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: _bodyController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Contenu copié dans le presse-papiers !',
                            ),
                          ),
                        );
                      }
                    }),
                    SizedBox(
                      width: 8,
                      child: VerticalDivider(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    _buildToolButton(context, Icons.link, () {
                      _applyFormat('[', '](url)');
                    }),
                  ],
                ),
              ),
              TextField(
                controller: _bodyController,
                onChanged: (v) => setState(() {}),
                maxLines: 6,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Rédigez votre message ici...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTargetSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESTINATAIRES *',
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        
        // Option 1: Toute l'université (Radio)
        _buildTargetRadioCard(
          context,
          'Toute l\'université',
          'Tous les étudiants et enseignants',
          'all',
        ),
        const SizedBox(height: 12),
        
        // Option 2: Par filière (Radio + Dropdown stable)
        _buildTargetRadioCard(
          context,
          'Par filière',
          'Sélectionnez une filière spécifique',
          'filiere',
        ),
        if (_selectedTarget == 'filiere') ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFiliere,
                  dropdownColor: colorScheme.surface,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Filière cible',
                  ),
                  items: _filieres.map((filiere) {
                    return DropdownMenuItem(value: filiere, child: Text(filiere));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFiliere = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        
        // Option 3: Par niveau (Radio + Dropdown stable)
        _buildTargetRadioCard(
          context,
          'Par niveau',
          'Sélectionnez un niveau spécifique',
          'niveau',
        ),
        if (_selectedTarget == 'niveau') ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedNiveau,
                  dropdownColor: colorScheme.surface,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Niveau cible',
                  ),
                  items: _niveaux.map((niveau) {
                    return DropdownMenuItem(value: niveau, child: Text(niveau));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedNiveau = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTargetRadioCard(
    BuildContext context,
    String title,
    String subtitle,
    String targetValue,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedTarget == targetValue;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTarget = targetValue;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.amber
                : colorScheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: targetValue,
              // ignore: deprecated_member_use
              groupValue: _selectedTarget,
              activeColor: AppColors.amber,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTarget = value;
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _pickPDF,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile != null ? Icons.check_circle : Icons.picture_as_pdf,
              size: 32,
              color: _selectedFile != null
                  ? AppColors.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile != null
                  ? 'PDF sélectionné : ${_selectedFile!.name}'
                  : '+ Ajouter un PDF',
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationNotice(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active,
            color: AppColors.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Une notification push sera envoyée immédiatement aux destinataires lors de la publication.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: _publishAnnouncement,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: AppColors.amber.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Publier le communiqué',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.send),
            ],
          ),
        ),
      ),
    );
  }
}
