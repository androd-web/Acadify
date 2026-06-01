import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AttendanceTrackingScreen extends StatefulWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  State<AttendanceTrackingScreen> createState() =>
      _AttendanceTrackingScreenState();
}

class _AttendanceTrackingScreenState extends State<AttendanceTrackingScreen> {
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'MAT-2024-001',
      'name': 'Jean-Pierre Sarr',
      'initials': 'JS',
      'isPresent': true,
    },
    {
      'id': 'MAT-2024-042',
      'name': 'Marie Traoré',
      'initials': 'MT',
      'isPresent': false,
    },
    {
      'id': 'MAT-2024-118',
      'name': 'Cédric Loba',
      'initials': 'CL',
      'isPresent': true,
      'warning': 'ABS++',
    },
    {
      'id': 'MAT-2024-009',
      'name': 'Awa Koné',
      'initials': 'AK',
      'isPresent': true,
    },
    {
      'id': 'MAT-2024-056',
      'name': 'Bakary Diallo',
      'initials': 'BD',
      'isPresent': true,
    },
  ];

  void _toggleStatus(int index, bool isPresent) {
    setState(() {
      _students[index]['isPresent'] = isPresent;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        student['isPresent'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students.where((s) => s['isPresent'] == true).length;
    int absentCount = _students.length - presentCount;
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
                  _buildStickyConfig(context),
                  const SizedBox(height: 24),
                  _buildLiveCounter(presentCount, absentCount),
                  const SizedBox(height: 24),
                  _buildBulkActions(),
                  const SizedBox(height: 16),
                  _buildStudentList(context),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
          _buildBottomAction(context, presentCount, absentCount),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
          ),
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
              Row(
                children: [
                  Text(
                    'Algorithmique L2',
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                  ),
                  const Icon(
                    Icons.expand_more,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
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
          onPressed: () {},
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
        final bool isAbsent = !student['isPresent'];
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
                    student['initials'],
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
                    Row(
                      children: [
                        Text(
                          student['name'],
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 16,
                            color: AppColors.onSurface.withValues(alpha: isAbsent ? 0.6 : 1.0),
                          ),
                        ),
                        if (student['warning'] != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  size: 10,
                                  color: AppColors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  student['warning'],
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppColors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      student['id'],
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
                      index,
                      true,
                      student['isPresent'] == true,
                    ),
                    _buildStatusButton(
                      index,
                      false,
                      student['isPresent'] == false,
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

  Widget _buildStatusButton(int index, bool isPresent, bool isActive) {
    final Color activeColor = isPresent ? AppColors.primary : AppColors.error;
    final IconData icon = isPresent ? Icons.check : Icons.close;

    return InkWell(
      onTap: () => _toggleStatus(index, isPresent),
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
                onPressed: () {
                  // Show confirmation
                },
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
