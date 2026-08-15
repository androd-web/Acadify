import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ignore_for_file: deprecated_member_use

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

  // Variables pour ciblage flexible (peuvent être combinées)
  bool _targetAll = true;
  String? _selectedFiliere;
  String? _selectedNiveau;

  // Fichier PDF sélectionné
  PlatformFile? _selectedFile;
  bool _isPublishing = false;

  // Récupération des filières exactes depuis l'inscription
  final List<String> _filieres = ['Tous', 'ISN', 'CDN', 'INS'];

  // Récupération des niveaux exacts depuis l'inscription
  final List<String> _niveaux = ['Tous', 'L1', 'L2', 'L3', 'M1', 'M2'];

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

  // Fonction pour afficher un SnackBar personnalisé et super stylé
  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[900] : colorScheme.surface,
        duration: const Duration(seconds: 2),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? Colors.redAccent : AppColors.primaryAccent.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : AppColors.primaryAccent,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isError ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close, 
                color: isError ? Colors.white70 : colorScheme.onSurfaceVariant, 
                size: 18,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
      ),
    );
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
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isNotEmpty) {
        setState(() {
          _selectedFile = result.first;
        });
        _showCustomSnackBar('Fichier sélectionné : ${_selectedFile!.name}');
      }
    } catch (e) {
      _showCustomSnackBar('Erreur lors de la sélection du fichier : $e', isError: true);
    }
  }

  // Obtenir les critères de ciblage pour affichage
  Map<String, dynamic> _getTargetingCriteria() {
    if (_targetAll) {
      return {'displayText': 'Tous les utilisateurs', 'filters': {}};
    }

    Map<String, dynamic> filters = {};
    List<String> criteria = [];

    if (_selectedFiliere != null && _selectedFiliere != 'Tous') {
      filters['filiere'] = _selectedFiliere;
      criteria.add('Filière: $_selectedFiliere');
    }

    if (_selectedNiveau != null && _selectedNiveau != 'Tous') {
      filters['niveau'] = _selectedNiveau;
      criteria.add('Niveau: $_selectedNiveau');
    }

    if (criteria.isEmpty) {
      return {'displayText': 'Tous les utilisateurs', 'filters': {}};
    }

    return {'displayText': criteria.join(' + '), 'filters': filters};
  }

  Future<void> _publishAnnouncement() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      _showCustomSnackBar('Le titre et le contenu sont requis !', isError: true);
      return;
    }

    // Afficher un dialogue de confirmation avec les critères
    final targeting = _getTargetingCriteria();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la publication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Titre:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_titleController.text.trim()),
            const SizedBox(height: 16),
            const Text(
              'Catégorie:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_selectedCategory),
            const SizedBox(height: 16),
            const Text(
              'Destinataires:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Text(
                targeting['displayText'],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous êtes sur le point de publier ce communiqué. Continuez?',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      String categoryKey = 'info';
      if (_selectedCategory == 'Urgent') categoryKey = 'urgent';
      if (_selectedCategory == 'Général') categoryKey = 'general';

      final targeting = _getTargetingCriteria();

      final announcementData = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category': categoryKey,
        'targetFilters': targeting['filters'],
        'targetDescription': targeting['displayText'],
        'targetAll': _targetAll,
        'createdAt': FieldValue.serverTimestamp(),
        'authorUid': 'admin_uid',
        'authorName': 'Administrateur',
        'attachmentUrl': _selectedFile?.name, // Simulation d'upload
        'status': 'published',
      };

      await _firestore.collection('announcements').add(announcementData);

      _showCustomSnackBar('Communiqué publié avec succès !');

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showCustomSnackBar('Erreur lors de la publication: $e', isError: true);
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
                        _showCustomSnackBar('Contenu copié dans le presse-papiers !');
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

        // Option 1: Toute l'université
        InkWell(
          onTap: () {
            setState(() {
              _targetAll = true;
              _selectedFiliere = null;
              _selectedNiveau = null;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _targetAll
                    ? AppColors.amber
                    : colorScheme.onSurface.withValues(alpha: 0.08),
                width: _targetAll ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _targetAll,
                  activeColor: AppColors.amber,
                  onChanged: (value) {
                    if (value == true) {
                      setState(() {
                        _targetAll = true;
                        _selectedFiliere = null;
                        _selectedNiveau = null;
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
                        'Toute l\'université',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tous les étudiants et enseignants',
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
        ),
        const SizedBox(height: 24),

        // Option 2: Ciblage personnalisé
        InkWell(
          onTap: () {
            setState(() {
              _targetAll = false;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_targetAll
                    ? AppColors.amber
                    : colorScheme.onSurface.withValues(alpha: 0.08),
                width: !_targetAll ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _targetAll,
                  activeColor: AppColors.amber, 
                  onChanged: (value) {
                    if (value == false) {
                      setState(() {
                        _targetAll = false;
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
                        'Ciblage personnalisé',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sélectionnez filière et/ou niveau',
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
        ),

        if (!_targetAll) ...[
          const SizedBox(height: 24),
          Text(
            'Par filière',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez une filière (optionnel)',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _selectedFiliere,
            dropdownColor: colorScheme.surface,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Aucune filière sélectionnée',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Aucune filière'),
              ),
              ..._filieres.where((f) => f != 'Tous').map((filiere) {
                return DropdownMenuItem<String?>(
                  value: filiere,
                  child: Text(filiere),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFiliere = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Par niveau',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un niveau (optionnel)',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _selectedNiveau,
            dropdownColor: colorScheme.surface,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Aucun niveau sélectionné',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Aucun niveau'),
              ),
              ..._niveaux.where((n) => n != 'Tous').map((niveau) {
                return DropdownMenuItem<String?>(
                  value: niveau,
                  child: Text(niveau),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedNiveau = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Destinataires: ${_getTargetingCriteria()['displayText']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
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
