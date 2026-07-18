import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

enum UserStatus { active, pending, inactive }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String matricule;
  final UserRole role;
  final String? filiere;
  final String? niveau;
  final String? photoUrl;
  final bool forcePasswordChange;
  final UserStatus status;
  final List<String>? subjects;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.matricule,
    required this.role,
    this.filiere,
    this.niveau,
    this.photoUrl,
    this.forcePasswordChange = false,
    this.status = UserStatus.pending,
    this.subjects,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      matricule: map['matricule'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      filiere: map['filiere'],
      niveau: map['niveau'],
      photoUrl: map['photoUrl'],
      forcePasswordChange: map['forcePasswordChange'] ?? false,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => UserStatus.pending,
      ),
      subjects: map['subjects'] != null ? List<String>.from(map['subjects']) : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'matricule': matricule,
      'role': role.toString().split('.').last,
      'filiere': filiere,
      'niveau': niveau,
      'photoUrl': photoUrl,
      'forcePasswordChange': forcePasswordChange,
      'status': status.toString().split('.').last,
      'subjects': subjects,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
