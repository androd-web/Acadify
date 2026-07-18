import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/course_service.dart';
import '../../../core/models/course_model.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final CourseService _courseService = CourseService();
  final Box _userBox = Hive.box('userBox');
  
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final String? uid = _userBox.get('uid');
    if (uid != null) {
      final courses = await _courseService.getTeacherCourses(uid);
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
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
            child: RefreshIndicator(
              onRefresh: _loadCourses,
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
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_courses.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucun cours trouvé.')))
                    else
                      _buildCourseCards(context),
                    const SizedBox(height: 32),
                    _buildRecentResources(context),
                    const SizedBox(height: 120),
                  ],
                ),
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
    final String? photoUrl = _userBox.get('photoUrl');
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
                  image: photoUrl != null
                      ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                      : null,
                  color: AppColors.surfaceContainerHigh,
                ),
                child: photoUrl == null ? const Icon(Icons.person, size: 16) : null,
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
        _buildStatItem(context, Icons.menu_book, '${_courses.length}', 'Total Cours', AppColors.secondary),
        _buildStatItem(context, Icons.description, '-', 'Documents', AppColors.primary),
        _buildStatItem(context, Icons.group, '-', 'Étudiants', AppColors.amber),
        _buildStatItem(context, Icons.assignment_turned_in, '-', 'Évaluations', AppColors.error),
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
      children: _courses.map((course) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildCourseCard(
          context: context,
          course: course,
        ),
      )).toList(),
    );
  }

  Widget _buildCourseCard({
    required BuildContext context,
    required CourseModel course,
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
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text('ACTIF', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                          ),
                          child: Text(course.filiere, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Icon(Icons.more_vert, color: AppColors.outline),
                  ],
                ),
                const SizedBox(height: 16),
                Text(course.name, style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
                const SizedBox(height: 16),
                _buildCourseInfoItem(Icons.school, '${course.filiere} - ${course.niveau}'),
                _buildCourseInfoItem(Icons.calendar_today, 'Semestre ${course.semester}'),
                const SizedBox(height: 16),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mis à jour: ${course.updatedAt.day}/${course.updatedAt.month}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline, fontStyle: FontStyle.italic)),
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
                _buildCourseAction(context, Icons.add_box, 'Document', () => context.push('/teacher-upload-course')),
                _buildCourseAction(context, Icons.visibility, 'Appel', () => context.push('/teacher-attendance')),
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
        _buildResourceItem(context, Icons.picture_as_pdf, 'Document_Exemple.pdf', 'Matière', 'Aujourd\'hui', AppColors.error),
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
      child: GestureDetector(
        onTap: () => context.push('/teacher-upload-course'),
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
            _buildBottomNavItem(context, Icons.dashboard, 'Dashboard', false, () => context.go('/teacher-dashboard')),
            _buildBottomNavItem(context, Icons.menu_book, 'Courses', true, () {}),
            _buildBottomNavItem(context, Icons.person, 'Profile', false, () => context.push('/teacher-profile')),
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

