
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsightsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to view insights.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  Future<Map<String, dynamic>> getInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? DateTime(now.year, now.month + 1, 1);

    final snapshot = await _transactions
        .where(
      'date',
      isGreaterThanOrEqualTo: Timestamp.fromDate(start),
    )
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    double income = 0;
    double expenses = 0;
    final Map<String, double> categoryExpenses = {};

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
        categoryExpenses[category] =
            (categoryExpenses[category] ?? 0) + amount;
      }
    }

    final savings = income - expenses;
    final savingsRate = income > 0 ? (savings / income) * 100 : 0.0;

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'income': income,
      'expenses': expenses,
      'savings': savings,
      'savingsRate': savingsRate,
      'transactionCount': snapshot.docs.length,
      'categoryExpenses': Map<String, double>.fromEntries(sortedCategories),
      'periodStart': start,
      'periodEnd': end,
    };
  }
}
