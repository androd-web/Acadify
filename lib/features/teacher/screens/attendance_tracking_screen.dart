import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/course_service.dart';
import '../../../core/models/course_model.dart';
import '../../../core/models/user_model.dart';

class AttendanceTrackingScreen extends StatefulWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  State<AttendanceTrackingScreen> createState() =>
      _AttendanceTrackingScreenState();
}

class _AttendanceTrackingScreenState extends State<AttendanceTrackingScreen> {
  final CourseService _courseService = CourseService();
  final Box _userBox = Hive.box('userBox');

  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  List<UserModel> _students = [];
  final Map<String, bool> _attendanceStatus = {}; // studentUid -> isPresent
  
  bool _isLoadingCourses = true;
  bool _isLoadingStudents = false;
  bool _isValidating = false;

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
          if (_courses.isNotEmpty) {
            _selectedCourse = _courses.first;
            _loadStudents();
          }
          _isLoadingCourses = false;
        });
      }
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedCourse == null) return;
    
    setState(() => _isLoadingStudents = true);
    
    final students = await _courseService.getStudentsForCourse(
      _selectedCourse!.filiere,
      _selectedCourse!.niveau,
    );

    if (mounted) {
      setState(() {
        _students = students;
        _attendanceStatus.clear();
        for (var student in _students) {
          _attendanceStatus[student.uid] = true; // Par défaut présent
        }
        _isLoadingStudents = false;
      });
    }
  }

  void _toggleStatus(String uid, bool isPresent) {
    setState(() {
      _attendanceStatus[uid] = isPresent;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var uid in _attendanceStatus.keys) {
        _attendanceStatus[uid] = true;
      }
    });
  }

  Future<void> _handleValidate() async {
    if (_selectedCourse == null || _students.isEmpty) return;

    final List<String> absentUids = _attendanceStatus.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();

    setState(() => _isValidating = true);

    final success = await _courseService.recordAttendance(
      courseId: _selectedCourse!.id,
      subjectName: _selectedCourse!.name,
      absentStudentUids: absentUids,
    );

    if (mounted) {
      setState(() => _isValidating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appel validé avec succès !')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la validation.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _attendanceStatus.values.where((v) => v == true).length;
    int absentCount = _attendanceStatus.length - presentCount;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: _isLoadingCourses
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildStickyConfig(context),
                    const SizedBox(height: 24),
                    _buildLiveCounter(presentCount, absentCount),
                    const SizedBox(height: 24),
                    _buildBulkActions(),
                    const SizedBox(height: 16),
                    if (_isLoadingStudents)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildStudentList(context),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
          ),
          if (_isValidating)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
          _buildBottomAction(context, presentCount, absentCount),
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
                'Feuille d\'appel',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyConfig(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _showCoursePicker,
                child: Row(
                  children: [
                    Text(
                      _selectedCourse?.name ?? 'Sélectionner',
                      style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                    ),
                    const Icon(
                      Icons.expand_more,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Cours Magistral',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.event,
                color: AppColors.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Lundi 26 Mai 2026',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCoursePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            title: Text(course.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('${course.filiere} - ${course.niveau}', style: const TextStyle(color: Colors.white70)),
            onTap: () {
              setState(() {
                _selectedCourse = course;
                _loadStudents();
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildLiveCounter(int present, int absent) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCounterChip('Présents: $present', AppColors.secondary),
          const SizedBox(width: 12),
          _buildCounterChip('Absents: $absent', AppColors.error),
          const SizedBox(width: 12),
          _buildCounterChip(
            'Total: ${_students.length}',
            AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _markAllPresent,
          icon: const Icon(Icons.done_all, size: 18, color: AppColors.primary),
          label: Text(
            'Marquer tous présents',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              for (var uid in _attendanceStatus.keys) {
                _attendanceStatus[uid] = false;
              }
            });
          },
          child: Text(
            'Réinitialiser',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final bool isPresent = _attendanceStatus[student.uid] ?? true;
        final bool isAbsent = !isPresent;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAbsent
                ? AppColors.error.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAbsent
                  ? AppColors.error.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 16,
                        color: AppColors.onSurface.withValues(alpha: isAbsent ? 0.6 : 1.0),
                      ),
                    ),
                    Text(
                      student.matricule,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildStatusButton(
                      student.uid,
                      true,
                      isPresent,
                    ),
                    _buildStatusButton(
                      student.uid,
                      false,
                      isAbsent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(String uid, bool isPresent, bool isActive) {
    final Color activeColor = isPresent ? AppColors.primary : AppColors.error;
    final IconData icon = isPresent ? Icons.check : Icons.close;

    return InkWell(
      onTap: () => _toggleStatus(uid, isPresent),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive
              ? (isPresent ? AppColors.primary : Colors.white)
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, int present, int absent) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('$present présents', style: AppTextStyles.bodySmall),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: CircleAvatar(
                        radius: 2,
                        backgroundColor: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$absent absents',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Voir la liste',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _handleValidate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Valider l\'appel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.send, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
