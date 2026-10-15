
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _challenges {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to access challenges.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('challenges');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchChallenges() {
    return _challenges.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addChallenge({
    required String title,
    required String description,
    required double targetAmount,
    DateTime? endDate,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw ArgumentError('Enter a title and description.');
    }

    if (!targetAmount.isFinite || targetAmount <= 0) {
      throw ArgumentError('Target amount must be greater than zero.');
    }

    await _challenges.add({
      'title': title.trim(),
      'description': description.trim(),
      'targetAmount': targetAmount,
      'progressAmount': 0.0,
      'isCompleted': false,
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProgress({
    required String challengeId,
    required double progressAmount,
  }) async {
    if (!progressAmount.isFinite || progressAmount < 0) {
      throw ArgumentError('Progress cannot be negative.');
    }

    final ref = _challenges.doc(challengeId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw StateError('Challenge not found.');
      }

      final data = snapshot.data()!;
      final target = (data['targetAmount'] as num).toDouble();

      if (progressAmount > target) {
        throw ArgumentError('Progress cannot exceed the target.');
      }

      transaction.update(ref, {
        'progressAmount': progressAmount,
        'isCompleted': progressAmount >= target,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _challenges.doc(challengeId).delete();
  }
}
