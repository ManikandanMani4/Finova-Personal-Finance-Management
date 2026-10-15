
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _bills {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to manage bills.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bills');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBills() {
    return _bills.orderBy('dueDate').snapshots();
  }

  Future<void> addBill({
    required String name,
    required double amount,
    required DateTime dueDate,
    String category = 'Other',
    bool isPaid = false,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Bill name is required.');
    }

    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Bill amount must be greater than zero.');
    }

    await _bills.add({
      'name': name.trim(),
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsPaid({
    required String billId,
    required bool isPaid,
  }) async {
    await _bills.doc(billId).update({
      'isPaid': isPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBill({
    required String billId,
    required String name,
    required double amount,
    required DateTime dueDate,
    required String category,
  }) async {
    if (name.trim().isEmpty || !amount.isFinite || amount <= 0) {
      throw ArgumentError('Enter a valid bill name and amount.');
    }

    await _bills.doc(billId).update({
      'name': name.trim(),
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBill(String billId) async {
    await _bills.doc(billId).delete();
  }
}
