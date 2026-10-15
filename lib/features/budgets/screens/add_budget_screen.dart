
import 'package:flutter/material.dart';
import '../../../theme/finova_theme.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  static const String routeName = '/add-budget';

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  String _period = 'Monthly';
  String _category = 'Food';
  bool _saving = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Education',
    'Healthcare',
    'Other',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) return;

    final budget = <String, dynamic>{
      'category': _category,
      'amount': double.parse(_amountController.text.trim()),
      'period': _period,
      'createdAt': DateTime.now().toIso8601String(),
    };

    Navigator.pop(context, budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Budget',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FinovaTheme.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: FinovaTheme.blue,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Plan your spending',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: FinovaTheme.navy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set a limit to manage your expenses.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FinovaTheme.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Budget category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Budget amount (₹)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee),
                        hintText: 'Enter budget amount',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          value?.trim() ?? '',
                        );

                        if (amount == null ||
                            !amount.isFinite ||
                            amount <= 0) {
                          return 'Enter a valid amount greater than zero.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Budget period',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Weekly',
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: 'Monthly',
                          label: Text('Monthly'),
                        ),
                        ButtonSegment(
                          value: 'Yearly',
                          label: Text('Yearly'),
                        ),
                      ],
                      selected: {_period},
                      onSelectionChanged: (selection) {
                        setState(() => _period = selection.first);
                      },
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _saving
                            ? null
                            : () {
                          setState(() => _saving = true);
                          _saveBudget();
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'Save Budget',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: FinovaTheme.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
