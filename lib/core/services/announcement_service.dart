import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer les communiqués pour un étudiant spécifique (selon sa filière et son niveau)
  Stream<List<AnnouncementModel>> getAnnouncementsForStudent({
    required String filiere,
    required String niveau,
  }) {
    return _firestore
        .collection('announcements')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) {
      final allAnnouncements = snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(doc.data(), doc.id);
      }).toList();

      // Filtrer localement pour correspondre au groupe cible
      return allAnnouncements.where((announcement) {
        final target = announcement.targetGroup.toLowerCase();
        if (target == 'all') return true;
        if (target == filiere.toLowerCase()) return true;
        if (target == '${filiere.toLowerCase()}_${niveau.toLowerCase()}') return true;
        return false;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Créer un nouveau communiqué (Admin ou Enseignant autorisé)
  Future<bool> createAnnouncement({
    required String title,
    required String body,
    required AnnouncementCategory category,
    required String targetGroup,
    String? attachmentUrl,
    required String authorUid,
    required String authorName,
  }) async {
    try {
      await _firestore.collection('announcements').add({
        'title': title,
        'body': body,
        'category': category.toString().split('.').last,
        'targetGroup': targetGroup,
        'attachmentUrl': attachmentUrl,
        'authorUid': authorUid,
        'authorName': authorName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'published',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Archiver un communiqué
  Future<bool> archiveAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).update({
        'status': 'archived',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
