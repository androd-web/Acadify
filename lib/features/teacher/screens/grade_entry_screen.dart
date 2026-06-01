import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherGradeEntry extends StatefulWidget {
  const TeacherGradeEntry({super.key});

  @override
  State<TeacherGradeEntry> createState() => _TeacherGradeEntryState();
}

class _TeacherGradeEntryState extends State<TeacherGradeEntry> {
  int _maxGrade = 20;
  String _selectedEvaluation = 'Partiel 2';
  final List<String> _evaluations = ['Partiel 1', 'Partiel 2', 'DS', 'Examen Final'];

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
                  _buildConfigCard(context),
                  const SizedBox(height: 32),
                  _buildDistributionChart(context),
                  const SizedBox(height: 32),
                  _buildStudentListHeader(context),
                  const SizedBox(height: 16),
                  _buildStudentList(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
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
              IconButton(
                icon: const Icon(Icons.cloud_upload, color: AppColors.primary),
                onPressed: () {},
              ),
              TextButton(
                onPressed: () {},
                child: Text('SAVE', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 1)),
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
            Row(
              children: [
                Text('Algorithmique L2', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
              ],
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
                _buildGradeButton(context, Icons.remove, () => setState(() => _maxGrade = math.max(0, _maxGrade - 1))),
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
              _buildChartBar('0-5', 0.2, AppColors.errorContainer),
              _buildChartBar('6-9', 0.4, AppColors.tertiaryContainer),
              _buildChartBar('10-13', 0.85, AppColors.secondaryContainer),
              _buildChartBar('14-17', 0.6, AppColors.primaryContainer),
              _buildChartBar('18-20', 0.15, AppColors.amber.withValues(alpha: 0.4)),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 60 * heightFactor,
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
            Text('(24)', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary.withValues(alpha: 0.6))),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildStudentItem(context, 'AD', 'Amadou Diallo', '2024-AD08', '14.5', colorScheme.primaryContainer, true),
        _buildStudentItem(context, 'BK', 'Bintu Keita', '2024-BK12', '12.0', colorScheme.secondaryContainer, true),
        _buildStudentItem(context, 'CL', 'Cédric Loba', '2024-CL03', '', colorScheme.tertiaryContainer, false),
        _buildStudentItem(context, 'DM', 'Dina Mensah', '2024-DM41', '15.0', colorScheme.surfaceBright, true),
      ],
    );
  }

  Widget _buildStudentItem(BuildContext context, String initial, String name, String id, String grade, Color avatarColor, bool isCompleted) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted 
          ? Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05))
          : BorderDirectional(
              start: const BorderSide(color: AppColors.amber, width: 2),
              top: BorderSide(color: AppColors.amber.withValues(alpha: 0.3)),
              bottom: BorderSide(color: AppColors.amber.withValues(alpha: 0.3)),
              end: BorderSide(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(child: Text(initial, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(id, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.warning,
            color: isCompleted ? AppColors.secondary : AppColors.amber,
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
              controller: TextEditingController(text: grade),
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
                Text('13.4 / 20', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Show confirmation
              },
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
