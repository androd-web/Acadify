import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/file_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final Map<String, dynamic> doc;
  const PdfViewerScreen({super.key, required this.doc});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final FileService _fileService = FileService();
  String? _localPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    final path = _fileService.getLocalPath(widget.doc['id']);
    if (path != null && await File(path).exists()) {
      setState(() {
        _localPath = path;
        _isLoading = false;
      });
    } else {
      // Pour la Phase 1, on force le téléchargement avant lecture
      // ou on utilise un viewer réseau. Ici on va informer l'utilisateur.
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101412),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.doc['title'] ?? 'Document',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath != null
              ? Stack(
                  children: [
                    PDFView(
                      filePath: _localPath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      onRender: (pages) => setState(() {
                        _totalPages = pages!;
                        _isReady = true;
                      }),
                      onViewCreated: (PDFViewController controller) {},
                      onPageChanged: (page, total) => setState(() => _currentPage = page!),
                    ),
                    if (!_isReady) const Center(child: CircularProgressIndicator()),
                    _buildPageIndicator(),
                  ],
                )
              : _buildNotDownloadedState(),
    );
  }

  Widget _buildNotDownloadedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text('Veuillez télécharger le document pour le lire.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Retour aux documents'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Text('Page ${_currentPage + 1} sur $_totalPages', style: AppTextStyles.labelSmall),
        ),
      ),
    );
  }
}

