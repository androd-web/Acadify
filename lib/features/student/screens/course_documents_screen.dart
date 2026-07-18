import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/course_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/file_service.dart';

class CourseDocumentsScreen extends StatefulWidget {
  final CourseModel course;
  const CourseDocumentsScreen({super.key, required this.course});

  @override
  State<CourseDocumentsScreen> createState() => _CourseDocumentsScreenState();
}

class _CourseDocumentsScreenState extends State<CourseDocumentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FileService _fileService = FileService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];
  final Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _documents = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching documents: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDownload(Map<String, dynamic> doc) async {
    final String docId = doc['id'];
    final String url = doc['fileUrl'];
    final String fileName = "${doc['title']}.pdf";

    setState(() => _downloadProgress[docId] = 0.01);

    final path = await _fileService.downloadFile(
      url: url,
      fileName: fileName,
      docId: docId,
      onProgress: (p) => setState(() => _downloadProgress[docId] = p),
    );

    if (mounted) {
      setState(() => _downloadProgress.remove(docId));
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document téléchargé !')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Column(
          children: [
            Text(widget.course.name, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            Text('${_documents.length} documents disponibles', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final doc = _documents[index];
                          return _buildDocCard(context, doc);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppColors.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('Aucun document disponible pour cette matière.'),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, Map<String, dynamic> doc) {
    final String docId = doc['id'];
    final bool isOffline = _fileService.getLocalPath(docId) != null;
    final double? progress = _downloadProgress[docId];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['title'], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${doc['type']} • ${doc['fileSize']}', style: AppTextStyles.labelSmall),
                if (isOffline)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.offline_pin, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Disponible hors-ligne', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (progress != null)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(value: progress, strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(isOffline ? Icons.visibility : Icons.cloud_download_outlined, 
                   color: isOffline ? AppColors.primary : AppColors.onSurfaceVariant),
              onPressed: isOffline 
                ? () => context.push('/pdf-viewer', extra: doc)
                : () => _handleDownload(doc),
            ),
        ],
      ),
    );
  }
}


