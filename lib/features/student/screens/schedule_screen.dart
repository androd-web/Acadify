import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _userBox = Hive.box('userBox');
  
  bool _isLoading = true;
  ScheduleModel? _weeklySchedule;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    final String? filiere = _userBox.get('filiere');
    if (filiere == null) return;

    setState(() => _isLoading = true);

    try {
      // Calculer la clé de semaine (ex: 2026-W24)
      final weekKey = "${_selectedDate.year}-W${((_selectedDate.day + 7) / 7).floor()}"; // Simplifié

      final doc = await _firestore
          .collection('schedule')
          .doc(filiere)
          .collection('weeks')
          .doc(weekKey)
          .get();

      if (mounted) {
        setState(() {
          if (doc.exists) {
            _weeklySchedule = ScheduleModel.fromMap(doc.data()!, doc.id);
          } else {
            _weeklySchedule = null;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      if (mounted) setState(() => _isLoading = false);
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
            top: 100,
            child: Column(
              children: [
                _buildWeekCalendar(),
                const SizedBox(height: 24),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchSchedule,
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _weeklySchedule == null || _weeklySchedule!.slots.isEmpty
                        ? _buildEmptyState()
                        : _buildSlotsList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          // Lundi à Vendredi
          final date = DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1));
          final isSelected = date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 55,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primaryContainer : AppColors.onSurface.withValues(alpha: 0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(['LUN', 'MAR', 'MER', 'JEU', 'VEN'][index], 
                    style: TextStyle(color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(date.day.toString(), 
                    style: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlotsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _weeklySchedule!.slots.length,
      itemBuilder: (context, index) {
        final slot = _weeklySchedule!.slots[index];
        return _buildScheduleCard(slot);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleSlot slot) {
    final bool isCancelled = slot.status == ScheduleSlotStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.red.withValues(alpha: 0.05) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCancelled ? Colors.red.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(slot.startTime, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Container(width: 2, height: 20, color: AppColors.onSurface.withValues(alpha: 0.1)),
              Text(slot.endTime, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subjectName, 
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  )
                ),
                Text(slot.teacherName, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(slot.room, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          if (isCancelled)
            const Badge(label: Text('ANNULÉ'), backgroundColor: Colors.red)
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('Aucun cours prévu pour cette période.'),
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
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('Emploi du Temps', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
