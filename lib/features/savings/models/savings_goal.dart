
class SavingsGoal {
final String id;
final String title;
final double targetAmount;
final double savedAmount;
final DateTime? targetDate;
final DateTime createdAt;

const SavingsGoal({
required this.id,
required this.title,
required this.targetAmount,
this.savedAmount = 0.0,
this.targetDate,
required this.createdAt,
});

double get remainingAmount =>
(targetAmount - savedAmount).clamp(0.0, double.infinity);

double get progress {
if (targetAmount <= 0) return 0.0;
return (savedAmount / targetAmount).clamp(0.0, 1.0);
}

bool get isCompleted => savedAmount >= targetAmount;

// Create a savings goal from JSON.
factory SavingsGoal.fromJson(Map<String, dynamic> json) {
return SavingsGoal.fromMap(
json['id']?.toString() ?? '',
json,
);
}

// Create a savings goal from a map and its document ID.
factory SavingsGoal.fromMap(
String id,
Map<String, dynamic> data,
) {
return SavingsGoal(
id: id,
title: data['title'] as String? ?? '',
targetAmount:
(data['targetAmount'] as num?)?.toDouble() ?? 0.0,
savedAmount:
(data['savedAmount'] as num?)?.toDouble() ?? 0.0,
targetDate: _parseDate(data['targetDate']),
createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
);
}

// Parse dates from strings, DateTime values, or Firestore Timestamps.
static DateTime? _parseDate(dynamic value) {
if (value == null) return null;

if (value is DateTime) return value;

if (value is String) {
return DateTime.tryParse(value);
}

try {
final result = (value as dynamic).toDate();
if (result is DateTime) return result;
} catch (_) {
// Unsupported date format.
}

return null;
}

// Convert the savings goal into JSON.
Map<String, dynamic> toJson() {
return {
'id': id,
...toMap(),
};
}

// Convert the savings goal into a map for storage.
Map<String, dynamic> toMap() {
return {
'title': title,
'targetAmount': targetAmount,
'savedAmount': savedAmount,
'targetDate': targetDate?.toIso8601String(),
'createdAt': createdAt.toIso8601String(),
};
}

SavingsGoal copyWith({
String? title,
double? targetAmount,
double? savedAmount,
DateTime? targetDate,
bool clearTargetDate = false,
}) {
return SavingsGoal(
id: id,
title: title ?? this.title,
targetAmount: targetAmount ?? this.targetAmount,
savedAmount: savedAmount ?? this.savedAmount,
targetDate:
clearTargetDate ? null : targetDate ?? this.targetDate,
createdAt: createdAt,
);
}
}
