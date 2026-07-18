import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final String filiere;
  final String niveau;
  final int semester;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.filiere,
    required this.niveau,
    required this.semester,
    required this.updatedAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CourseModel(
      id: documentId,
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      filiere: map['filiere'] ?? '',
      niveau: map['niveau'] ?? '',
      semester: map['semester'] ?? 1,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'filiere': filiere,
      'niveau': niveau,
      'semester': semester,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

enum DocumentType { cours, td, tp, examen }

class CourseDocumentModel {
  final String id;
  final String title;
  final DocumentType type;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;
  final String uploadedBy;

  CourseDocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory CourseDocumentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CourseDocumentModel(
      id: documentId,
      title: map['title'] ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => DocumentType.cours,
      ),
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      uploadedBy: map['uploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.toString().split('.').last,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
    };
  }
}
