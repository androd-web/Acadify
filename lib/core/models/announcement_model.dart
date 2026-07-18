import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementCategory { urgent, info, general }

enum AnnouncementStatus { published, archived }

class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final AnnouncementCategory category;
  final String targetGroup; // all, filiere_name, niveau
  final String? attachmentUrl;
  final String authorUid;
  final String authorName;
  final DateTime createdAt;
  final AnnouncementStatus status;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetGroup,
    this.attachmentUrl,
    required this.authorUid,
    required this.authorName,
    required this.createdAt,
    this.status = AnnouncementStatus.published,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AnnouncementModel(
      id: documentId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: AnnouncementCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => AnnouncementCategory.info,
      ),
      targetGroup: map['targetGroup'] ?? 'all',
      attachmentUrl: map['attachmentUrl'],
      authorUid: map['authorUid'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: AnnouncementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AnnouncementStatus.published,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'category': category.toString().split('.').last,
      'targetGroup': targetGroup,
      'attachmentUrl': attachmentUrl,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
    };
  }
}
