import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
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
                children: [
                  const SizedBox(height: 12),
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  _buildSemesterSelector(context),
                  const SizedBox(height: 24),
                  _buildCourseList(context),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Bibliothèque de cours',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: colorScheme.onSurface),
                    onPressed: () {},
                  ),
                ],
              ),
              Text(
                'Accédez à vos ressources académiques',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: TextField(
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Rechercher une matière',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSemesterSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
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
            color: isActive ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: colorScheme.primaryContainer.withValues(alpha: 0.3), blurRadius: 10)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    return Column(
      children: [
        _buildCourseCard(
          context,
          Icons.code,
          'Algorithmique &\nStructure de Données',
          'Dr. Bakari',
          '12 documents',
          isOffline: true,
          isUpdated: true,
        ),
        const SizedBox(height: 16),
        _buildCourseCard(
          context,
          Icons.router,
          'Réseaux Mobiles &\nSécurité',
          'Mme. Diallo',
          '8 documents',
          isNew: true,
        ),
        const SizedBox(height: 16),
        _buildCourseCard(
          context,
          Icons.functions,
          'Mathématiques\nDiscrètes',
          'M. Touré',
          '15 documents',
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    IconData icon,
    String title,
    String prof,
    String docs, {
    bool isOffline = false,
    bool isUpdated = false,
    bool isNew = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () => context.push('/course-documents'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18, height: 1.2)),
                      const SizedBox(height: 4),
                      Text('Prof: $prof', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(docs, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                Row(
                  children: [
                    if (isOffline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_done, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Offline', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (isUpdated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: colorScheme.secondaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('Mis à jour', style: TextStyle(color: colorScheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE8A317).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Nouveau', style: TextStyle(color: Color(0xFFE8A317), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    if (!isOffline && !isUpdated && !isNew)
                      Icon(Icons.cloud_download, size: 20, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ],
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
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.home, 'Accueil', false, () => context.go('/student-dashboard')),
            _buildBottomNavItem(context, Icons.menu_book, 'Cours', true, () {}),
            _buildBottomNavItem(context, Icons.grade, 'Notes', false, () => context.push('/grades')),
            _buildBottomNavItem(context, Icons.calendar_month, 'Planning', false, () => context.push('/schedule')),
            _buildBottomNavItem(context, Icons.person, 'Profil', false, () => context.push('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
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
