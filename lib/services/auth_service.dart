// ============================================================
// FILE: lib/services/auth_service.dart
// COPY THIS CODE INTO: lib/services/auth_service.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedMurabiId,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'assignedMurabiId': assignedMurabiId,
        'currentLevel': 1,
        'chillaDay': 1,
        'chillaStartDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return 'ای میل یا پاس ورڈ غلط ہے';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserRole() async {
    if (currentUser == null) return '';
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.get('role') ?? '';
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }
}

