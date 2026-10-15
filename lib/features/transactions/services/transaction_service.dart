
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class TransactionService {
final FirebaseFirestore _firestore;
final FirebaseAuth _auth;

TransactionService({
FirebaseFirestore? firestore,
FirebaseAuth? auth,
})  : _firestore = firestore ?? FirebaseFirestore.instance,
_auth = auth ?? FirebaseAuth.instance;

String get _userId {
final user = _auth.currentUser;

if (user == null) {
throw StateError('Please sign in to access transactions.');
}

return user.uid;
}

CollectionReference<Map<String, dynamic>> get _transactions =>
_firestore
    .collection('users')
    .doc(_userId)
    .collection('transactions');

// Add a transaction.
Future<String> addTransaction(TransactionModel transaction) async {
final doc = _transactions.doc();

await doc.set(transaction.toMap());

return doc.id;
}

// Stream transactions, newest first.
Stream<List<TransactionModel>> watchTransactions() {
return _transactions
    .orderBy('date', descending: true)
    .snapshots()
    .map(
(snapshot) => snapshot.docs
    .map(
(doc) => TransactionModel.fromMap(
doc.id,
doc.data(),
),
)
    .toList(),
);
}

// Fetch transactions once.
Future<List<TransactionModel>> getTransactions() async {
final snapshot = await _transactions
    .orderBy('date', descending: true)
    .get();

return snapshot.docs
    .map(
(doc) => TransactionModel.fromMap(
doc.id,
doc.data(),
),
)
    .toList();
}

// Get one transaction.
Future<TransactionModel?> getTransaction(String id) async {
final doc = await _transactions.doc(id).get();
final data = doc.data();

if (!doc.exists || data == null) {
return null;
}

return TransactionModel.fromMap(doc.id, data);
}

// Update a transaction.
Future<void> updateTransaction(
TransactionModel transaction,
) async {
if (transaction.id.trim().isEmpty) {
throw ArgumentError('Transaction ID cannot be empty.');
}

await _transactions
    .doc(transaction.id)
    .update(transaction.toMap());
}

// Delete a transaction.
Future<void> deleteTransaction(String id) async {
if (id.trim().isEmpty) {
throw ArgumentError('Transaction ID cannot be empty.');
}

await _transactions.doc(id).delete();
}

// Calculate total income.
Future<double> getTotalIncome() async {
final transactions = await getTransactions();

return transactions
    .where((transaction) => transaction.isIncome)
    .fold<double>(
0.0,
(total, transaction) => total + transaction.amount,
);
}

// Calculate total expenses.
Future<double> getTotalExpenses() async {
final transactions = await getTransactions();

return transactions
    .where((transaction) => transaction.isExpense)
    .fold<double>(
0.0,
(total, transaction) => total + transaction.amount,
);
}
}
