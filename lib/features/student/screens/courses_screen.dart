import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/course_model.dart';
import '../../../core/theme/app_colors.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _offlineBox = Hive.box('offlineBox');
  final Box _userBox = Hive.box('userBox');

  int _selectedSemester = 1; // 1 ou 2
  bool _isLoading = true;
  List<CourseModel> _allCourses = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCachedCourses();
    _fetchCourses();
  }

  void _loadCachedCourses() {
    final cached = _offlineBox.get('courses_list_s$_selectedSemester');
    if (cached != null) {
      setState(() {
        _allCourses = (cached as List)
            .map((e) => CourseModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCourses() async {
    final String? filiere = _userBox.get('filiere');
    if (filiere == null) return;

    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('filiere', isEqualTo: filiere)
          .where('semester', isEqualTo: _selectedSemester)
          .get();

      final courses = snapshot.docs.map((doc) => CourseModel.fromMap(doc.data(), doc.id)).toList();
      
      if (mounted) {
        setState(() {
          _allCourses = courses;
          _isLoading = false;
        });
      }

      // Cache pour le mode offline
      _offlineBox.put('courses_list_s$_selectedSemester', courses.map((e) => e.toMap()..['id'] = e.id).toList());
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CourseModel> get _filteredCourses {
    if (_searchQuery.isEmpty) return _allCourses;
    return _allCourses.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
            child: RefreshIndicator(
              onRefresh: _fetchCourses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildSearchBar(context),
                    const SizedBox(height: 20),
                    _buildSemesterSelector(context),
                    const SizedBox(height: 24),
                    if (_isLoading && _allCourses.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredCourses.isEmpty)
                      _buildEmptyState()
                    else
                      _buildCourseList(context),
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

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.search_off, size: 64, color: AppColors.onSurface.withValues(alpha: 0.1)),
        const SizedBox(height: 16),
        Text('Aucune matière trouvée', style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.5))),
      ],
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
                  const SizedBox(width: 48), // Spacer pour l'équilibre
                ],
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
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
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
          _buildSemesterButton(context, 'Semestre 1', _selectedSemester == 1, () {
            setState(() {
              _selectedSemester = 1;
              _isLoading = true;
            });
            _loadCachedCourses();
            _fetchCourses();
          }),
          _buildSemesterButton(context, 'Semestre 2', _selectedSemester == 2, () {
            setState(() {
              _selectedSemester = 2;
              _isLoading = true;
            });
            _loadCachedCourses();
            _fetchCourses();
          }),
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
      children: _filteredCourses.map((course) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCourseCard(context, course),
        );
      }).toList(),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Déterminer une icône basée sur le nom (très simplifié)
    IconData icon = Icons.book;
    if (course.name.toLowerCase().contains('math')) icon = Icons.functions;
    if (course.name.toLowerCase().contains('réseau')) icon = Icons.router;
    if (course.name.toLowerCase().contains('algo')) icon = Icons.code;

    return GestureDetector(
      onTap: () => context.push('/course-documents', extra: course),
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
                  ),
                  child: Icon(icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18, height: 1.2)),
                      const SizedBox(height: 4),
                      Text('Prof: ${course.teacherName}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
                    Text('Voir les documents', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

