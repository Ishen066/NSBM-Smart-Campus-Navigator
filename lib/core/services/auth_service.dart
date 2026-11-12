
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Student Registration
  Future<UserCredential> registerStudent({
    required String fullName,
    required String email,
    required String studentId,
    required String degreeProgramme,
    required String academicBatch,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Student account could not be created.');
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': normalizedEmail,
        'studentId': studentId.trim(),
        'degreeProgramme': degreeProgramme.trim(),
        'academicBatch': academicBatch.trim(),
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await user.sendEmailVerification();

      return credential;
    } catch (e) {
      // Keep the account so the student can retry verification.
      rethrow;
    }
  }

  // Student Login
  Future<UserCredential> loginStudent({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // Send verification email again
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in student found.');
    }

    await user.sendEmailVerification();
  }

  // Refresh current user's verification status
  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      return false;
    }

    if (refreshedUser.emailVerified) {
      await _firestore.collection('users').doc(refreshedUser.uid).update({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return refreshedUser.emailVerified;
  }

  // Get student profile
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // Update student profile
  Future<void> updateStudentProfile({
    required String fullName,
    required String studentId,
    required String degreeProgramme,
    required String academicBatch,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in student found.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName.trim(),
      'studentId': studentId.trim(),
      'degreeProgramme': degreeProgramme.trim(),
      'academicBatch': academicBatch.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}
