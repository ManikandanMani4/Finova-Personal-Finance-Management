
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/transactions/models/transaction_model.dart';

class TransactionService {
static const String _storageKey = 'finova_transactions_v1';

final List<TransactionModel> _transactions = [];

List<TransactionModel> get transactions =>
List.unmodifiable(_transactions);

double get totalIncome => _transactions
    .where((t) => t.type == TransactionType.income)
    .fold(0.0, (sum, t) => sum + t.amount);

double get totalExpenses => _transactions
    .where((t) => t.type == TransactionType.expense)
    .fold(0.0, (sum, t) => sum + t.amount);

double get balance => totalIncome - totalExpenses;

Future<void> loadTransactions() async {
final prefs = await SharedPreferences.getInstance();
final raw = prefs.getString(_storageKey);

_transactions.clear();

if (raw == null || raw.isEmpty) {
debugPrint('FINOVA STORAGE: No saved transactions');
return;
}

try {
final decoded = jsonDecode(raw) as List<dynamic>;

_transactions.addAll(
decoded.map(
(item) => TransactionModel.fromJson(
Map<String, dynamic>.from(item as Map),
),
),
);

_transactions.sort((a, b) => b.date.compareTo(a.date));

debugPrint(
'FINOVA STORAGE: Loaded ${_transactions.length} transactions',
);
debugPrint('FINOVA STORAGE: Income = $totalIncome');
debugPrint('FINOVA STORAGE: Expenses = $totalExpenses');
} catch (error, stackTrace) {
debugPrint('FINOVA STORAGE: Load failed: $error');
debugPrintStack(stackTrace: stackTrace);
rethrow;
}
}

Future<bool> addTransaction(TransactionModel transaction) async {
if (_transactions.any((t) => t.id == transaction.id)) {
debugPrint('FINOVA STORAGE: Duplicate transaction ignored');
return false;
}

_transactions.insert(0, transaction);

try {
final prefs = await SharedPreferences.getInstance();

final json = jsonEncode(
_transactions.map((t) => t.toJson()).toList(),
);

final saved = await prefs.setString(_storageKey, json);

if (!saved) {
_transactions.removeWhere((t) => t.id == transaction.id);
debugPrint('FINOVA STORAGE: Write failed');
return false;
}

debugPrint(
'FINOVA STORAGE: Saved ${transaction.type}, '
'amount=${transaction.amount}',
);
debugPrint('FINOVA STORAGE: New balance = $balance');

return true;
} catch (error, stackTrace) {
_transactions.removeWhere((t) => t.id == transaction.id);
debugPrint('FINOVA STORAGE: Save error: $error');
debugPrintStack(stackTrace: stackTrace);
return false;
}
}

Future<void> clearTransactions() async {
final prefs = await SharedPreferences.getInstance();

_transactions.clear();
await prefs.remove(_storageKey);

debugPrint('FINOVA STORAGE: Transactions cleared');
}
}
