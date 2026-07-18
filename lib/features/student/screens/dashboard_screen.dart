import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/models/grade_model.dart';
import '../../../core/models/schedule_model.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _offlineBox = Hive.box('offlineBox');
  
  String _userName = 'Étudiant';
  String? _filiere;
  bool _isLoading = true;

  List<AnnouncementModel> _recentAnnouncements = [];
  List<GradeModel> _recentGrades = [];
  ScheduleSlot? _nextCourse;
  
  StreamSubscription? _announcementsSub;
  StreamSubscription? _gradesSub;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCachedData();
    _initRealtimeListeners();
  }

  @override
  void dispose() {
    _announcementsSub?.cancel();
    _gradesSub?.cancel();
    super.dispose();
  }

  void _loadUserData() {
    var userBox = Hive.box('userBox');
    setState(() {
      _userName = userBox.get('name', defaultValue: 'Étudiant');
      _filiere = userBox.get('filiere');
    });
  }

  void _loadCachedData() {
    // Charger les données depuis Hive pour un affichage immédiat (Offline-first)
    final cachedAnnouncements = _offlineBox.get('recent_announcements');
    final cachedGrades = _offlineBox.get('recent_grades');
    final cachedNextCourse = _offlineBox.get('next_course');

    setState(() {
      if (cachedAnnouncements != null) {
        _recentAnnouncements = (cachedAnnouncements as List)
            .map((e) => AnnouncementModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
      }
      if (cachedGrades != null) {
        _recentGrades = (cachedGrades as List)
            .map((e) => GradeModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
      }
      if (cachedNextCourse != null) {
        _nextCourse = ScheduleSlot.fromMap(Map<String, dynamic>.from(cachedNextCourse));
      }
      _isLoading = false;
    });
  }

  void _initRealtimeListeners() {
    // 1. Listen for Announcements
    _announcementsSub = _firestore
        .collection('announcements')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .snapshots()
        .listen((snapshot) {
      final news = snapshot.docs.map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id)).toList();
      setState(() => _recentAnnouncements = news);
      // Cache to Hive
      _offlineBox.put('recent_announcements', news.map((e) => e.toMap()..['id'] = e.id).toList());
    });

    // 2. Listen for Grades
    var userBox = Hive.box('userBox');
    String? uid = userBox.get('uid');
    if (uid != null) {
      _gradesSub = _firestore
          .collection('grades')
          .doc(uid)
          .collection('subjects')
          .orderBy('publishedAt', descending: true)
          .limit(2)
          .snapshots()
          .listen((snapshot) {
        final grades = snapshot.docs.map((doc) => GradeModel.fromMap(doc.data(), doc.id)).toList();
        setState(() => _recentGrades = grades);
        // Cache to Hive
        _offlineBox.put('recent_grades', grades.map((e) => e.toMap()..['id'] = e.id).toList());
      });
    }

    // 3. Fetch Next Course
    _fetchNextCourse();
  }

  Future<void> _fetchNextCourse() async {
    if (_filiere == null) return;
    
    try {
      final now = DateTime.now();
      // Logique simplifiée pour trouver la semaine actuelle
      var snapshot = await _firestore
          .collection('schedule')
          .doc(_filiere)
          .collection('weeks')
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        var weekData = snapshot.docs.first.data();
        var schedule = ScheduleModel.fromMap(weekData, snapshot.docs.first.id);
        
        // Trouver le prochain cours
        final currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        ScheduleSlot? found;
        for (var slot in schedule.slots) {
          if (slot.startTime.compareTo(currentTime) > 0) {
            found = slot;
            break;
          }
        }

        if (found != null) {
          setState(() => _nextCourse = found);
          _offlineBox.put('next_course', found.toMap());
        }
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _fetchNextCourse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            _buildAppBar(context),
            Positioned.fill(
              top: 100,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildNextCourseHero(context),
                    const SizedBox(height: 24),
                    _buildAbsenceAlert(context),
                    const SizedBox(height: 32),
                    _buildTwoColumnGrid(context),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userBox = Hive.box('userBox');
    final String? photoUrl = userBox.get('photoUrl');
    // Extraire le prénom pour la salutation
    String firstName = _userName.split(' ').first;

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                  image: photoUrl != null
                      ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: photoUrl == null
                    ? Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bonjour, $firstName 👋',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Content de vous revoir !',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextCourseHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return _buildLoadingHero();
    }

    if (_nextCourse == null) {
      return _buildNoCourseHero(context);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.surfaceContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.15),
            blurRadius: 40,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('PROCHAIN COURS', style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.9), letterSpacing: 1)),
              ),
              const Icon(Icons.schedule, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nextCourse!.subjectName,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(_nextCourse!.teacherName, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(_nextCourse!.room, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(width: 1, height: 16, color: Colors.white24),
                const SizedBox(width: 16),
                Text('${_nextCourse!.startTime} - ${_nextCourse!.endTime}', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHero() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoCourseHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_available, size: 48, color: AppColors.primaryContainer),
          const SizedBox(height: 16),
          Text('Aucun cours prévu', style: AppTextStyles.headlineMedium),
          Text('Profitez de votre temps libre !', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAbsenceAlert(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Absences du jour', style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                Text('0 absences enregistrées', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/absences'),
            child: Text('DÉTAILS', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.primary, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnGrid(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, Icons.campaign, 'Derniers communiqués'),
        const SizedBox(height: 12),
        if (_isLoading)
          const LinearProgressIndicator()
        else if (_recentAnnouncements.isEmpty)
          const Text('Aucun communiqué récent')
        else
          ..._recentAnnouncements.map((ann) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAnnouncementCard(
              context, 
              ann.category.toString().split('.').last, 
              ann.title, 
              '${ann.createdAt.day}/${ann.createdAt.month}', 
              _getCategoryColor(ann.category).withValues(alpha: 0.2), 
              _getCategoryColor(ann.category)
            ),
          )),
        const SizedBox(height: 32),
        _buildSectionHeader(context, Icons.school, 'Mes notes récentes'),
        const SizedBox(height: 12),
        if (_isLoading)
          const LinearProgressIndicator()
        else if (_recentGrades.isEmpty)
          const Text('Aucune note enregistrée')
        else
          ..._recentGrades.map((grade) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecentGradeCard(
              context, 
              grade.subjectName, 
              '${grade.score}/${grade.maxScore}', 
              grade.score / grade.maxScore, 
              _getGradeColor(grade.score / grade.maxScore)
            ),
          )),
      ],
    );
  }

  Color _getCategoryColor(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.urgent: return Colors.red;
      case AnnouncementCategory.info: return Colors.blue;
      case AnnouncementCategory.general: return Colors.green;
    }
  }

  Color _getGradeColor(double ratio) {
    if (ratio >= 0.6) return Colors.green;
    if (ratio >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, String tag, String title, String time, Color tagBg, Color tagText) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(20)),
                child: Text(tag.toUpperCase(), style: TextStyle(color: tagText, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              Text(time, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentGradeCard(BuildContext context, String title, String grade, double progress, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(grade, style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.verified, size: 14, color: color),
              const SizedBox(width: 4),
              Text('Validé', style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
