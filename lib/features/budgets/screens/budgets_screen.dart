
import 'package:flutter/material.dart';
import '../../../theme/finova_theme.dart';
import 'add_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  static const String routeName = '/budgets';

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _budgets = [
    {
      'category': 'Food',
      'limit': 5000.0,
      'spent': 3200.0,
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFF59E0B),
      'period': 'Monthly',
    },
    {
      'category': 'Transport',
      'limit': 2000.0,
      'spent': 850.0,
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF2563EB),
      'period': 'Monthly',
    },
    {
      'category': 'Shopping',
      'limit': 4000.0,
      'spent': 3100.0,
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF8B5CF6),
      'period': 'Monthly',
    },
    {
      'category': 'Bills',
      'limit': 3000.0,
      'spent': 1800.0,
      'icon': Icons.receipt_long_rounded,
      'color': Color(0xFF06B6D4),
      'period': 'Monthly',
    },
  ];

  List<Map<String, dynamic>> get _filteredBudgets {
    if (_filter == 'All') return _budgets;

    return _budgets
        .where((budget) => budget['category'] == _filter)
        .toList();
  }

  double get _totalBudget => _budgets.fold(
    0.0,
        (sum, budget) => sum + (budget['limit'] as double),
  );

  double get _totalSpent => _budgets.fold(
    0.0,
        (sum, budget) => sum + (budget['spent'] as double),
  );

  String _money(double amount) =>
      '₹${amount.toStringAsFixed(2)}';

  Future<void> _addBudget() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBudgetScreen(),
      ),
    );

    if (!mounted || result == null) return;

    final category = result['category'] as String;
    final amount = result['amount'] as double;
    final period = result['period'] as String;

    final existingIndex = _budgets.indexWhere(
          (budget) =>
      budget['category'] == category &&
          budget['period'] == period,
    );

    setState(() {
      if (existingIndex >= 0) {
        _budgets[existingIndex]['limit'] = amount;
      } else {
        _budgets.add({
          'category': category,
          'limit': amount,
          'spent': 0.0,
          'icon': _categoryIcon(category),
          'color': _categoryColor(category),
          'period': period,
        });
      }

      _filter = 'All';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$category budget added successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Healthcare':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFF59E0B);
      case 'Transport':
        return const Color(0xFF2563EB);
      case 'Shopping':
        return const Color(0xFF8B5CF6);
      case 'Bills':
        return const Color(0xFF06B6D4);
      case 'Entertainment':
        return const Color(0xFFEC4899);
      case 'Education':
        return const Color(0xFF10B981);
      case 'Healthcare':
        return const Color(0xFFEF4444);
      default:
        return FinovaTheme.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalBudget - _totalSpent;
    final overallProgress = _totalBudget > 0
        ? (_totalSpent / _totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Budgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add budget',
            onPressed: _addBudget,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Overview',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _money(_totalBudget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total budget',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          'Spent',
                          _money(_totalSpent),
                          Icons.trending_up_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryItem(
                          'Remaining',
                          _money(remaining),
                          Icons.account_balance_wallet_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(overallProgress * 100).round()}% of budget used',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget categories',
                  style: TextStyle(
                    color: FinovaTheme.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addBudget,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', ..._budgets
                    .map((budget) => budget['category'] as String)
                    .toSet()].map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _filter == category,
                      selectedColor:
                      FinovaTheme.blue.withAlpha(30),
                      onSelected: (_) {
                        setState(() => _filter = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            if (_filteredBudgets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text('No budgets found.'),
                ),
              )
            else
              ..._filteredBudgets.map((budget) {
                final category = budget['category'] as String;
                final limit = budget['limit'] as double;
                final spent = budget['spent'] as double;
                final color = budget['color'] as Color;
                final progress = limit > 0
                    ? (spent / limit).clamp(0.0, 1.0)
                    : 0.0;
                final exceeded = spent > limit;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withAlpha(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              budget['icon'] as IconData,
                              color: color,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  budget['period'] as String,
                                  style: const TextStyle(
                                    color: FinovaTheme.navy,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _money(limit),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent ${_money(spent)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            exceeded
                                ? 'Over by ${_money(spent - limit)}'
                                : '${_money(limit - spent)} left',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: exceeded
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: color.withAlpha(25),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            exceeded ? Colors.red : color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(progress * 100).round()}% used',
                          style: const TextStyle(
                            fontSize: 11,
                            color: FinovaTheme.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
      String label,
      String amount,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
