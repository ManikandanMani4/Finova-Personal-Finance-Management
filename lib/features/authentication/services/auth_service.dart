
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      throw ArgumentError('Name, email, and password are required.');
    }

    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase did not return the new user.');
      }

      await user.updateDisplayName(cleanName);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': cleanName,
        'email': cleanEmail,
        'phone': phone?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (_) {
      // Avoid leaving an authentication account behind if profile creation fails.
      final user = credential?.user;
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {
          // The account may require recent authentication to delete.
        }
      }
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Enter your email and password.');
    }

    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw ArgumentError('Enter your email address.');
    }

    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
