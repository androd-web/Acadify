import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/course_model.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Professeur';
  String? _specialite;
  bool _isLoading = true;
  bool _isPending = false;
  
  List<CourseModel> _myCourses = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadUserData();
    await _fetchTeacherStats();
    if (mounted) setState(() => _isLoading = false);
  }

  void _loadUserData() {
    var userBox = Hive.box('userBox');
    setState(() {
      _userName = userBox.get('name', defaultValue: 'Professeur');
      _specialite = userBox.get('filiere'); // On utilise filiere pour la spécialité
    });
  }

  Future<void> _fetchTeacherStats() async {
    var userBox = Hive.box('userBox');
    String? uid = userBox.get('uid');
    if (uid == null) return;

    try {
      // 1. Vérifier le statut du compte
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String status = userDoc.get('status') ?? 'active';
        _isPending = status == 'pending';
      }

      // 2. Récupérer les cours du prof
      var coursesSnapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: uid)
          .get();
      
      _myCourses = coursesSnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Pour chaque cours, on pourrait compter les documents dans la sous-collection
      // Pour simplifier on affiche juste le nombre de cours
    } catch (e) {
      debugPrint('Error fetching teacher stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (_isPending) _buildPendingAlert(context),
                    Text('Gérez vos activités académiques', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    _buildHeroCourseCard(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildCourseManagement(context),
                    const SizedBox(height: 32),
                    _buildStatistics(context),
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

                  Widget _buildPendingAlert(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compte en attente de validation par l\'administration.',
              style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    String firstName = _userName.split(' ').first;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  border: Border.all(color: colorScheme.primaryContainer, width: 2),
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'P',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bonjour, $firstName 👋',
                style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.notifications, color: colorScheme.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCourseCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Spécialité : ${_specialite ?? "Non définie"}',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
              const Icon(Icons.auto_stories, color: Colors.white54, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _myCourses.isNotEmpty ? _myCourses.first.name : 'Aucun cours assigné',
            style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildHeroInfoItem(Icons.class_, '${_myCourses.length} Matières'),
              _buildHeroInfoItem(Icons.assignment_ind, 'Enseignant Certifié'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions Rapides', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildActionCard(context, Icons.add_circle, 'Uploader un cours', () => context.push('/teacher-upload-course')),
            _buildActionCard(context, Icons.grading, 'Saisir les notes', () => context.push('/teacher-grade-entry')),
            _buildActionCard(context, Icons.how_to_reg, 'Faire l\'appel', () => context.push('/teacher-attendance')),
            _buildActionCard(context, Icons.calendar_month, 'Gérer l\'EDT', () => context.push('/teacher-schedule')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseManagement(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vos Matières', style: theme.textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/teacher-courses'),
              child: Text('Tout voir', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_myCourses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Aucune matière enregistrée pour le moment.'),
          )
        else
          ..._myCourses.take(2).map((course) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTeacherCourseCard(context, course.name, course.filiere, 'S${course.semester}', colorScheme.primary),
          )),
      ],
    );
  }

  Widget _buildTeacherCourseCard(BuildContext context, String title, String dept, String semester, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('$dept - Semestre $semester', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatBox(context, 'Matières', '${_myCourses.length}', colorScheme.primary),
              const SizedBox(width: 12),
              _buildStatBox(context, 'En attente', '0', colorScheme.primary, subtitle: 'évaluations'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, Color color, {String? subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
