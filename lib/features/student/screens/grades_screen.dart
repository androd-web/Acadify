import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _selectedSemester = 0;

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
                  _buildSemesterSelector(context),
                  const SizedBox(height: 24),
                  _buildGPAHeroCard(context),
                  const SizedBox(height: 24),
                  _buildAnalyticsGrid(context),
                  const SizedBox(height: 32),
                  Text('Détails des modules', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  _buildGradesList(context),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mes Notes',
                    style: theme.textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
                  ),
                  Text(
                    'Suivez vos performances académiques',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              _buildIconButton(context, Icons.download),
              const SizedBox(width: 8),
              _buildIconButton(context, Icons.notifications, hasBadge: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, {bool hasBadge = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, shape: BoxShape.circle),
          child: Icon(icon, color: colorScheme.onSurface, size: 20),
        ),
        if (hasBadge)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSemesterSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _buildSemesterButton(context, 'Semestre 1', _selectedSemester == 0, () => setState(() => _selectedSemester = 0)),
          _buildSemesterButton(context, 'Semestre 2', _selectedSemester == 1, () => setState(() => _selectedSemester = 1)),
        ],
      ),
    );
  }

  Widget _buildSemesterButton(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPAHeroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Moyenne Générale', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Validé', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('15.84', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 40, color: Colors.white)),
                      const SizedBox(width: 4),
                      Text('/20', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('+0.42 pt. depuis S1', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                    ],
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: 0.8,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const Text('80%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.emoji_events, size: 18, color: Color(0xFFE8A317)),
              SizedBox(width: 8),
              Text(
                'Excellent travail, continuez ainsi !',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: _buildMiniStatCard(context, Icons.star, 'Meilleure Matière', 'Mathématiques', colorScheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniStatCard(context, Icons.analytics, 'Progression', '+12%', colorScheme.secondaryContainer)),
      ],
    );
  }

  Widget _buildMiniStatCard(BuildContext context, IconData icon, String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildGradesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildGradeCard(context, 'Algorithmique & Structure de Données', '4', 16.5, 'Excellent', colorScheme.primary),
        const SizedBox(height: 12),
        _buildGradeCard(context, 'Réseaux Mobiles', '3', 14.2, 'Validé', colorScheme.secondary),
        const SizedBox(height: 12),
        _buildGradeCard(context, 'Mathématiques Discrètes', '3', 17.0, 'Excellent', colorScheme.primary),
      ],
    );
  }

  Widget _buildGradeCard(BuildContext context, String title, String coeff, double grade, String status, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
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
                    Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Coeff: $coeff', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$grade', style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: grade / 20,
              minHeight: 6,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
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
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.home, 'Accueil', false, () => context.go('/student-dashboard')),
            _buildBottomNavItem(context, Icons.menu_book, 'Cours', false, () => context.push('/courses')),
            _buildBottomNavItem(context, Icons.grade, 'Notes', true, () {}),
            _buildBottomNavItem(context, Icons.calendar_month, 'Planning', false, () => context.push('/schedule')),
            _buildBottomNavItem(context, Icons.person, 'Profil', false, () => context.push('/profile')),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 4),
                  Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                ],
              ),
            )
          else
            Column(
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.labelMedium),
              ],
            ),
        ],
      ),
    );
  }
}
