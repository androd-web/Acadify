import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_navigation_bar.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

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
                  Text('Gérez vos activités académiques', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  _buildHeroCourseCard(context),
                  const SizedBox(height: 32),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildCourseManagement(context),
                  const SizedBox(height: 32),
                  _buildRecentActivity(context),
                  const SizedBox(height: 32),
                  _buildStatistics(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          CustomNavigationBar(
            currentIndex: 0,
            items: [
              CustomBottomNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
              CustomBottomNavItem(icon: Icons.menu_book, label: 'Cours', onTap: () => context.push('/teacher-courses')),
              CustomBottomNavItem(icon: Icons.group, label: 'Étudiants', onTap: () {}),
              CustomBottomNavItem(icon: Icons.calendar_today, label: 'Planning', onTap: () => context.push('/teacher-schedule')),
              CustomBottomNavItem(icon: Icons.person, label: 'Profil', onTap: () => context.push('/teacher-profile')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primaryContainer, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCOPlRypfb2Rh6JEyUcYo1rXP10avrFjYbPK2e4m9RPCIrMKTA4hU6P8Kc2IVKyiptBnlEGZZdbiejYo752OoAXvTNMracDVRiyaRV-5GWXQkjAXxuAoV61_KyljJ90XjVsoXqodjQ56lw2ebrH-3Ql2c6zAcUCNgqB-m7g0IAgEsv6QlAv6tFjBLuCdqZWBMhiVJXsQ5yuq6c6Ki2WheI24aQhKPbnGoVMMikeejdlKyUygbf7NfANyaFDyUGOSpnI9259_tcjVYr8'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bonjour Professeur 👋',
                style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.notifications, color: colorScheme.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCourseCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 20,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Prochain cours dans 15 min',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
              const Icon(Icons.auto_stories, color: Colors.white54, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Algorithmique & Structures de Données',
            style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildHeroInfoItem(Icons.schedule, '10:30 - 12:30'),
              _buildHeroInfoItem(Icons.location_on, 'Amphi B, Bloc C'),
              _buildHeroInfoItem(Icons.groups, '142 Étudiants'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions Rapides', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildActionCard(context, Icons.add_circle, 'Ajouter un cours', () => context.push('/teacher-upload-course')),
            _buildActionCard(context, Icons.grading, 'Publier une note', () => context.push('/teacher-grade-entry')),
            _buildActionCard(context, Icons.campaign, 'Envoyer un communiqué', () {}),
            _buildActionCard(context, Icons.upload_file, 'Télécharger document', () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseManagement(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vos Cours', style: theme.textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/teacher-courses'),
              child: Text('Tout voir', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTeacherCourseCard(context, 'Systèmes d\'Information', 'Informatique', '85', '12', colorScheme.primary),
        const SizedBox(height: 12),
        _buildTeacherCourseCard(context, 'Réseaux Mobiles', 'Télécoms', '64', '8', colorScheme.secondaryContainer),
      ],
    );
  }

  Widget _buildTeacherCourseCard(BuildContext context, String title, String dept, String students, String docs, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(dept, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
              Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCourseStat(context, Icons.group, '$students Étudiants', colorScheme.primary),
              const SizedBox(width: 24),
              _buildCourseStat(context, Icons.description, '$docs Documents', colorScheme.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStat(BuildContext context, IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.labelMedium?.copyWith(color: color, fontSize: 10)),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité Récente', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildActivityItem(context, Icons.task, 'Nouvelle soumission: Devoir 2 - Algorithmique', 'il y a 2m', colorScheme.primary),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
              _buildActivityItem(context, Icons.picture_as_pdf, 'Document partagé: Support_Cours_V3.pdf', 'il y a 1h', colorScheme.secondaryContainer),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String text, String time, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: theme.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(time, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatBox(context, 'Cours', '4', colorScheme.primary),
              const SizedBox(width: 12),
              _buildStatBox(context, 'Documents', '28', colorScheme.primary),
              const SizedBox(width: 12),
              _buildStatBox(context, 'Présence', '92%', colorScheme.primary),
              const SizedBox(width: 12),
              _buildStatBox(context, 'Évaluations', '3', colorScheme.primary, subtitle: 'en attente'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, Color color, {String? subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
