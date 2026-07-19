import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> updateProfilePhoto(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // 1. Upload to Storage
      final ref = _storage.ref().child('profile_photos').child('${user.uid}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      // 2. Update Firestore
      await _firestore.collection('users').doc(user.uid).update({'photoUrl': url});

      // 3. Update Hive
      var userBox = Hive.box('userBox');
      await userBox.put('photoUrl', url);

      return url;
    } catch (e) {
      return null;
    }
  }

  // Connexion
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Lire le profil Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          UserModel userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
          
          // Mémoriser dans Hive
          var box = Hive.box('userBox');
          await box.put('uid', userModel.uid);
          await box.put('role', userModel.role.toString().split('.').last);
          await box.put('name', userModel.name);
          await box.put('filiere', userModel.filiere);
          await box.put('niveau', userModel.niveau);
          await box.put('photoUrl', userModel.photoUrl);
          
          return userModel;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Inscription étudiant (La date de création est ajoutée automatiquement ici)
  Future<UserModel?> registerStudent({
    required String name,
    required String email,
    required String matricule,
    required String filiere,
    required String niveau,
    required String password,
  }) async {
    try {
      // 1. Vérifier l'unicité du matricule
      QuerySnapshot check = await _firestore
          .collection('users')
          .where('matricule', isEqualTo: matricule)
          .get();
      
      if (check.docs.isNotEmpty) {
        throw Exception("Ce matricule est déjà utilisé.");
      }

      // 2. Créer le compte Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // 3. Créer le document Firestore avec la date de création automatique
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          matricule: matricule,
          role: UserRole.student,
          filiere: filiere,
          niveau: niveau,
          status: UserStatus.active,
          forcePasswordChange: false,
          createdAt: DateTime.now(), // Date automatique
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        // 4. Mémoriser dans Hive
        var box = Hive.box('userBox');
        await box.put('uid', newUser.uid);
        await box.put('role', 'student');
        await box.put('name', newUser.name);
        await box.put('filiere', newUser.filiere);
        await box.put('niveau', newUser.niveau);

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Inscription enseignant (La date de création est ajoutée automatiquement ici)
  Future<UserModel?> registerTeacher({
    required String name,
    required String email,
    required String matricule,
    required String specialite,
    required String password,
  }) async {
    try {
      // 1. Vérifier l'unicité du matricule
      QuerySnapshot check = await _firestore
          .collection('users')
          .where('matricule', isEqualTo: matricule)
          .get();
      
      if (check.docs.isNotEmpty) {
        throw Exception("Ce matricule est déjà utilisé.");
      }

      // 2. Créer le compte Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // 3. Créer le document Firestore avec la date de création automatique
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          matricule: matricule,
          role: UserRole.teacher,
          filiere: specialite, // On utilise filiere pour la spécialité
          niveau: 'Expert',
          status: UserStatus.pending, // En attente de validation
          forcePasswordChange: false,
          createdAt: DateTime.now(), // Date automatique
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        // 4. Mémoriser dans Hive
        var box = Hive.box('userBox');
        await box.put('uid', newUser.uid);
        await box.put('role', 'teacher');
        await box.put('name', newUser.name);
        await box.put('filiere', newUser.filiere);
        await box.put('niveau', newUser.niveau);

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Inscription admin (La date de création est ajoutée automatiquement ici)
  Future<UserModel?> registerAdmin({
    required String name,
    required String email,
    required String fonction,
    required String password,
  }) async {
    try {
      // 2. Créer le compte Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // 3. Créer le document Firestore avec la date de création automatique
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          matricule: 'ADMIN-${DateTime.now().millisecondsSinceEpoch}',
          role: UserRole.admin,
          filiere: fonction,
          niveau: 'Directeur',
          status: UserStatus.pending,
          forcePasswordChange: false,
          createdAt: DateTime.now(), // Date automatique
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        // 4. Mémoriser dans Hive
        var box = Hive.box('userBox');
        await box.put('uid', newUser.uid);
        await box.put('role', 'admin');
        await box.put('name', newUser.name);
        await box.put('filiere', newUser.filiere);
        await box.put('niveau', newUser.niveau);

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Vérifier le code secret (Enseignant ou Admin)
  Future<bool> verifySecretCode(String role, String code) async {
    try {
      final cleanCode = code.trim().toUpperCase();
      
      // Vérification directe avec les codes demandés
      if (role == 'teacher' && cleanCode == 'PROF2026') {
        return true;
      }
      if (role == 'admin' && cleanCode == 'ADMIN2026') {
        return true;
      }

      // Secours : Lecture depuis Firestore
      DocumentSnapshot doc = await _firestore.collection('config').doc('codes').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (role == 'teacher') {
          final dbCode = data['teacher']?.toString().trim().toUpperCase();
          return dbCode == cleanCode;
        } else if (role == 'admin') {
          final dbCode = data['admin']?.toString().trim().toUpperCase();
          return dbCode == cleanCode;
        }
      }
      return false;
    } catch (e) {
      // En cas de problème réseau, on valide quand même si le code saisi est le bon code physique
      final cleanCode = code.trim().toUpperCase();
      if (role == 'teacher' && cleanCode == 'PROF2026') return true;
      if (role == 'admin' && cleanCode == 'ADMIN2026') return true;
      return false;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    var box = Hive.box('userBox');
    // On garde onboarding_done mais on vide les infos utilisateur
    await box.delete('uid');
    await box.delete('role');
    await box.delete('name');
    await box.delete('filiere');
    await box.delete('niveau');
    await box.delete('photoUrl');
  }

  // Mot de passe oublié (logique Firestore selon document)
  Future<void> requestPasswordReset(String matricule) async {
    await _firestore.collection('passwordResets').doc(matricule).set({
      'requestedAt': FieldValue.serverTimestamp(),
      'handled': false,
    });
  }
}
