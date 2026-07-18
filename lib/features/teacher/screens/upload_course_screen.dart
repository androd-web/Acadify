import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/course_service.dart';
import '../../../core/models/course_model.dart';

class UploadCourseScreen extends StatefulWidget {
  const UploadCourseScreen({super.key});

  @override
  State<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends State<UploadCourseScreen> {
  final CourseService _courseService = CourseService();
  final TextEditingController _titleController = TextEditingController();
  final Box _userBox = Hive.box('userBox');

  String _selectedType = 'Cours';
  final List<String> _types = ['Cours', 'TD', 'TP', 'Examen', 'Autre'];
  
  List<CourseModel> _courses = [];
  String? _selectedCourseId;
  File? _selectedFile;
  bool _isLoadingCourses = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final String? uid = _userBox.get('uid');
    if (uid != null) {
      final courses = await _courseService.getTeacherCourses(uid);
      if (mounted) {
        setState(() {
          _courses = courses;
          if (_courses.isNotEmpty) _selectedCourseId = _courses.first.id;
          _isLoadingCourses = false;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedCourseId == null || _selectedFile == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner un fichier.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final success = await _courseService.uploadDocument(
      courseId: _selectedCourseId!,
      title: _titleController.text.trim(),
      type: _getDocumentType(_selectedType),
      file: _selectedFile!,
      teacherId: _userBox.get('uid'),
      teacherName: _userBox.get('name'),
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document publié avec succès !')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la publication.')),
        );
      }
    }
  }

  DocumentType _getDocumentType(String type) {
    switch (type) {
      case 'TD': return DocumentType.td;
      case 'TP': return DocumentType.tp;
      case 'Examen': return DocumentType.examen;
      default: return DocumentType.cours;
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uploader un cours', style: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Partagez vos ressources pédagogiques avec vos étudiants', style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  if (_isLoadingCourses)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildForm(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          _buildBottomAction(context),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String? photoUrl = _userBox.get('photoUrl');

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
                  image: photoUrl != null
                      ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                      : null,
                  color: colorScheme.surfaceContainerHigh,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: photoUrl == null
                    ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 12),
              Text('Acadify LMS', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, 'Matière'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourseId,
              isExpanded: true,
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
              items: _courses.map((course) => DropdownMenuItem(value: course.id, child: Text(course.name))).toList(),
              onChanged: (v) => setState(() => _selectedCourseId = v),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel(context, 'Type de document'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((type) {
            final bool isActive = _selectedType == type;
            return InkWell(
              onTap: () => setState(() => _selectedType = type),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? Colors.transparent : colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Text(type, style: AppTextStyles.labelMedium.copyWith(color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildLabel(context, 'Titre du document'), Text('${_titleController.text.length} / 80', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant))],
        ),
        TextField(
          controller: _titleController,
          onChanged: (v) => setState(() {}),
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Entrez le titre du support...',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel(context, 'Fichier'),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1), style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 48,
                  color: _selectedFile != null ? Colors.green : colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedFile != null ? _selectedFile!.path.split('/').last : 'Appuyez pour sélectionner un fichier',
                  style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                Text('(PDF or DOCX · Max 20 Mo)', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1))
          ),
          child: Row(
            children: [
              Icon(Icons.description, color: colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guide de publication', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface)),
                    Text('Assurez-vous que le document est lisible.', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isUploading ? null : _handleUpload,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.publish),
              const SizedBox(width: 8),
              Text('Publier le document', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: colorScheme.onPrimary)),
            ],
          ),
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
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', false, () => context.go('/teacher-dashboard')),
            _buildNavItem(context, Icons.menu_book, 'Courses', true, () => context.go('/teacher-courses')),
            _buildNavItem(context, Icons.grade_outlined, 'Grades', false, () => context.push('/teacher-grade-entry')),
            _buildNavItem(context, Icons.person_outline, 'Profile', false, () => context.push('/teacher-profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
          Text(label, style: TextStyle(color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}
