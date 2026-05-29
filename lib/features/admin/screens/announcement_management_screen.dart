import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminAnnouncementManagement extends StatefulWidget {
  const AdminAnnouncementManagement({super.key});

  @override
  State<AdminAnnouncementManagement> createState() => _AdminAnnouncementManagementState();
}

class _AdminAnnouncementManagementState extends State<AdminAnnouncementManagement> {
  String _activeFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Urgent', 'Information', 'Général', 'Archivés'];

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
                  const SizedBox(height: 12),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildFilters(context),
                  const SizedBox(height: 24),
                  _buildAnnouncementList(context),
                  const SizedBox(height: 32),
                  _buildArchivedSection(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildFAB(context),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.8),
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communiqués',
                    style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '14 publiés · 3 archivés',
                    style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.amber),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un communiqué...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.amber : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive ? null : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? Colors.black : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnnouncementList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildAnnouncementCard(
          context: context,
          color: colorScheme.error,
          type: 'Urgent',
          time: 'Aujourd\'hui, 09:45',
          title: 'Report des examens de fin de semestre - Faculté de Droit',
          tags: ['Faculté de Droit'],
          views: '1.2k',
          status: 'PUBLIÉ',
        ),
        const SizedBox(height: 16),
        _buildAnnouncementCard(
          context: context,
          color: colorScheme.secondary,
          type: 'Information',
          time: 'Hier, 14:20',
          title: 'Mise à jour de la plateforme de bourses d\'études 2024',
          tags: ['Toute l\'université'],
          views: '856',
          status: 'PUBLIÉ',
        ),
        const SizedBox(height: 16),
        _buildAnnouncementCard(
          context: context,
          color: AppColors.amber,
          type: 'Général',
          time: '24 Oct, 11:00',
          title: 'Inauguration du nouveau complexe sportif UIECC',
          tags: ['Tous les Campus'],
          views: '3.4k',
          status: 'PUBLIÉ',
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required Color color,
    required String type,
    required String time,
    required String title,
    required List<String> tags,
    required String views,
    required String status,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(type.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: color, letterSpacing: 1, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(time, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...tags.map((tag) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                          ),
                          child: Text(tag, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                        )),
                    Icon(Icons.visibility, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('$views vus', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(status, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Archivés (3)', style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant)),
            Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: 0.5,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(width: 4, height: 40, decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ARCHIVES', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                          Text('12 Sep 2024', style: AppTextStyles.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Fermeture temporaire de la Bibliothèque Centrale', style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () => context.push('/admin-compose-announcement'),
        backgroundColor: AppColors.amber,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('NOUVEAU', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.grid_view, 'Dashboard', false, () => context.go('/admin-dashboard')),
            _buildBottomNavItem(context, Icons.group, 'Users', false, () {}),
            _buildBottomNavItem(context, Icons.notifications_active, 'Alerts', true, () {}),
            _buildBottomNavItem(context, Icons.settings, 'Settings', false, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
    );
  }
}
