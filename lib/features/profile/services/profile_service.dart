
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> get _profileRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to access your profile.');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile() {
    return _profileRef.snapshots();
  }

  Future<Map<String, dynamic>> getProfile() async {
    final snapshot = await _profileRef.get();
    return snapshot.data() ?? {};
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to update your profile.');
    }

    await user.updateDisplayName(name.trim());

    await _profileRef.set({
      'uid': user.uid,
      'name': name.trim(),
      'email': user.email,
      if (phone != null) 'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user.reload();
  }

  Future<void> updateEmail(String newEmail) async {
    if (newEmail.trim().isEmpty) {
      throw ArgumentError('Email cannot be empty.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to update your email.');
    }

    await user.verifyBeforeUpdateEmail(newEmail.trim());

    await _profileRef.set({
      'email': newEmail.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
