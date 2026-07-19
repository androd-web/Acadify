import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/absence_model.dart';

class AbsenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer toutes les absences d'un étudiant
  Stream<List<AbsenceModel>> getStudentAbsences(String studentUid) {
    return _firestore
        .collection('users')
        .doc(studentUid)
        .collection('absences')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AbsenceModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Enregistrer une nouvelle absence pour un étudiant dans une matière
  Future<bool> recordAbsence({
    required String studentUid,
    required String subjectId,
    required String subjectName,
    required DateTime date,
    int maxAllowed = 5,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(studentUid)
          .collection('absences')
          .doc(subjectId);

      final docSnap = await docRef.get();

      if (docSnap.exists) {
        // Ajouter la nouvelle date à la liste existante
        await docRef.update({
          'records': FieldValue.arrayUnion([Timestamp.fromDate(date)]),
          'total': FieldValue.increment(1),
        });
      } else {
        // Créer le document d'absence s'il n'existe pas encore
        await docRef.set({
          'subjectName': subjectName,
          'maxAllowed': maxAllowed,
          'total': 1,
          'records': [Timestamp.fromDate(date)],
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
