
import 'package:flutter/material.dart';
import '../../../theme/finova_theme.dart';
import 'add_savings_goal_screen.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  static const String routeName = '/savings-goals';

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Emergency Fund',
      'target': 50000.0,
      'saved': 18000.0,
      'icon': Icons.shield_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'New Laptop',
      'target': 80000.0,
      'saved': 32000.0,
      'icon': Icons.laptop_mac_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'title': 'Dream Vacation',
      'target': 40000.0,
      'saved': 12000.0,
      'icon': Icons.flight_takeoff_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  double get _totalSaved => _goals.fold(
    0.0,
        (sum, goal) => sum + (goal['saved'] as double),
  );

  double get _totalTarget => _goals.fold(
    0.0,
        (sum, goal) => sum + (goal['target'] as double),
  );

  String _money(double amount) =>
      '₹${amount.toStringAsFixed(0)}';

  Future<void> _addGoal() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddSavingsGoalScreen(),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _goals.add({
        'title': result['title'] ?? result['name'] ?? 'New Goal',
        'target': (result['targetAmount'] ??
            result['target'] ??
            result['target_amount'] ??
            0 as num)
            .toDouble(),
        'saved': (result['savedAmount'] ??
            result['saved'] ??
            result['currentAmount'] ??
            0 as num)
            .toDouble(),
        'icon': Icons.savings_rounded,
        'color': FinovaTheme.blue,
      });
    });
  }

  void _addSavings(Map<String, dynamic> goal) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add to ${goal['title']}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());

              if (amount == null ||
                  !amount.isFinite ||
                  amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid amount.'),
                  ),
                );
                return;
              }

              setState(() {
                goal['saved'] =
                    (goal['saved'] as double) + amount;
              });

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Savings updated successfully.'),
                ),
              );
            },
            child: const Text('Add Savings'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = _totalTarget > 0
        ? (_totalSaved / _totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _addGoal,
            tooltip: 'Add savings goal',
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
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Total saved',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _money(_totalSaved),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${_money(_totalTarget)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                    '${(overallProgress * 100).round()}% of total target saved',
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
                  'Your goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FinovaTheme.navy,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addGoal,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Goal'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_goals.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text('No savings goals yet. Add your first goal!'),
                ),
              )
            else
              ..._goals.map((goal) {
                final target = goal['target'] as double;
                final saved = goal['saved'] as double;
                final color = goal['color'] as Color;
                final progress = target > 0
                    ? (saved / target).clamp(0.0, 1.0)
                    : 0.0;
                final completed = saved >= target;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              goal['icon'] as IconData,
                              color: color,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  completed
                                      ? 'Goal completed!'
                                      : '${_money(target - saved > 0 ? target - saved : 0)} remaining',
                                  style: TextStyle(
                                    color: completed
                                        ? Colors.green
                                        : FinovaTheme.navy,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (completed)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _money(saved),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${_money(target)}',
                            style: const TextStyle(
                              color: FinovaTheme.navy,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: color.withAlpha(25),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(progress * 100).round()}% completed',
                          style: const TextStyle(
                            color: FinovaTheme.navy,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _addSavings(goal),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Savings'),
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
}
