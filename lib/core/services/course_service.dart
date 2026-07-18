import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../models/grade_model.dart';

import 'package:flutter/foundation.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploader un document pour un cours spécifique
  Future<bool> uploadDocument({
    required String courseId,
    required String title,
    required DocumentType type,
    required File file,
    required String teacherName,
    required String teacherId,
  }) async {
    try {
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      final Reference ref = _storage.ref().child('courses').child(courseId).child(fileName);

      // 1. Upload vers Storage
      final UploadTask task = ref.putFile(file);
      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      final int fileSize = await file.length();

      // 2. Créer le document dans Firestore
      final DocumentReference docRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('documents')
          .doc();

      final CourseDocumentModel newDoc = CourseDocumentModel(
        id: docRef.id,
        title: title,
        type: type,
        fileUrl: downloadUrl,
        fileSize: fileSize,
        uploadedAt: DateTime.now(),
        uploadedBy: teacherName,
      );

      await docRef.set(newDoc.toMap());

      // 3. Mettre à jour la date de modification du cours
      await _firestore.collection('courses').doc(courseId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint("Error uploading document: $e");
      return false;
    }
  }

  /// Récupérer les cours assignés à un enseignant
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching teacher courses: $e");
      return [];
    }
  }

  /// Récupérer les étudiants d'une filière et d'un niveau spécifique
  Future<List<UserModel>> getStudentsForCourse(String filiere, String niveau) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('filiere', isEqualTo: filiere)
          .where('niveau', isEqualTo: niveau)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching students: $e");
      return [];
    }
  }

  /// Publier les notes pour un groupe d'étudiants (Batch Write)
  Future<bool> publishGrades({
    required String courseId,
    required String subjectName,
    required String teacherName,
    required double maxScore,
    required int semester,
    required EvaluationType evaluation,
    required Map<String, double> studentGrades, // studentUid -> score
  }) async {
    final WriteBatch batch = _firestore.batch();
    final DateTime now = DateTime.now();

    try {
      studentGrades.forEach((studentUid, score) {
        final DocumentReference gradeRef = _firestore
            .collection('grades')
            .doc(studentUid)
            .collection('subjects')
            .doc(courseId);

        final GradeModel grade = GradeModel(
          subjectId: courseId,
          subjectName: subjectName,
          teacherName: teacherName,
          score: score,
          maxScore: maxScore,
          coefficient: 1, // Par défaut
          publishedAt: now,
          semester: semester,
          evaluation: evaluation,
        );

        batch.set(gradeRef, grade.toMap());
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint("Error publishing grades: $e");
      return false;
    }
  }

  /// Enregistrer l'appel (Batch Write)
  Future<bool> recordAttendance({
    required String courseId,
    required String subjectName,
    required List<String> absentStudentUids,
  }) async {
    final WriteBatch batch = _firestore.batch();
    final DateTime now = DateTime.now();

    try {
      for (String uid in absentStudentUids) {
        final DocumentReference docRef = _firestore
            .collection('absences')
            .doc(uid)
            .collection('subjects')
            .doc(courseId);

        batch.set(docRef, {
          'subjectName': subjectName,
          'records': FieldValue.arrayUnion([Timestamp.fromDate(now)]),
          'total': FieldValue.increment(1),
          'maxAllowed': 10, // Valeur par défaut
        }, SetOptions(merge: true));
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint("Error recording attendance: $e");
      return false;
    }
  }
}
