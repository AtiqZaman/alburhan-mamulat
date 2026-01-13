import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache the user role to avoid repeated Firestore calls
  String? _cachedRole;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up a new user - STORES ROLE IMMEDIATELY
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedMurabiId,
  }) async {
    try {
      print('=== SIGNUP START ===');
      print('Email: $email, Role: $role, Name: $name');

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;
      print('✓ User created in Auth. UID: $uid');

      // IMMEDIATELY save to Firestore with simple try-catch
      try {
        await _firestore.collection('users').doc(uid).set(
          {
            'uid': uid,
            'name': name.trim(),
            'email': email.trim(),
            'role': role.trim().toLowerCase(), // Store as lowercase
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        print('✓ User and role saved to Firestore');
        
        // Cache the role locally
        _cachedRole = role.trim().toLowerCase();
        print('✓ Role cached: $_cachedRole');
      } catch (e) {
        print('⚠ Firestore save error: $e');
        // Still cache locally even if Firestore fails
        _cachedRole = role.trim().toLowerCase();
      }

      print('=== SIGNUP SUCCESS ===');
      return null;
    } on FirebaseAuthException catch (e) {
      print('✗ FirebaseAuthException: ${e.code}');
      
      if (e.code == 'email-already-in-use') {
        return 'یہ ای میل پہلے سے استعمال میں ہے';
      } else if (e.code == 'weak-password') {
        return 'پاس ورڈ بہت کمزور ہے';
      } else if (e.code == 'invalid-email') {
        return 'ای میل غلط ہے';
      }
      return 'خرابی: ${e.message ?? e.code}';
    } catch (e) {
      print('✗ Signup error: $e');
      return 'غیر متوقع خرابی: $e';
    }
  }

  /// Sign in existing user
  Future<String?> signIn(String email, String password) async {
    try {
      print('=== SIGNIN START ===');
      print('Email: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✓ Sign in successful');
      
      // Clear cache on new login so we fetch fresh role
      _cachedRole = null;
      
      print('=== SIGNIN SUCCESS ===');
      return null;
    } on FirebaseAuthException catch (e) {
      print('✗ SignIn error: ${e.code}');

      if (e.code == 'user-not-found') {
        return 'یہ ای میل رجسٹرڈ نہیں ہے';
      } else if (e.code == 'wrong-password') {
        return 'پاس ورڈ غلط ہے';
      }
      return 'ای میل یا پاس ورڈ غلط ہے';
    } catch (e) {
      print('✗ Signin error: $e');
      return 'غیر متوقع خرابی: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('Signing out...');
      _cachedRole = null; // Clear cache
      await _auth.signOut();
      notifyListeners();
      print('✓ Sign out successful');
    } catch (e) {
      print('✗ SignOut error: $e');
    }
  }

  /// Get user role - WITH CACHING
  Future<String> getUserRole() async {
    try {
      if (currentUser == null) {
        print('getUserRole: No current user');
        return 'salik';
      }

      // Return cached role if available
      if (_cachedRole != null) {
        print('✓ Using cached role: $_cachedRole');
        return _cachedRole!;
      }

      final uid = currentUser!.uid;
      final email = currentUser!.email ?? '';
      print('Fetching role for: $uid ($email)');

      // Try to get from Firestore
      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .get()
            .timeout(Duration(seconds: 3));

        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['role'] != null) {
            // SAFE extraction - handle any type
            var roleValue = data['role'];
            final roleStr = roleValue.toString().trim().toLowerCase();
            
            // Validate role
            if (['admin', 'murabi', 'salik'].contains(roleStr)) {
              print('✓ Role from Firestore: $roleStr');
              _cachedRole = roleStr; // Cache it
              return roleStr;
            }
          }
        }
        print('⚠ No role data in Firestore document');
      } catch (e) {
        print('⚠ Firestore error: $e');
      }

      // Fallback: email pattern
      print('Using email pattern for role...');
      final emailLower = email.toLowerCase();
      String finalRole = 'salik'; // Default
      
      if (emailLower.contains('admin')) {
        finalRole = 'admin';
      } else if (emailLower.contains('murabi') || emailLower.contains('murshad')) {
        finalRole = 'murabi';
      }
      
      print('✓ Role determined: $finalRole');
      _cachedRole = finalRole;
      return finalRole;
    } catch (e) {
      print('✗ Critical error: $e');
      return _cachedRole ?? 'salik';
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get()
          .timeout(Duration(seconds: 3));

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      print('⚠ Error getting user data: $e');
      return null;
    }
  }

  /// Update user data
  Future<String?> updateUserData(Map<String, dynamic> data) async {
    try {
      if (currentUser == null) {
        return 'کوئی یوزر لاگ ان نہیں ہے';
      }

      await _firestore.collection('users').doc(currentUser!.uid).update(data);
      return null;
    } catch (e) {
      print('⚠ Error updating user: $e');
      return null;
    }
  }
}
