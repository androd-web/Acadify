import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/course_service.dart';
import '../../../core/models/course_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/grade_model.dart';

class TeacherGradeEntry extends StatefulWidget {
  const TeacherGradeEntry({super.key});

  @override
  State<TeacherGradeEntry> createState() => _TeacherGradeEntryState();
}

class _TeacherGradeEntryState extends State<TeacherGradeEntry> {
  final CourseService _courseService = CourseService();
  final Box _userBox = Hive.box('userBox');

  int _maxGrade = 20;
  String _selectedEvaluation = 'Partiel 1';
  final List<String> _evaluations = ['Partiel 1', 'Partiel 2', 'DS', 'Examen Final'];
  
  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  List<UserModel> _students = [];
  final Map<String, TextEditingController> _gradeControllers = {};
  
  bool _isLoadingCourses = true;
  bool _isLoadingStudents = false;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
        _gradeControllers.clear();
        for (var student in _students) {
          _gradeControllers[student.uid] = TextEditingController();
          _gradeControllers[student.uid]!.addListener(() => setState(() {}));
        }
        _isLoadingStudents = false;
      });
    }
  }

  double _calculateAverage() {
    double total = 0;
    int count = 0;
    for (var controller in _gradeControllers.values) {
      final val = double.tryParse(controller.text);
      if (val != null) {
        total += val;
        count++;
      }
    }
    return count > 0 ? total / count : 0.0;
  }

  Future<void> _handlePublish() async {
    if (_selectedCourse == null || _gradeControllers.isEmpty) return;

    final Map<String, double> scores = {};
    bool hasEmpty = false;

    for (var entry in _gradeControllers.entries) {
      final score = double.tryParse(entry.value.text);
      if (score != null) {
        scores[entry.key] = score;
      } else {
        hasEmpty = true;
      }
    }

    if (hasEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notes manquantes'),
          content: const Text('Certains étudiants n\'ont pas de note. Voulez-vous continuer ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CONTINUER')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isPublishing = true);

    final success = await _courseService.publishGrades(
      courseId: _selectedCourse!.id,
      subjectName: _selectedCourse!.name,
      teacherName: _userBox.get('name'),
      maxScore: _maxGrade.toDouble(),
      semester: _selectedCourse!.semester,
      evaluation: _getEvaluationType(_selectedEvaluation),
      studentGrades: scores,
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes publiées avec succès !')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la publication.')),
        );
      }
    }
  }

  EvaluationType _getEvaluationType(String eval) {
    switch (eval) {
      case 'Partiel 1': return EvaluationType.partiel1;
      case 'Examen Final': return EvaluationType.finalExam;
      default: return EvaluationType.ds;
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
            child: _isLoadingCourses 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildConfigCard(context),
                    const SizedBox(height: 32),
                    _buildDistributionChart(context),
                    const SizedBox(height: 32),
                    _buildStudentListHeader(context),
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
          if (_isPublishing)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
          _buildBottomActionBar(context),
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Saisir les notes',
                style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _handlePublish,
                child: Text('SAUVEGARDER', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          _buildConfigRow(
            'Matière',
            InkWell(
              onTap: _showCoursePicker,
              child: Row(
                children: [
                  Text(_selectedCourse?.name ?? 'Sélectionner', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Évaluation', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _evaluations.map((eval) {
                      final isActive = _selectedEvaluation == eval;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedEvaluation = eval),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? colorScheme.primaryContainer : colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isActive ? Colors.transparent : colorScheme.onSurface.withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              eval,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isActive ? colorScheme.onPrimaryContainer : AppColors.onSurfaceVariant,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          _buildConfigRow(
            'Note maximale',
            Row(
              children: [
                _buildGradeButton(context, Icons.remove, () => setState(() => _maxGrade = math.max(1, _maxGrade - 1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$_maxGrade', style: AppTextStyles.headlineMedium),
                ),
                _buildGradeButton(context, Icons.add, () => setState(() => _maxGrade++)),
              ],
            ),
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

  Widget _buildConfigRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          trailing,
        ],
      ),
    );
  }

  Widget _buildGradeButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
        child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 16),
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context) {
    // Calculer la distribution réelle basée sur les notes saisies
    int g1=0, g2=0, g3=0, g4=0, g5=0;
    for (var controller in _gradeControllers.values) {
      final val = double.tryParse(controller.text);
      if (val != null) {
        if (val < 5) {
          g1++;
        } else if (val < 10) {
          g2++;
        } else if (val < 14) {
          g3++;
        } else if (val < 18) {
          g4++;
        } else {
          g5++;
        }
      }
    }
    int max = [g1, g2, g3, g4, g5].reduce(math.max);
    double factor(int v) => max == 0 ? 0.05 : v / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, color: AppColors.onSurfaceVariant, size: 18),
            const SizedBox(width: 8),
            Text('DISTRIBUTION DES NOTES', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('0-5', factor(g1), AppColors.errorContainer),
              _buildChartBar('6-9', factor(g2), AppColors.tertiaryContainer),
              _buildChartBar('10-13', factor(g3), AppColors.secondaryContainer),
              _buildChartBar('14-17', factor(g4), AppColors.primaryContainer),
              _buildChartBar('18-20', factor(g5), AppColors.amber.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(String label, double heightFactor, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 60 * heightFactor + 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStudentListHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Étudiants', style: AppTextStyles.headlineMedium),
            const SizedBox(width: 8),
            Text('(${_students.length})', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary.withValues(alpha: 0.6))),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: colorScheme.surfaceContainer, shape: BoxShape.circle),
          child: const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
        ),
      ],
    );
  }

  Widget _buildStudentList(BuildContext context) {
    if (_students.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aucun étudiant trouvé.')));
    return Column(
      children: _students.map((student) {
        return _buildStudentItem(context, student);
      }).toList(),
    );
  }

  Widget _buildStudentItem(BuildContext context, UserModel student) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = _gradeControllers[student.uid];
    final bool hasGrade = controller?.text.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: hasGrade 
          ? Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05))
          : Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
              )
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(student.matricule, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(
            hasGrade ? Icons.check_circle : Icons.warning,
            color: hasGrade ? AppColors.secondary : AppColors.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 40,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(border: InputBorder.none),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final average = _calculateAverage();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MOYENNE DE CLASSE', style: AppTextStyles.labelSmall.copyWith(letterSpacing: -0.5)),
                Text('${average.toStringAsFixed(2)} / $_maxGrade', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary)),
              ],
            ),
            ElevatedButton(
              onPressed: _isPublishing ? null : _handlePublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.send, size: 18),
                  const SizedBox(width: 8),
                  Text('Publier', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
