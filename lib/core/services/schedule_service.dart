import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer l'emploi du temps d'une filière/niveau pour une semaine spécifique (ex: 2024-W42)
  Stream<ScheduleModel?> getWeeklySchedule({
    required String filiere,
    required String niveau,
    required String weekKey,
  }) {
    final docId = '${filiere.toLowerCase()}_${niveau.toLowerCase()}_$weekKey';
    return _firestore
        .collection('schedules')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ScheduleModel.fromMap(doc.data()!, weekKey);
    });
  }

  /// Mettre à jour le statut d'un créneau de cours (Annulé, Reporté, Normal)
  Future<bool> updateSlotStatus({
    required String filiere,
    required String niveau,
    required String weekKey,
    required int slotIndex,
    required ScheduleSlotStatus status,
    String? cancelReason,
  }) async {
    final docId = '${filiere.toLowerCase()}_${niveau.toLowerCase()}_$weekKey';
    try {
      final docRef = _firestore.collection('schedules').doc(docId);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data() != null) {
        List<dynamic> slots = docSnap.data()!['slots'] ?? [];
        if (slotIndex >= 0 && slotIndex < slots.length) {
          slots[slotIndex]['status'] = status.toString().split('.').last;
          if (cancelReason != null) {
            slots[slotIndex]['cancelReason'] = cancelReason;
          }
          await docRef.update({'slots': slots});
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
