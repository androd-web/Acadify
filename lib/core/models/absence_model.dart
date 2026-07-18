import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenceModel {
  final String subjectId;
  final String subjectName;
  final int total;
  final int maxAllowed;
  final List<DateTime> records;

  AbsenceModel({
    required this.subjectId,
    required this.subjectName,
    required this.total,
    required this.maxAllowed,
    required this.records,
  });

  factory AbsenceModel.fromMap(Map<String, dynamic> map, String subjectId) {
    return AbsenceModel(
      subjectId: subjectId,
      subjectName: map['subjectName'] ?? '',
      total: map['total'] ?? 0,
      maxAllowed: map['maxAllowed'] ?? 5,
      records: (map['records'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'total': total,
      'maxAllowed': maxAllowed,
      'records': records.map((e) => Timestamp.fromDate(e)).toList(),
    };
  }
}
