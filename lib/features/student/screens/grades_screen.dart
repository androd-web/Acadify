import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/grade_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _userBox = Hive.box('userBox');
  
  int _selectedSemester = 1;
  bool _isLoading = true;
  List<GradeModel> _grades = [];

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    final String? uid = _userBox.get('uid');
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('grades')
          .doc(uid)
          .collection('subjects')
          .where('semester', isEqualTo: _selectedSemester)
          .get();

      if (mounted) {
        setState(() {
          _grades = snapshot.docs.map((doc) => GradeModel.fromMap(doc.data(), doc.id)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _averageGrade {
    if (_grades.isEmpty) return 0.0;
    double totalWeighted = 0;
    int totalCoeff = 0;
    for (var g in _grades) {
      totalWeighted += g.score * g.coefficient;
      totalCoeff += g.coefficient;
    }
    return totalWeighted / totalCoeff;
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
            top: 100,
            child: RefreshIndicator(
              onRefresh: _fetchGrades,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildGPAHero(context),
                    const SizedBox(height: 32),
                    _buildSemesterTabs(context),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_grades.isEmpty)
                      _buildEmptyState()
                    else
                      ..._grades.map((grade) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGradeCard(context, grade),
                      )),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.assignment_outlined, size: 64, color: AppColors.onSurface.withValues(alpha: 0.1)),
        const SizedBox(height: 16),
        const Text('Aucune note enregistrée pour ce semestre.'),
      ],
    );
  }

  Widget _buildGPAHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avg = _averageGrade;
    final color = avg >= 12 ? Colors.green : (avg >= 10 ? Colors.orange : Colors.red);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 40)],
      ),
      child: Column(
        children: [
          Text('MOYENNE GÉNÉRALE', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(
            avg.toStringAsFixed(2),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
          ),
          Text('/ 20', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              avg >= 10 ? 'SEMESTRE VALIDÉ' : 'EN ATTENTE',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, GradeModel grade) {
    final ratio = grade.score / grade.maxScore;
    final color = ratio >= 0.6 ? Colors.green : (ratio >= 0.5 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grade.subjectName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(grade.teacherName, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${grade.score.toStringAsFixed(1)} / ${grade.maxScore.toInt()}', 
                       style: AppTextStyles.headlineMedium.copyWith(color: color)),
                  Text('Coeff: ${grade.coefficient}', style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _buildTab(context, 'Semestre 1', _selectedSemester == 1, () => _changeSemester(1)),
          _buildTab(context, 'Semestre 2', _selectedSemester == 2, () => _changeSemester(2)),
        ],
      ),
    );
  }

  void _changeSemester(int s) {
    if (_selectedSemester == s) return;
    setState(() {
      _selectedSemester = s;
      _isLoading = true;
    });
    _fetchGrades();
  }

  Widget _buildTab(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.onSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
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
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('Mes Notes', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
