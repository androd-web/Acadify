import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade_model.dart';

class GradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer les notes d'un étudiant pour un semestre donné
  Stream<List<GradeModel>> getStudentGrades({
    required String studentUid,
    required int semester,
  }) {
    return _firestore
        .collection('users')
        .doc(studentUid)
        .collection('grades')
        .where('semester', isEqualTo: semester)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GradeModel.fromMap(doc.data(), doc.id);
      }).toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    });
  }

  /// Récupérer toutes les notes saisies par un enseignant spécifique (via collectionGroup)
  Stream<List<GradeModel>> getGradesByTeacher({required String teacherName}) {
    return _firestore
        .collectionGroup('grades')
        .where('teacherName', isEqualTo: teacherName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GradeModel.fromMap(doc.data(), doc.id);
      }).toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    });
  }

  /// Publier ou mettre à jour la note d'un étudiant (Enseignant)
  Future<bool> publishGrade({
    required String studentUid,
    required String subjectId,
    required String subjectName,
    required String teacherName,
    required double score,
    required double maxScore,
    required int coefficient,
    required int semester,
    String? comment,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentUid)
          .collection('grades')
          .doc(subjectId)
          .set({
        'subjectName': subjectName,
        'teacherName': teacherName,
        'score': score,
        'maxScore': maxScore,
        'coefficient': coefficient,
        'semester': semester,
        'comment': comment,
        'publishedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }
}
