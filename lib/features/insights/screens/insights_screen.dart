
import 'package:flutter/material.dart';
import '../../../theme/finova_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  static const String routeName = '/insights';

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _period = 'This Month';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'amount': 4200.0,
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Shopping',
      'amount': 2800.0,
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Transport',
      'amount': 1600.0,
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'name': 'Bills',
      'amount': 2400.0,
      'icon': Icons.receipt_long_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'name': 'Others',
      'amount': 1000.0,
      'icon': Icons.category_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  final List<double> _monthlySpending = [
    9500,
    11200,
    8700,
    12500,
    10500,
    12000,
  ];

  double get _totalExpenses => _categories.fold(
    0.0,
        (sum, item) => sum + (item['amount'] as double),
  );

  String _money(double amount) =>
      '₹${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final income = _period == 'This Week' ? 8000.0 : 25000.0;
    final expenses = _period == 'This Week'
        ? 5200.0
        : _totalExpenses;
    final savings = income - expenses;
    final savingsRate = income > 0
        ? (savings / income * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Insights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Your financial overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FinovaTheme.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _period,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text('This Month'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _period = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                    'Estimated savings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _money(savings),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: savingsRate / 100,
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
                    '${savingsRate.toStringAsFixed(0)}% savings rate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Income',
                    _money(income),
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    'Expenses',
                    _money(expenses),
                    Icons.trending_down_rounded,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'Spending by category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FinovaTheme.navy,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withAlpha(35),
                ),
              ),
              child: Column(
                children: _categories.map((item) {
                  final amount = item['amount'] as double;
                  final color = item['color'] as Color;
                  final share = _totalExpenses > 0
                      ? amount / _totalExpenses
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 21,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _money(amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: share,
                            minHeight: 8,
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
                              color: FinovaTheme.navy,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Monthly spending trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FinovaTheme.navy,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withAlpha(35),
                ),
              ),
              child: SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    _monthlySpending.length,
                        (index) {
                      final amount = _monthlySpending[index];
                      final maxAmount = _monthlySpending.reduce(
                            (a, b) => a > b ? a : b,
                      );
                      final height = 105 * amount / maxAmount;
                      const months = [
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                      ];

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(amount / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: height,
                                decoration: BoxDecoration(
                                  color: index ==
                                      _monthlySpending.length - 1
                                      ? FinovaTheme.blue
                                      : FinovaTheme.blue.withAlpha(90),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                months[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Smart money tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FinovaTheme.navy,
              ),
            ),
            const SizedBox(height: 14),

            _tipCard(
              Icons.restaurant_rounded,
              'Watch food spending',
              'Review food expenses and set a realistic limit for eating out.',
              const Color(0xFFF59E0B),
            ),
            _tipCard(
              Icons.savings_rounded,
              'Save consistently',
              'Set aside a portion of your income before spending.',
              const Color(0xFF10B981),
            ),
            _tipCard(
              Icons.receipt_long_rounded,
              'Review recurring bills',
              'Check subscriptions and recurring payments for services you no longer use.',
              const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
      String title,
      String amount,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: FinovaTheme.navy,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(
      IconData icon,
      String title,
      String description,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withAlpha(35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: FinovaTheme.navy,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
