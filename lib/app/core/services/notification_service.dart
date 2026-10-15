
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class NotificationService {
  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static const MethodChannel _channel =
  MethodChannel('com.finova/notifications');

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Reads pending Android notifications and saves valid transactions.
  /// Returns the number of new transaction records saved.
  Future<int> syncPendingTransactions() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in before syncing transactions.');
    }

    final response =
    await _channel.invokeMethod<String>('getPendingTransactions');

    if (response == null || response.isEmpty) return 0;

    final decoded = jsonDecode(response);
    if (decoded is! List) return 0;

    final pending = decoded.whereType<Map>().toList();
    if (pending.isEmpty) return 0;

    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');

    int savedCount = 0;

    for (final raw in pending) {
      final item = Map<String, dynamic>.from(raw);

      final notificationId = item['notificationId']?.toString();
      final packageName = item['packageName']?.toString() ?? '';
      final title = item['title']?.toString().trim() ?? '';
      final message = item['message']?.toString().trim() ?? '';
      final timestamp = item['timestamp'];

      if (notificationId == null || notificationId.isEmpty) continue;

      final text = '$title $message';
      final amount = _extractAmount(text);
      final type = _extractType(text);

      // Do not create a financial record when the details are ambiguous.
      if (amount == null || amount <= 0 || type == null) continue;

      // Stable document ID makes repeated syncs idempotent.
      final documentId = base64Url
          .encode(utf8.encode(notificationId))
          .replaceAll('=', '');

      final reference = collection.doc('notification_$documentId');

      final date = timestamp is num
          ? DateTime.fromMillisecondsSinceEpoch(timestamp.toInt())
          : DateTime.now();

      final transaction = <String, dynamic>{
        'title': title.isNotEmpty ? title : 'Notification transaction',
        'amount': amount,
        'type': type,
        'category': 'Other',
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'notification',
        'sourcePackage': packageName,
        'notificationId': notificationId,
        'verificationStatus': 'needs_review',
      };

      final result = await _firestore.runTransaction<int>((tx) async {
        final existing = await tx.get(reference);

        if (existing.exists) return 0;

        tx.set(reference, transaction);
        return 1;
      });

      savedCount += result;
    }

    // Do not clear the Android queue here. Some records may need review,
    // and a partial upload must not cause pending data to be lost.
    return savedCount;
  }

  double? _extractAmount(String text) {
    final regex = RegExp(
      r'(?:₹\s*|rs\.?\s*|inr\s*)'
      r'([0-9][0-9,]*(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match == null) return null;

    return double.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  String? _extractType(String text) {
    final lower = text.toLowerCase();

    final income = RegExp(
      r'\b(credited|received|deposit|deposited)\b',
    ).hasMatch(lower);

    final expense = RegExp(
      r'\b(debited|debit|sent|paid|payment|withdrawn)\b',
    ).hasMatch(lower);

    // Ambiguous messages should not be classified automatically.
    if (income == expense) return null;

    return income ? 'income' : 'expense';
  }
}
