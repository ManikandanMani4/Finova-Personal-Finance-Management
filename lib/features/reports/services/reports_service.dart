
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to view reports.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  Future<Map<String, dynamic>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    final snapshot = await _transactions
        .where(
      'date',
      isGreaterThanOrEqualTo: Timestamp.fromDate(start),
    )
        .where(
      'date',
      isLessThan: Timestamp.fromDate(end),
    )
        .get();

    double income = 0;
    double expenses = 0;
    final Map<String, double> categoryTotals = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final type = (data['type'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? 'Other').toString();

      if (type == 'income' || type == 'credit' || type == 'deposit') {
        income += amount;
      } else if (type == 'expense' ||
          type == 'debit' ||
          type == 'withdrawal') {
        expenses += amount;
        categoryTotals[category] =
            (categoryTotals[category] ?? 0) + amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'year': year,
      'month': month,
      'income': income,
      'expenses': expenses,
      'netSavings': income - expenses,
      'transactionCount': snapshot.docs.length,
      'categoryTotals': Map<String, double>.fromEntries(sortedCategories),
    };
  }
}
