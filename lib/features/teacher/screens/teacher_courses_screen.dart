import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherCoursesScreen extends StatelessWidget {
  const TeacherCoursesScreen({super.key});

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
                  Text(
                    'Gérez vos matières et ressources pédagogiques',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsOverview(context),
                  const SizedBox(height: 32),
                  _buildSearchAndFilters(context),
                  const SizedBox(height: 24),
                  _buildCourseCards(context),
                  const SizedBox(height: 32),
                  _buildRecentResources(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildFAB(),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Mes Cours',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () => context.push('/teacher-upload-course'),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAuQbVpF0Mlj2w3epD9tn5WBuaTQ1j5-ffTShfaqzgw1KABAK5F99vgXGWPm54cBMG1n79_XEl4T2OW26hWBCERzSHKijAkh0r5Dz2rejMnOsPI4hPmJH2MUf4o-N_qCPHocHXqmhK541jPxXp47UgPgNcAaHt5kSnayssWieMVvR3fMdx_ofyS0oC_JWQJx5JO-EhUvV7zm4qM-Exhm0Gn7JxLDFCRADXXULBXU82A8-wPB3HI80wWEOONx3FzZhN72mSLxY2CuiF3'),
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

  Widget _buildStatsOverview(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatItem(context, Icons.menu_book, '12', 'Total Cours', AppColors.secondary),
        _buildStatItem(context, Icons.description, '148', 'Documents', AppColors.primary),
        _buildStatItem(context, Icons.group, '420', 'Étudiants', AppColors.amber),
        _buildStatItem(context, Icons.assignment_turned_in, '8', 'Évaluations', AppColors.error),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineMedium),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
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
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une matière',
              prefixIcon: Icon(Icons.search, color: AppColors.outline),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(context, 'Tous', true),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Actifs', false),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Hors ligne', false),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Récents', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: isActive ? Colors.black : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildCourseCards(BuildContext context) {
    return Column(
      children: [
        _buildCourseCard(
          context: context,
          tag: 'Synchronisé',
          code: 'INF-401',
          title: 'Algorithmique & Structures de Données',
          dept: 'Licence 3 - Génie Logiciel',
          students: '124 Étudiants',
          docs: '32 Documents',
          lastActivity: 'Il y a 2 heures',
          isOffline: false,
        ),
        const SizedBox(height: 24),
        _buildCourseCard(
          context: context,
          tag: 'Hors ligne',
          code: 'TEL-405',
          title: 'Réseaux Mobiles & 5G Architectures',
          dept: 'Master 1 - Télécoms',
          students: '86 Étudiants',
          docs: '18 Documents',
          lastActivity: 'Hier',
          isOffline: true,
        ),
      ],
    );
  }

  Widget _buildCourseCard({
    required BuildContext context,
    required String tag,
    required String code,
    required String title,
    required String dept,
    required String students,
    required String docs,
    required String lastActivity,
    required bool isOffline,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOffline ? AppColors.amber.withValues(alpha: 0.2) : AppColors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isOffline ? AppColors.amber.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(tag.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: isOffline ? AppColors.amber : AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                          ),
                          child: Text(code, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Icon(Icons.more_vert, color: AppColors.outline),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
                const SizedBox(height: 16),
                _buildCourseInfoItem(Icons.school, dept),
                _buildCourseInfoItem(Icons.group, students),
                _buildCourseInfoItem(Icons.description, docs),
                const SizedBox(height: 16),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dernière activité: $lastActivity', style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline, fontStyle: FontStyle.italic)),
                    _buildStudentAvatars(context),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                _buildCourseAction(context, Icons.add_box, 'Document', () {}),
                _buildCourseAction(context, Icons.visibility, 'Étudiants', () {}),
                _buildCourseAction(context, Icons.rate_review, 'Notes', () => context.push('/teacher-grade-entry')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStudentAvatars(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surfaceContainerLow, width: 2),
          ),
          child: const Center(child: Text('+121', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
        ),
        _buildMiniAvatar(context, 'https://lh3.googleusercontent.com/aida-public/AB6AXuB6hMMfAjR5UmlqO0DBQysTWZrmer_mu6qDezBGf8vEt4FZxpaH0GaFt1GEZq3BkhJpxm9q60gPWZsC0zJCXGx48fI9DEHIgD563XPpDil4A0m0EO57eUNablF6QU6EYpFKDTPa8ihmIFKHJPSbWRFp6I01SjKJ1FXrImVfZ3UJRlsAQYAJTxsixYIoB9sjtH-OadI5ekVL4omTPdl3tp49_PQtl9Az01BeC-9YjuqsiwXvWmz_HE7KUsXDwYULTzqu6g5RbNjFHMoN'),
        _buildMiniAvatar(context, 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVr9erNdIao_dlXB6MPLtMb4hUiapRVXgqV9mZxoE316UYCLKpfZpDkRCubjV0nCo86xsRPXuu8zGE1EyhaFdK_UWkHJ80sRnWnsvBvWhB3HtgdYfHoGgwERIHgoE4dgAL-7GcLJ8V0BViD-v0ZpTKy8Mp7o8RwcIKhKTDoO_dewVVsKm6qhdaeTap91AH_mTSWH3zfzltjLaV4CUY2M0rKb09wwwKObHiysGWNadpHMqLLizn2XcgRhe7ErnW4tVlBeyHPuJvhkwp'),
      ].reversed.toList(),
    );
  }

  Widget _buildMiniAvatar(BuildContext context, String url) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: -8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surfaceContainerLow, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCourseAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentResources(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ressources Récentes', style: AppTextStyles.headlineMedium),
            TextButton(
              onPressed: () {},
              child: Text('Voir Tout', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildResourceItem(context, Icons.picture_as_pdf, 'TD_Arbres_Binaires.pdf', 'Algorithmique', 'Ajouté hier', AppColors.error),
        const SizedBox(height: 12),
        _buildResourceItem(context, Icons.description, 'Exam_Final_Architecture.docx', 'Architecture', 'Il y a 3 jours', AppColors.secondary),
        const SizedBox(height: 12),
        _buildResourceItem(context, Icons.slideshow, 'Lecture_5G_NR.pptx', 'Réseaux Mobiles', 'Il y a 1 semaine', AppColors.primary),
      ],
    );
  }

  Widget _buildResourceItem(BuildContext context, IconData icon, String title, String course, String time, Color iconColor) {
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(course, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.24), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(time, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.download, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.amber,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
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
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.dashboard, 'Dashboard', false, () => context.push('/teacher-dashboard')),
            _buildBottomNavItem(context, Icons.menu_book, 'Courses', true, () {}),
            _buildBottomNavItem(context, Icons.group, 'Students', false, () {}),
            _buildBottomNavItem(context, Icons.calendar_today, 'Planning', false, () {}),
            _buildBottomNavItem(context, Icons.person, 'Profile', false, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 4),
                  Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                ],
              ),
            )
          else
            Column(
              children: [
                Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelMedium),
              ],
            ),
        ],
      ),
    );
  }
}
