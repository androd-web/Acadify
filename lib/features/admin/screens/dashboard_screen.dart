import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_navigation_bar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 32),
                  _buildKPIStats(context),
                  const SizedBox(height: 32),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildSystemHealth(context),
                  const SizedBox(height: 32),
                  _buildRecentActivity(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          CustomNavigationBar(
            currentIndex: 0,
            items: [
              CustomBottomNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
              CustomBottomNavItem(icon: Icons.group, label: 'Utilisateurs', onTap: () {}),
              CustomBottomNavItem(icon: Icons.campaign, label: 'Alertes', onTap: () {}),
              CustomBottomNavItem(icon: Icons.description, label: 'Docs', onTap: () {}),
              CustomBottomNavItem(icon: Icons.settings, label: 'Paramètres', onTap: () {}),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Icon(Icons.menu, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                'Acadify UIECC',
                style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDf1JxLqy0RD6QMsoeVR2c45nAwlbXO2AUXHBmvBSVyt46DMOCaNRzc4ltRZVKmcxFnr3YuUgHLy4apf5RIoZ_YmfKIgXcbJZprSwgYbJCRw-YcCYQLPoNUSQM6Rf1fHUnJh1I1rYk7ghmUcWfRrmGvPvqTCHZ1nBu9oGlbTiElqBLMrVl-4ms9wtaEpqT_Yvz8cpnNS4PNXNikFwaWIC9lBKtGb7djbMJYwAtsdGkRfyyIq8cPTQoBRGIR1faM8xpPDvkRTG5lSlhH'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Administrateur',
                style: TextStyle(color: AppColors.amber, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lundi 26 Mai 2026',
              style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tableau de bord — UIECC',
          style: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, color: colorScheme.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              'Administration · Sangmélima',
              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard(context, '487', 'Étudiants actifs', Icons.group, colorScheme.secondary, '+12%'),
        _buildKPICard(context, '23', 'Enseignants', Icons.school, AppColors.amber, 'Stable'),
        _buildKPICard(context, '14', 'Communiqués', Icons.campaign, colorScheme.primary, '+4'),
        _buildKPICard(context, '138', 'Documents', Icons.folder_open, AppColors.amber, '+85'),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String value, String label, IconData icon, Color color, String trend) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(trend, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.headlineLarge.copyWith(fontSize: 28, color: colorScheme.onSurface)),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actions rapides', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface)),
            Text('Tout voir', style: AppTextStyles.labelMedium.copyWith(color: AppColors.amber)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionItem(context, Icons.post_add, 'Nouveau communiqué', colorScheme.primary, () => context.push('/admin-compose-announcement')),
            _buildActionItem(context, Icons.person_add, 'Ajouter utilisateur', colorScheme.secondary, () {}),
            _buildActionItem(context, Icons.manage_accounts, 'Gérer communiqués', AppColors.amber, () => context.push('/admin-announcements')),
            _buildActionItem(context, Icons.group_work, 'Gérer utilisateurs', colorScheme.onSurfaceVariant, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: colorScheme.secondary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Text('État du système', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 20),
          _buildHealthRow(context, 'Firebase connection', 'Connecté', true),
          _buildHealthRow(context, 'Notifications FCM', 'Opérationnel', true),
          _buildHealthRow(context, 'Dernière synchro', 'il y a 4 min', null),
          const SizedBox(height: 12),
          Text('Storage usage (234 Mo / 1 Go)', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.23,
              backgroundColor: colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, String status, bool? isPositive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
          Row(
            children: [
              if (isPositive != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: isPositive ? colorScheme.secondary : colorScheme.error, shape: BoxShape.circle),
                ),
              Text(status, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: isPositive == true ? colorScheme.secondary : colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité récente', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildActivityItem(context, Icons.upload, 'Dr. Mbida a uploadé Intro_Informatique_v2.pdf', 'Il y a 1h', colorScheme.primary),
              _buildActivityItem(context, Icons.campaign, 'Communiqué : Suspension des cours pour l\'Ascension', 'Il y a 3h', AppColors.amber),
              _buildActivityItem(context, Icons.person_add, 'Nouveau compte étudiant créé : Jean-Marc Biyong', 'Hier', colorScheme.secondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String text, String time, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface)),
                Text(time, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
