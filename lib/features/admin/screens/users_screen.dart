import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

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
                  const SizedBox(height: 12),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAnalyticsGrid(context),
                  const SizedBox(height: 32),
                  _buildSearchAndFilters(context),
                  const SizedBox(height: 24),
                  _buildUserList(context),
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
          child: Row(
            children: [
              const Icon(Icons.menu, color: AppColors.primary),
              const SizedBox(width: 16),
              Text(
                'University Admin',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCdt98Rj3-eCBzf_xmlbfVm02ODF0sIbpv6ac1go-sE4Valvc_tSrrJ_SDVRuS9vCFy_arck1ja4I3AJc_w1-Umu9AraBKIaJ1hnEygKfBZukxenOrP_XvOS-ube41m8a9hkbIxlIhvGztDYl9jbrwvPs-Nwuey-k3iE9R3yVOAPMnRzGGYmq49JVawqNknIUhknCsa9TPsvM7Kvs36YfaO9022LHI0FX5OYBWXF0mWa9mdPyjAnU8YYNIMoLqw64Oxc3rIEDZLVmKh'),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion des utilisateurs', style: AppTextStyles.headlineLarge),
        Text(
          'Supervisez les comptes académiques',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(context, 'Total utilisateurs', '510', null),
        _buildStatCard(context, 'Étudiants', '487', AppColors.primary),
        _buildStatCard(context, 'Enseignants', '23', AppColors.secondaryContainer),
        _buildStatCard(context, 'Suspendus', '2', AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color? borderColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null 
          ? Border(left: BorderSide(color: borderColor, width: 4))
          : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: borderColor ?? AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou matricule',
              prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tous', true),
              const SizedBox(width: 8),
              _buildFilterChip('Étudiants', false),
              const SizedBox(width: 8),
              _buildFilterChip('Enseignants', false),
              const SizedBox(width: 8),
              _buildFilterChip('Administrateurs', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return Column(
      children: [
        _buildUserCard(context, 'KM', 'Kofi Mensah', 'MAT-2024-001', 'Étudiant', true),
        const SizedBox(height: 12),
        _buildUserCard(context, 'AD', 'Amina Diallo', 'PROF-2022-042', 'Enseignant', true),
        const SizedBox(height: 12),
        _buildUserCard(context, 'SO', 'Samuel Okoro', 'ADM-2019-005', 'Administrateur', true),
        const SizedBox(height: 12),
        _buildUserCard(context, 'JB', 'Jean Bakari', 'MAT-2023-118', 'Étudiant', false),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, String initials, String name, String id, String role, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    Color roleColor;
    if (role == 'Étudiant') {
      roleColor = AppColors.primary;
    } else if (role == 'Enseignant') {
      roleColor = AppColors.secondaryContainer;
    } else {
      roleColor = const Color(0xFF974946);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: roleColor.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(id, style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(color: roleColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Actif' : 'Suspendu',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: ElevatedButton.icon(
        onPressed: () => context.push('/admin-add-user'),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Ajouter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.4),
        ),
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
          color: AppColors.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.dashboard, 'Dashboard', false),
            _buildBottomNavItem(Icons.notifications, 'Alertes', false),
            _buildBottomNavItem(Icons.group, 'Users', true),
            _buildBottomNavItem(Icons.analytics, 'Stats', false),
            _buildBottomNavItem(Icons.account_circle, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.amber : AppColors.onSurfaceVariant,
        ),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.amber : AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
