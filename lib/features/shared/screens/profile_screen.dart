import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_navigation_bar.dart';

enum UserRole { student, teacher, admin }

class ProfileScreen extends StatelessWidget {
  final UserRole role;

  const ProfileScreen({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileHero(context),
                  const SizedBox(height: 32),
                  _buildRoleSpecificInfo(context),
                  const SizedBox(height: 24),
                  _buildSettingsList(context),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              Text(
                'Mon Profil',
                style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: colorScheme.onSurface),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String name = "Utilisateur Acadify";
    String subtitle = "ID: AC-2026-001";
    String roleLabel = "Utilisateur";
    String imageUrl = 'https://i.pravatar.cc/300?u=acadify';

    switch (role) {
      case UserRole.student:
        name = "Amara Diallo";
        subtitle = "Informatique • AD2024-0892";
        roleLabel = "Étudiante";
        imageUrl = 'https://i.pravatar.cc/300?u=amara';
        break;
      case UserRole.teacher:
        name = "Dr. Jean-Baptiste";
        subtitle = "Département Informatique";
        roleLabel = "Enseignant";
        imageUrl = 'https://i.pravatar.cc/300?u=jb';
        break;
      case UserRole.admin:
        name = "Admin Acadify";
        subtitle = "Administration Centrale";
        roleLabel = "Administrateur";
        imageUrl = 'https://i.pravatar.cc/300?u=admin';
        break;
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.5), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            roleLabel,
            style: AppTextStyles.labelMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSpecificInfo(BuildContext context) {
    if (role == UserRole.student) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoCard(context, 'Filière', 'Génie Logiciel', Icons.code)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard(context, 'Niveau', 'Licence 3', Icons.stairs)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoCard(context, 'Département', 'Informatique', Icons.account_balance)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard(context, 'Promotion', '2023-2024', Icons.calendar_today)),
            ],
          ),
        ],
      );
    } else if (role == UserRole.teacher) {
      return Column(
        children: [
          _buildInfoCard(context, 'Spécialité', 'Algorithmique & Intelligence Artificielle', Icons.psychology, isFullWidth: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoCard(context, 'Cours', '4 Actifs', Icons.menu_book)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard(context, 'Étudiants', '248 inscrits', Icons.people)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildInfoCard(context, 'Fonction', 'Directeur des Études', Icons.admin_panel_settings, isFullWidth: true),
          const SizedBox(height: 12),
          _buildInfoCard(context, 'Accès', 'Super Administrateur', Icons.security, isFullWidth: true),
        ],
      );
    }
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon, {bool isFullWidth = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildSettingsItem(context, Icons.person_outline, 'Informations personnelles', () {}),
            _buildDivider(context),
            _buildSettingsItem(context, Icons.history, 'Historique d\'activité', () {}),
            _buildDivider(context),
            _buildSettingsItem(context, Icons.notifications_none, 'Notifications', () => context.push('/notifications')),
            _buildDivider(context),
            _buildSettingsItem(context, Icons.help_outline, 'Aide & Support', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), indent: 20, endIndent: 20);
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout),
        label: const Text('Déconnexion'),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    switch (role) {
      case UserRole.teacher:
        return CustomNavigationBar(
          currentIndex: 4,
          items: [
            CustomBottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () => context.go('/teacher-dashboard')),
            CustomBottomNavItem(icon: Icons.menu_book_outlined, label: 'Cours', onTap: () => context.push('/teacher-courses')),
            CustomBottomNavItem(icon: Icons.group_outlined, label: 'Étudiants', onTap: () {}),
            CustomBottomNavItem(icon: Icons.calendar_today_outlined, label: 'Planning', onTap: () => context.push('/teacher-schedule')),
            CustomBottomNavItem(icon: Icons.person, label: 'Profil', onTap: () {}),
          ],
        );
      case UserRole.admin:
        return CustomNavigationBar(
          currentIndex: 4,
          items: [
            CustomBottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () => context.go('/admin-dashboard')),
            CustomBottomNavItem(icon: Icons.group_outlined, label: 'Users', onTap: () => context.push('/admin-users')),
            CustomBottomNavItem(icon: Icons.campaign_outlined, label: 'Alertes', onTap: () => context.push('/admin-announcements')),
            CustomBottomNavItem(icon: Icons.description_outlined, label: 'Docs', onTap: () {}),
            CustomBottomNavItem(icon: Icons.person, label: 'Profil', onTap: () {}),
          ],
        );
      case UserRole.student:
        return CustomNavigationBar(
          currentIndex: 4,
          items: [
            CustomBottomNavItem(icon: Icons.home_outlined, label: 'Accueil', onTap: () => context.go('/student-dashboard')),
            CustomBottomNavItem(icon: Icons.menu_book_outlined, label: 'Cours', onTap: () => context.push('/courses')),
            CustomBottomNavItem(icon: Icons.grade_outlined, label: 'Notes', onTap: () => context.push('/grades')),
            CustomBottomNavItem(icon: Icons.calendar_month_outlined, label: 'Planning', onTap: () => context.push('/schedule')),
            CustomBottomNavItem(icon: Icons.person, label: 'Profil', onTap: () {}),
          ],
        );
    }
  }
}
