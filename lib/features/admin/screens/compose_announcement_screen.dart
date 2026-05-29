import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminComposeAnnouncement extends StatefulWidget {
  const AdminComposeAnnouncement({super.key});

  @override
  State<AdminComposeAnnouncement> createState() => _AdminComposeAnnouncementState();
}

class _AdminComposeAnnouncementState extends State<AdminComposeAnnouncement> {
  String _selectedCategory = 'Urgent';

  List<Map<String, dynamic>> _getCategories(ColorScheme colorScheme) => [
    {'label': 'Urgent', 'icon': Icons.campaign, 'color': colorScheme.error},
    {'label': 'Information', 'icon': Icons.info, 'color': colorScheme.secondary},
    {'label': 'Général', 'icon': Icons.public, 'color': colorScheme.primary},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: SingleChildScrollView(
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
          _buildBottomAction(context),
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
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Nouveau communiqué',
                style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.outline, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Brouillon', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
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
            Text('EN-TÊTE', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 2)),
            Text('0/100', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          style: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Titre de l\'annonce...',
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
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
        Text('CATÉGORIE *', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 2)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: categories.map((cat) {
            final isActive = _selectedCategory == cat['label'];
            return InkWell(
              onTap: () => setState(() => _selectedCategory = cat['label']),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? cat['color'].withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? cat['color'].withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat['icon'], color: isActive ? cat['color'] : colorScheme.onSurfaceVariant, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'],
                      style: AppTextStyles.labelMedium.copyWith(color: isActive ? cat['color'] : colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
            Text('CONTENU DU COMMUNIQUÉ *', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 2)),
            Text('0/2000', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.02),
                  border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
                ),
                child: Row(
                  children: [
                    _buildToolButton(context, Icons.format_bold),
                    _buildToolButton(context, Icons.format_italic),
                    _buildToolButton(context, Icons.format_list_bulleted),
                    SizedBox(width: 8, child: VerticalDivider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                    _buildToolButton(context, Icons.link),
                  ],
                ),
              ),
              TextField(
                maxLines: 6,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Rédigez votre message ici...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
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

  Widget _buildToolButton(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
      onPressed: () {},
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTargetSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DESTINATAIRES *', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 2)),
        const SizedBox(height: 16),
        _buildTargetCard(context, 'Toute l\'université', '487 étudiants actifs', true),
        const SizedBox(height: 12),
        _buildTargetCard(context, 'Par filière', 'Sélectionnez une ou plusieurs filières', false),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Par niveau', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['L1', 'L2', 'L3', 'M1', 'M2'].map((lvl) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Text(lvl, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCard(BuildContext context, String title, String subtitle, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? BorderDirectional(
              start: const BorderSide(color: AppColors.amber, width: 4),
              top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              end: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
            )
          : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
            ],
          ),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.amber)
          else Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1), width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.picture_as_pdf, size: 32, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('+ Ajouter un PDF', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
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
          const Icon(Icons.notifications_active, color: AppColors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Une notification push sera envoyée immédiatement aux destinataires lors de la publication.',
              style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface),
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
          border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Show confirmation sheet or publish
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 10,
            shadowColor: AppColors.amber.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Publier le communiqué', style: AppTextStyles.headlineMedium.copyWith(color: Colors.black, fontSize: 18)),
              const SizedBox(width: 8),
              const Icon(Icons.send),
            ],
          ),
        ),
      ),
    );
  }
}
