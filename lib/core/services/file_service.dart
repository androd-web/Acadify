import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final Dio _dio = Dio();
  final Box _offlineBox = Hive.box('offlineBox');

  /// Télécharge un fichier et le sauvegarde localement
  Future<String?> downloadFile({
    required String url,
    required String fileName,
    required String docId,
    Function(double)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String savePath = '${dir.path}/$fileName';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // Mémoriser le chemin local dans Hive
      await _offlineBox.put('local_path_$docId', savePath);
      return savePath;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  /// Vérifie si un document est disponible offline
  String? getLocalPath(String docId) {
    return _offlineBox.get('local_path_$docId');
  }

  /// Supprime un fichier local
  Future<void> deleteFile(String docId) async {
    final String? path = getLocalPath(docId);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await _offlineBox.delete('local_path_$docId');
    }
  }
}
