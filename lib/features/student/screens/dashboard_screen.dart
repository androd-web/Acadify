import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_navigation_bar.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildNextCourseHero(context),
                  const SizedBox(height: 24),
                  _buildAbsenceAlert(context),
                  const SizedBox(height: 32),
                  _buildTwoColumnGrid(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          CustomNavigationBar(
            currentIndex: 0,
            items: [
              CustomBottomNavItem(icon: Icons.home, label: 'Accueil', onTap: () {}),
              CustomBottomNavItem(icon: Icons.menu_book, label: 'Cours', onTap: () => context.push('/courses')),
              CustomBottomNavItem(icon: Icons.grade, label: 'Notes', onTap: () => context.push('/grades')),
              CustomBottomNavItem(icon: Icons.calendar_month, label: 'Planning', onTap: () => context.push('/schedule')),
              CustomBottomNavItem(icon: Icons.person, label: 'Profil', onTap: () => context.push('/profile')),
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
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDG351k_EmiUmYzfGtPHedKcyBHEQGnkypU6PTBPwrxVSFo88N5gPScptFpML47P3rL3XGlu6kJS72Xq9N_ZkO6Bt9vIiPbDbfAkqHGOhJxIZOPKv7wG0BAaEMbOWPixhJiE0wzApMpy41-Q4kVR5BXCMLWuSAAtsilUPdca3xVJlE59Siz3zi0iq18TRdnuk4EvPYGM5xs1YmauUXUgkVPgjMbQaFb56_D1t1HBg8CynszpOrR42ZGslbdQR0SkaQJdPYunqKio5ds'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bonjour, Clément 👋',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.notifications, color: colorScheme.onSurfaceVariant),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextCourseHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.surfaceContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('PROCHAIN COURS', style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.9), letterSpacing: 1)),
              ),
              const Icon(Icons.schedule, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Algorithmique & Structures de Données',
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text('Dr. Jean-Baptiste', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Amphi B', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(width: 1, height: 16, color: Colors.white24),
                const SizedBox(width: 16),
                Text('08:30 - 10:30', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenceAlert(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Absences du jour', style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                Text('0 absences enregistrées', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('DÉTAILS', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.primary, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildSectionHeader(context, Icons.campaign, 'Derniers communiqués'),
        const SizedBox(height: 12),
        _buildAnnouncementCard(context, 'Urgent', 'Modification du planning des examens', 'Auj.', colorScheme.errorContainer.withValues(alpha: 0.2), colorScheme.error),
        const SizedBox(height: 12),
        _buildAnnouncementCard(context, 'Général', 'Ouverture des inscriptions aux clubs', 'Hier', colorScheme.secondaryContainer.withValues(alpha: 0.2), colorScheme.secondary),
        const SizedBox(height: 32),
        _buildSectionHeader(context, Icons.school, 'Mes notes récentes'),
        const SizedBox(height: 12),
        _buildRecentGradeCard(context, 'Intelligence Artificielle', '16/20', 0.8, colorScheme.primary),
        const SizedBox(height: 12),
        _buildRecentGradeCard(context, 'Réseaux & Télécoms', '12/20', 0.6, colorScheme.secondary),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, String tag, String title, String time, Color tagBg, Color tagText) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(20)),
                child: Text(tag.toUpperCase(), style: TextStyle(color: tagText, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              Text(time, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentGradeCard(BuildContext context, String title, String grade, double progress, Color color) {
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
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(grade, style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.verified, size: 14, color: color),
              const SizedBox(width: 4),
              Text('Validé', style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
