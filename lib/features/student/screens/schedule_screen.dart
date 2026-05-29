import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 2; // Wednesday

  final List<Map<String, dynamic>> _days = [
    {'day': 'Lun', 'date': '15'},
    {'day': 'Mar', 'date': '16'},
    {'day': 'Mer', 'date': '17'},
    {'day': 'Jeu', 'date': '18'},
    {'day': 'Ven', 'date': '19'},
  ];

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildDaySelector(context),
                  const SizedBox(height: 32),
                  _buildTimetableList(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildBottomNavBar(context),
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
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
                onPressed: () {},
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Emploi du temps',
                    style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Consultez votre planning académique',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.calendar_month, color: colorScheme.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_days.length, (index) {
          final day = _days[index];
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minWidth: 64),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.05)),
                boxShadow: isSelected ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.15), blurRadius: 15)] : null,
              ),
              child: Column(
                children: [
                  Text(
                    day['day'],
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day['date'],
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimetableList(BuildContext context) {
    return Column(
      children: [
        _buildScheduleCard(context, '08:30 - 10:30', 'Algorithmique & Structure de Données', 'Dr. Bakari', 'Amphi A', true, false),
        const SizedBox(height: 16),
        _buildScheduleCard(context, '10:45 - 12:45', 'Réseaux Mobiles', 'Mme. Traoré', 'Salle 204', false, false),
        const SizedBox(height: 16),
        _buildScheduleCard(context, '14:00 - 16:00', 'Mathématiques Discrètes', 'Pr. Diallo', 'Labo Info 1', false, false),
        const SizedBox(height: 16),
        _buildScheduleCard(context, '16:15 - 18:15', 'Session d\'examen - Anglais', 'M. Smith', 'Grande Salle', false, true),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, String time, String subject, String teacher, String room, bool isOngoing, bool isExam) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    Color accentColor = isOngoing ? colorScheme.primary : (isExam ? const Color(0xFFE8A317) : colorScheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOngoing ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.05)),
        boxShadow: isOngoing ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.15), blurRadius: 20)] : null,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Text(time, style: theme.textTheme.labelMedium?.copyWith(color: accentColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (isOngoing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Maintenant', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontSize: 10)),
                      ),
                    if (isExam)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8A317).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Examen', style: TextStyle(color: Color(0xFFE8A317), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(subject, style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(context, Icons.person, teacher),
                    const SizedBox(width: 24),
                    _buildInfoItem(context, Icons.location_on, room),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.home, 'Home', false, () => context.go('/student-dashboard')),
            _buildBottomNavItem(context, Icons.menu_book, 'Courses', false, () => context.push('/courses')),
            _buildBottomNavItem(context, Icons.grade, 'Grades', false, () => context.push('/grades')),
            _buildBottomNavItem(context, Icons.calendar_today, 'Planning', true, () {}),
            _buildBottomNavItem(context, Icons.person, 'Profile', false, () => context.push('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isActive ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : null,
        decoration: isActive ? BoxDecoration(color: colorScheme.secondaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, size: 24),
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
