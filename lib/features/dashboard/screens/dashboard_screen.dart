
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/home';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideBalance = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _transactions {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> get _goals {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('savingsGoals');
  }

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _name {
    final displayName = _user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }

    return _user?.email?.split('@').first ?? 'there';
  }

  String _money(num value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isIncome(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    return type == 'credit' ||
        type == 'income' ||
        type == 'deposit';
  }

  bool _isExpense(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    return type == 'debit' ||
        type == 'expense' ||
        type == 'withdrawal';
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Please sign in to view your dashboard.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (_) => false,
                  );
                },
                child: const Text('Go to login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FC),
        title: const Text(
          'Finova',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const CircleAvatar(
              radius: 17,
              child: Icon(Icons.person_outline, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data?.data() ?? {};
            final profileName =
            (profile['name'] ?? _name).toString();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _transactions
                  .orderBy('date', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, transactionSnapshot) {
                final transactions =
                    transactionSnapshot.data?.docs ?? [];

                double income = 0;
                double expenses = 0;

                for (final doc in transactions) {
                  final data = doc.data();
                  final amount = _amount(data['amount']);

                  if (_isIncome(data)) {
                    income += amount;
                  } else if (_isExpense(data)) {
                    expenses += amount;
                  }
                }

                final balance = income - expenses;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Text(
                      '$_greeting, ${profileName.split(' ').first} 👋',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF102A43),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Here is your financial overview.',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Balance card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF246BFD),
                            Color(0xFF1645B8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Calculated net balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hideBalance = !_hideBalance;
                                  });
                                },
                                icon: Icon(
                                  _hideBalance
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hideBalance ? '₹ ••••••' : _money(balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _balanceItem(
                                  icon: Icons.arrow_downward,
                                  label: 'Income',
                                  amount: income,
                                  color: const Color(0xFFB9F6CA),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _balanceItem(
                                  icon: Icons.arrow_upward,
                                  label: 'Expenses',
                                  amount: expenses,
                                  color: const Color(0xFFFFD6D6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Quick actions
                    _sectionTitle('Quick actions'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _quickAction(
                            icon: Icons.add_card,
                            label: 'Transactions',
                            color: const Color(0xFFE5EDFF),
                            iconColor: const Color(0xFF246BFD),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/transactions',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _quickAction(
                            icon: Icons.savings_outlined,
                            label: 'Savings',
                            color: const Color(0xFFDDF7E9),
                            iconColor: const Color(0xFF16865C),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/savings',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _quickAction(
                            icon: Icons.pie_chart_outline,
                            label: 'Budgets',
                            color: const Color(0xFFFFEED9),
                            iconColor: const Color(0xFFAD6A00),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/budgets',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Savings goals
                    Row(
                      children: [
                        Expanded(child: _sectionTitle('Savings goals')),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/savings',
                          ),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _goals.limit(3).snapshots(),
                      builder: (context, goalsSnapshot) {
                        if (goalsSnapshot.hasError) {
                          return _emptyCard(
                            'Unable to load savings goals.',
                          );
                        }

                        final goals = goalsSnapshot.data?.docs ?? [];

                        if (goals.isEmpty) {
                          return _emptyCard(
                            'Your savings goals will appear here.',
                            action: 'Create a goal',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/savings',
                            ),
                          );
                        }

                        return Column(
                          children: goals.map((doc) {
                            final goal = doc.data();
                            final title =
                            (goal['title'] ?? 'Savings goal')
                                .toString();
                            final target =
                            _amount(goal['targetAmount']);
                            final saved =
                            _amount(goal['savedAmount']);
                            final progress = target > 0
                                ? (saved / target).clamp(0.0, 1.0)
                                : 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: _cardDecoration(),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.savings_outlined,
                                        color: Color(0xFF16865C),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).round()}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16865C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    borderRadius: BorderRadius.circular(8),
                                    backgroundColor:
                                    const Color(0xFFE7ECEF),
                                    color: const Color(0xFF16865C),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${_money(saved)} saved of ${_money(target)}',
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Recent transactions
                    Row(
                      children: [
                        Expanded(child: _sectionTitle('Recent activity')),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/transactions',
                          ),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (transactionSnapshot.hasError)
                      _emptyCard('Unable to load transactions.')
                    else if (transactions.isEmpty)
                      _emptyCard(
                        'Your transactions will appear here when available.',
                        action: 'View transactions',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/transactions',
                        ),
                      )
                    else
                      ...transactions.take(5).map((doc) {
                        final data = doc.data();
                        final isIncome = _isIncome(data);
                        final amount = _amount(data['amount']);
                        final title = (data['title'] ??
                            data['payee'] ??
                            data['merchant'] ??
                            data['category'] ??
                            'Transaction')
                            .toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: _cardDecoration(),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isIncome
                                    ? const Color(0xFFDDF7E9)
                                    : const Color(0xFFFFE6E6),
                                child: Icon(
                                  isIncome
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isIncome
                                      ? const Color(0xFF16865C)
                                      : Colors.redAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (data['category'] ?? 'General')
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isIncome ? '+' : '-'}${_money(amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome
                                      ? const Color(0xFF16865C)
                                      : const Color(0xFFB3261E),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Financial insights
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights,
                            size: 32,
                            color: Color(0xFF246BFD),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Understand your money',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF102A43),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Review your spending and build better habits.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/insights',
                            ),
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _balanceItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hideBalance ? '₹ •••••' : _money(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF102A43),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 6,
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(
      String message, {
        String? action,
        VoidCallback? onTap,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            color: Colors.blueGrey,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          if (action != null && onTap != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onTap,
              child: Text(action),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDF0F5)),
    );
  }
}
