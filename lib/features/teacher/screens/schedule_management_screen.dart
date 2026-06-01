import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherScheduleManagement extends StatefulWidget {
  const TeacherScheduleManagement({super.key});

  @override
  State<TeacherScheduleManagement> createState() => _TeacherScheduleManagementState();
}

class _TeacherScheduleManagementState extends State<TeacherScheduleManagement> {
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
            child: Column(
              children: [
                _buildWeekNavigator(context),
                const SizedBox(height: 16),
                Expanded(child: _buildScheduleGrid(context)),
                _buildLegend(context),
              ],
            ),
          ),
          _buildBottomSheetOverlay(context),
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
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Mon emploi du temps',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                ),
                child: Text('Aujourd\'hui', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left, color: AppColors.onSurfaceVariant),
            Text('26 Mai – 30 Mai 2026', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 60),
                ...['Lun 26', 'Mar 27', 'Mer 28', 'Jeu 29', 'Ven 30'].map((day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: day.contains('Mar') ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Grid Body
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  _buildGridBackground(context),
                  _buildEvents(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(12, (index) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Text('${7 + index}:00', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5))),
              ),
              ...List.generate(5, (dayIndex) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                    color: dayIndex == 1 ? AppColors.primary.withValues(alpha: 0.02) : null,
                  ),
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEvents() {
    return Positioned.fill(
      left: 60,
      child: Stack(
        children: [
          _buildEvent(0, 8, 2, 'Génie Logiciel', 'Amphi A', 'CM', AppColors.primaryContainer, AppColors.primary),
          _buildEvent(1, 9, 2, 'Algorithmique L2', 'Salle 402', 'TD', AppColors.primaryContainer, AppColors.primary, isSelected: true),
          _buildEvent(2, 11, 1.5, 'Systèmes d\'exploitation', '', 'TP', AppColors.errorContainer, AppColors.error, isCancelled: true),
          _buildEvent(3, 13, 2, 'Réseaux', 'Salle 105', 'TD', AppColors.primaryContainer, AppColors.secondary, isPostponed: true),
        ],
      ),
    );
  }

  Widget _buildEvent(int day, double startHour, double duration, String title, String room, String type, Color bgColor, Color textColor, {bool isSelected = false, bool isCancelled = false, bool isPostponed = false}) {
    double top = (startHour - 7) * 60;
    double height = duration * 60;
    double widthFactor = 1 / 5;

    return Positioned(
      left: day * (MediaQuery.of(context).size.width - 40 - 60) * widthFactor,
      top: top,
      width: (MediaQuery.of(context).size.width - 40 - 60) * widthFactor,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? textColor : textColor.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: textColor.withValues(alpha: 0.2), blurRadius: 10)] : null,
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: textColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(type, style: TextStyle(fontSize: 8, color: textColor, fontWeight: FontWeight.bold)),
                  ),
                  if (room.isNotEmpty) Text(room, style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.7))),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (isCancelled)
                Row(
                  children: [
                    Icon(Icons.cancel, size: 10, color: textColor),
                    const SizedBox(width: 2),
                    Text('Annulé', style: TextStyle(fontSize: 8, color: textColor, fontWeight: FontWeight.bold)),
                  ],
                )
              else if (isPostponed)
                Row(
                  children: [
                    Icon(Icons.update, size: 10, color: textColor),
                    const SizedBox(width: 2),
                    Text('Reporté', style: TextStyle(fontSize: 8, color: textColor, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Text('${startHour.toInt()}:00 - ${(startHour + duration).toInt()}:00', style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Normal', AppColors.primaryContainer),
          const SizedBox(width: 16),
          _buildLegendItem('Annulé', AppColors.errorContainer),
          const SizedBox(width: 16),
          _buildLegendItem('Reporté', AppColors.onSurfaceVariant, isDashed: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isDashed ? Border.all(color: AppColors.secondary.withValues(alpha: 0.5), style: BorderStyle.solid) : null, // Dotted not easy
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildBottomSheetOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.54),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Algorithmique L2', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('Mar 27 Mai', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 12),
                          const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('09:00 - 11:00', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(backgroundColor: colorScheme.surfaceContainerHighest, child: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 20)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Salle / Bâtiment', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: 'Salle 402, Bâtiment Sciences'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              Text('Statut de la session', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip(context, 'Normal', false),
                  const SizedBox(width: 8),
                  _buildStatusChip(context, 'Annulé', false),
                  const SizedBox(width: 8),
                  _buildStatusChip(context, 'Reporté', true),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Les étudiants seront notifiés automatiquement.', style: AppTextStyles.bodySmall)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Annuler'))),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer.withValues(alpha: 0.2) : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.secondary : colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.labelMedium.copyWith(color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant)),
      ),
    );
  }
}
