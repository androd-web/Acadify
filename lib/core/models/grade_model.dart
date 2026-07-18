import 'package:cloud_firestore/cloud_firestore.dart';

enum EvaluationType { partiel1, ds, finalExam }

class GradeModel {
  final String subjectId;
  final String subjectName;
  final String teacherName;
  final double score;
  final double maxScore;
  final int coefficient;
  final String? comment;
  final DateTime publishedAt;
  final int semester;
  final EvaluationType evaluation;

  String get id => subjectId;

  GradeModel({
    required this.subjectId,
    required this.subjectName,
    required this.teacherName,
    required this.score,
    required this.maxScore,
    required this.coefficient,
    this.comment,
    required this.publishedAt,
    required this.semester,
    required this.evaluation,
  });

  factory GradeModel.fromMap(Map<String, dynamic> map, String subjectId) {
    return GradeModel(
      subjectId: subjectId,
      subjectName: map['subjectName'] ?? '',
      teacherName: map['teacherName'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['maxScore'] as num?)?.toDouble() ?? 20.0,
      coefficient: map['coefficient'] ?? 1,
      comment: map['comment'],
      publishedAt: (map['publishedAt'] as Timestamp).toDate(),
      semester: map['semester'] ?? 1,
      evaluation: EvaluationType.values.firstWhere(
        (e) {
          String val = map['evaluation'] ?? 'ds';
          String eString = e.toString().split('.').last;
          if (val == 'final' && eString == 'finalExam') return true;
          return eString == val;
        },
        orElse: () => EvaluationType.ds,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'teacherName': teacherName,
      'score': score,
      'maxScore': maxScore,
      'coefficient': coefficient,
      'comment': comment,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'semester': semester,
      'evaluation': evaluation == EvaluationType.finalExam ? 'final' : evaluation.toString().split('.').last,
    };
  }
}
