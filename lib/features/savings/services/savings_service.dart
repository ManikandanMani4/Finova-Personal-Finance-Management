
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to manage savings goals.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection('users').doc(_uid).collection('savingsGoals');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGoals() {
    return _goals.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    double savedAmount = 0,
    DateTime? targetDate,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Goal name is required.');
    }

    if (!targetAmount.isFinite || targetAmount <= 0) {
      throw ArgumentError('Target amount must be greater than zero.');
    }

    if (!savedAmount.isFinite || savedAmount < 0 || savedAmount > targetAmount) {
      throw ArgumentError('Saved amount must be between zero and the target.');
    }

    await _goals.add({
      'name': name.trim(),
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addSavings({
    required String goalId,
    required double amount,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Enter an amount greater than zero.');
    }

    await _firestore.runTransaction((transaction) async {
      final ref = _goals.doc(goalId);
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw StateError('Savings goal not found.');
      }

      final data = snapshot.data()!;
      final saved = (data['savedAmount'] as num?)?.toDouble() ?? 0;
      final target = (data['targetAmount'] as num?)?.toDouble() ?? 0;

      if (saved + amount > target) {
        throw StateError('This amount exceeds the remaining goal balance.');
      }

      transaction.update(ref, {
        'savedAmount': saved + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _goals.doc(goalId).delete();
  }
}
