
enum TransactionType {
income,
expense,
}

class TransactionModel {
final String id;
final String title;
final String category;
final double amount;
final TransactionType type;
final DateTime date;
final String paymentMethod;
final String? note;

const TransactionModel({
required this.id,
required this.title,
required this.category,
required this.amount,
required this.type,
required this.date,
this.paymentMethod = 'Other',
this.note,
});

bool get isIncome => type == TransactionType.income;

bool get isExpense => type == TransactionType.expense;

// Create a model from a JSON map.
factory TransactionModel.fromJson(Map<String, dynamic> json) {
return TransactionModel.fromMap(
json['id']?.toString() ?? '',
json,
);
}

// Create a model from a Firestore document.
factory TransactionModel.fromMap(
String id,
Map<String, dynamic> data,
) {
return TransactionModel(
id: id,
title: data['title'] as String? ?? '',
category: data['category'] as String? ?? 'Other',
amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
type: _parseType(data['type']),
date: _parseDate(data['date']),
paymentMethod:
data['paymentMethod'] as String? ?? 'Other',
note: data['note'] as String?,
);
}

static TransactionType _parseType(dynamic value) {
if (value == 'income' ||
value == 'TransactionType.income') {
return TransactionType.income;
}

return TransactionType.expense;
}

static DateTime _parseDate(dynamic value) {
if (value is DateTime) return value;

if (value is String) {
return DateTime.tryParse(value) ?? DateTime.now();
}

// Supports Firestore Timestamp.
if (value != null) {
try {
final result = (value as dynamic).toDate();
if (result is DateTime) return result;
} catch (_) {
// Use fallback for unsupported date values.
}
}

return DateTime.now();
}

// Convert the model to JSON.
Map<String, dynamic> toJson() {
return {
'id': id,
...toMap(),
};
}

// Convert the model to a map for Firestore.
Map<String, dynamic> toMap() {
return {
'title': title,
'category': category,
'amount': amount,
'type': type.name,
'date': date.toIso8601String(),
'paymentMethod': paymentMethod,
'note': note,
};
}

TransactionModel copyWith({
String? id,
String? title,
String? category,
double? amount,
TransactionType? type,
DateTime? date,
String? paymentMethod,
String? note,
}) {
return TransactionModel(
id: id ?? this.id,
title: title ?? this.title,
category: category ?? this.category,
amount: amount ?? this.amount,
type: type ?? this.type,
date: date ?? this.date,
paymentMethod: paymentMethod ?? this.paymentMethod,
note: note ?? this.note,
);
}
}
