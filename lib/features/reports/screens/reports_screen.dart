
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/finova_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  static const String routeName = '/reports';

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'This Month';

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Salary',
      'category': 'Income',
      'amount': 25000.0,
      'date': DateTime(2026, 10, 1),
      'income': true,
    },
    {
      'title': 'Groceries',
      'category': 'Food',
      'amount': 1800.0,
      'date': DateTime(2026, 10, 5),
      'income': false,
    },
    {
      'title': 'Internet Bill',
      'category': 'Bills',
      'amount': 799.0,
      'date': DateTime(2026, 10, 8),
      'income': false,
    },
    {
      'title': 'Freelance Work',
      'category': 'Income',
      'amount': 3500.0,
      'date': DateTime(2026, 10, 10),
      'income': true,
    },
    {
      'title': 'Transport',
      'category': 'Transport',
      'amount': 650.0,
      'date': DateTime(2026, 10, 12),
      'income': false,
    },
    {
      'title': 'Shopping',
      'category': 'Shopping',
      'amount': 2200.0,
      'date': DateTime(2026, 10, 14),
      'income': false,
    },
  ];

  String _money(double amount) =>
      '₹${amount.toStringAsFixed(2)}';

  List<Map<String, dynamic>> get _filteredTransactions {
    final now = DateTime.now();

    return _transactions.where((transaction) {
      final date = transaction['date'] as DateTime;

      if (_period == 'This Week') {
        final start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(start) &&
            date.isBefore(start.add(const Duration(days: 7)));
      }

      if (_period == 'This Month') {
        return date.year == now.year && date.month == now.month;
      }

      return date.year == now.year;
    }).toList()
      ..sort((a, b) =>
          (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  double get _income => _filteredTransactions
      .where((t) => t['income'] == true)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));

  double get _expenses => _filteredTransactions
      .where((t) => t['income'] == false)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));

  Map<String, double> get _categoryTotals {
    final result = <String, double>{};

    for (final transaction in _filteredTransactions) {
      if (transaction['income'] == true) continue;

      final category = transaction['category'] as String;
      final amount = transaction['amount'] as double;

      result[category] = (result[category] ?? 0) + amount;
    }

    return result;
  }

  Future<void> _exportCsv() async {
    final rows = <List<String>>[
      ['Title', 'Category', 'Date', 'Type', 'Amount'],
      ..._filteredTransactions.map((t) => [
        t['title'].toString(),
        t['category'].toString(),
        _date(t['date'] as DateTime),
        t['income'] == true ? 'Income' : 'Expense',
        (t['amount'] as double).toStringAsFixed(2),
      ]),
    ];

    String escape(String value) =>
        '"${value.replaceAll('"', '""')}"';

    final csv = rows
        .map((row) => row.map(escape).join(','))
        .join('\n');

    await Clipboard.setData(ClipboardData(text: csv));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV report copied. Paste it into a file or spreadsheet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expenses;
    final categories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _period,
              decoration: InputDecoration(
                labelText: 'Report period',
                prefixIcon: const Icon(Icons.calendar_month_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'This Week',
                  child: Text('This Week'),
                ),
                DropdownMenuItem(
                  value: 'This Month',
                  child: Text('This Month'),
                ),
                DropdownMenuItem(
                  value: 'This Year',
                  child: Text('This Year'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _period = value);
                }
              },
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Net cash flow',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _money(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          'Income',
                          _money(_income),
                          Icons.arrow_downward_rounded,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryItem(
                          'Expenses',
                          _money(_expenses),
                          Icons.arrow_upward_rounded,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Expense breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FinovaTheme.navy,
              ),
            ),
            const SizedBox(height: 16),

            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No expense data for this period.')),
              )
            else
              ...categories.map((entry) {
                final share = _expenses > 0
                    ? entry.value / _expenses
                    : 0.0;
                final color = _categoryColor(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _money(entry.value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: share.clamp(0.0, 1.0),
                          minHeight: 9,
                          backgroundColor: color.withAlpha(25),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(share * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: FinovaTheme.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FinovaTheme.navy,
                    ),
                  ),
                ),
                Text(
                  '${_filteredTransactions.length} records',
                  style: const TextStyle(
                    color: FinovaTheme.navy,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_filteredTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No transactions for this period.')),
              )
            else
              ..._filteredTransactions.map((transaction) {
                final isIncome = transaction['income'] == true;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withAlpha(35),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (isIncome
                          ? Colors.green
                          : Colors.redAccent)
                          .withAlpha(25),
                      child: Icon(
                        isIncome
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                        color: isIncome ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      transaction['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${transaction['category']} • '
                          '${_date(transaction['date'] as DateTime)}',
                    ),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}'
                          '${_money(transaction['amount'] as double)}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
      String title,
      String amount,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(color: color.withAlpha(200), fontSize: 12),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFF59E0B);
      case 'Shopping':
        return const Color(0xFF8B5CF6);
      case 'Transport':
        return const Color(0xFF2563EB);
      case 'Bills':
        return const Color(0xFF06B6D4);
      default:
        return FinovaTheme.blue;
    }
  }
}
