import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _studentCount = 0;
  int _teacherCount = 0;
  int _announcementCount = 0;
  int _courseCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      // Récupération dynamique des données depuis Firestore
      final studentsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
          
      final teachersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();

      final announcementsQuery = await _firestore
          .collection('announcements')
          .get();

      final coursesQuery = await _firestore
          .collection('courses')
          .get();

      if (mounted) {
        setState(() {
          _studentCount = studentsQuery.docs.length;
          _teacherCount = teachersQuery.docs.length;
          _announcementCount = announcementsQuery.docs.length;
          _courseCount = coursesQuery.docs.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des stats: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            child: RefreshIndicator(
              onRefresh: _fetchStats,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: 24),
                    _buildKPIStats(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildSystemHealth(context),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                    const SizedBox(height: 120), // Espace pour la barre de navigation
                  ],
                ),
              ),
            ),
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Icon(Icons.menu, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acadify UIECC',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: colorScheme.primary, 
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDf1JxLqy0RD6QMsoeVR2c45nAwlbXO2AUXHBmvBSVyt46DMOCaNRzc4ltRZVKmcxFnr3YuUgHLy4apf5RIoZ_YmfKIgXcbJZprSwgYbJCRw-YcCYQLPoNUSQM6Rf1fHUnJh1I1rYk7ghmUcWfRrmGvPvqTCHZ1nBu9oGlbTiElqBLMrVl-4ms9wtaEpqT_Yvz8cpnNS4PNXNikFwaWIC9lBKtGb7djbMJYwAtsdGkRfyyIq8cPTQoBRGIR1faM8xpPDvkRTG5lSlhH'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Administrateur',
                style: TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              'Lundi 26 Mai 2026',
              style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tableau de bord — UIECC',
          style: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface, fontSize: 26),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, color: colorScheme.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              'Administration · Sangmélima',
              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45, // Ratio augmenté pour éviter les overflows verticaux
      children: [
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_studentCount', 
          'Étudiants actifs', 
          Icons.group, 
          colorScheme.secondary, 
          _isLoading ? '' : 'Live'
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_teacherCount', 
          'Enseignants', 
          Icons.school, 
          const Color(0xFFFFB300), 
          _isLoading ? '' : 'Live'
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_announcementCount', 
          'Communiqués', 
          Icons.campaign, 
          colorScheme.primary, 
          _isLoading ? '' : 'Total'
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_courseCount', 
          'Cours créés', 
          Icons.folder_open, 
          const Color(0xFFFFB300), 
          _isLoading ? '' : 'Total'
        ),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String value, String label, IconData icon, Color color, String trend) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Évite l'utilisation de Spacer() risqué
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trend.isNotEmpty)
                Text(
                  trend, 
                  style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10)
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value, 
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 24, color: colorScheme.onSurface, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Text(
                    label, 
                    style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actions rapides', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 18)),
            Text('Tout voir', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFFFB300))),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6, // Ratio augmenté pour éviter les overflows
          children: [
            _buildActionItem(context, Icons.post_add, 'Nouveau communiqué', colorScheme.primary, () => context.push('/admin-compose-announcement')),
            _buildActionItem(context, Icons.person_add, 'Ajouter utilisateur', colorScheme.secondary, () {}),
            _buildActionItem(context, Icons.manage_accounts, 'Gérer communiqués', const Color(0xFFFFB300), () => context.push('/admin-announcements')),
            _buildActionItem(context, Icons.group_work, 'Gérer utilisateurs', colorScheme.onSurfaceVariant, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label, 
                style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface, fontSize: 12), 
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: colorScheme.secondary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text('État du système', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthRow(context, 'Firebase connection', 'Connecté', true),
          _buildHealthRow(context, 'Notifications FCM', 'Opérationnel', true),
          _buildHealthRow(context, 'Dernière synchro', 'il y a 4 min', null),
          const SizedBox(height: 12),
          Text('Storage usage (234 Mo / 1 Go)', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface, fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.23,
              backgroundColor: colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, String status, bool? isPositive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          Row(
            children: [
              if (isPositive != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: isPositive ? colorScheme.secondary : colorScheme.error, shape: BoxShape.circle),
                ),
              Text(
                status, 
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: isPositive == true ? colorScheme.secondary : colorScheme.onSurface,
                  fontSize: 12
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité récente', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildActivityItem(context, Icons.upload, 'Dr. Mbida a uploadé Intro_Informatique_v2.pdf', 'Il y a 1h', colorScheme.primary),
              _buildActivityItem(context, Icons.campaign, 'Communiqué : Suspension des cours pour l\'Ascension', 'Il y a 3h', const Color(0xFFFFB300)),
              _buildActivityItem(context, Icons.person_add, 'Nouveau compte étudiant créé : Jean-Marc Biyong', 'Hier', colorScheme.secondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String text, String time, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
