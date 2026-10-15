
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to manage budgets.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _budgets =>
      _firestore.collection('users').doc(_uid).collection('budgets');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBudgets() {
    return _budgets.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addBudget({
    required String name,
    required double limit,
    required String category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Budget name is required.');
    }
    if (!limit.isFinite || limit <= 0) {
      throw ArgumentError('Budget limit must be greater than zero.');
    }

    await _budgets.add({
      'name': name.trim(),
      'limit': limit,
      'category': category,
      'startDate': Timestamp.fromDate(startDate ?? DateTime.now()),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBudget({
    required String budgetId,
    required String name,
    required double limit,
    required String category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (name.trim().isEmpty || !limit.isFinite || limit <= 0) {
      throw ArgumentError('Enter a name and a valid budget limit.');
    }

    await _budgets.doc(budgetId).update({
      'name': name.trim(),
      'limit': limit,
      'category': category,
      'startDate': Timestamp.fromDate(startDate ?? DateTime.now()),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBudget(String budgetId) async {
    await _budgets.doc(budgetId).delete();
  }
}
