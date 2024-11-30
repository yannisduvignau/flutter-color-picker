import 'package:color_picker/widgets/notification_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription d'un utilisateur avec email et mot de passe
  Future<User?> registerWithEmail(String email, String password, String role, BuildContext context) async {
    try {
      // Création de l'utilisateur via FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Création de l'utilisateur dans Firestore avec un rôle par défaut
      await createUserInFirestore(userCredential.user, role);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Show success message
        pushNotificationMessage(
          context: context,
          message: "${e.message}",
          type: MessageType.error,
        );
      return null;
    }
  }

  // Connexion d'un utilisateur avec email et mot de passe
  Future<User?> loginWithEmail(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      pushNotificationMessage(
          context: context,
          message: "${e.message}",
          type: MessageType.error,
        );
      return null;
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Réinitialisation du mot de passe de l'utilisateur
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Email de réinitialisation envoyé");
    } on FirebaseAuthException catch (e) {
      pushNotificationMessage(
          context: context,
          message: "${e.message}",
          type: MessageType.error,
        );
    }
  }

  // Ajouter un utilisateur dans Firestore
  Future<void> createUserInFirestore(User? user, String role) async {
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role,  // Par exemple "admin", "user"
        'created_at': FieldValue.serverTimestamp(),
      });
      print("Utilisateur ajouté dans Firestore");
    } catch (e) {
      print("Erreur Firestore: ${e}");
    }
  }

  // Obtenir le rôle de l'utilisateur depuis Firestore
  Future<String?> getUserRole(String uid, BuildContext context) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc['role'];
    } catch (e) {
      pushNotificationMessage(
          context: context,
          message: "${e}",
          type: MessageType.error,
        );
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Obtenir l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
