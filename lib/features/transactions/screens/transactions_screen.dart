
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  static const routeName = '/transactions';

  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';
  String _search = '';

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions');
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isIncome(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    return ['income', 'credit', 'deposit'].contains(type);
  }

  String _money(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view transactions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/add-transaction',
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (value) {
                  setState(() => _search = value.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF1F4F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton('All'),
                  const SizedBox(width: 8),
                  _filterButton('Income'),
                  const SizedBox(width: 8),
                  _filterButton('Expense'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _transactions
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Could not load transactions. Check your '
                              'Firestore rules and transaction date fields.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documents = snapshot.data!.docs.where((doc) {
                    final data = doc.data();
                    final income = _isIncome(data);

                    if (_filter == 'Income' && !income) return false;
                    if (_filter == 'Expense' && income) return false;

                    final title = (data['title'] ??
                        data['payee'] ??
                        data['merchant'] ??
                        data['category'] ??
                        'Transaction')
                        .toString()
                        .toLowerCase();

                    return title.contains(_search);
                  }).toList();

                  if (documents.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add a transaction to see it here.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  double incomeTotal = 0;
                  double expenseTotal = 0;

                  for (final doc in documents) {
                    final data = doc.data();
                    final amount = _amount(data['amount']);

                    if (_isIncome(data)) {
                      incomeTotal += amount;
                    } else {
                      expenseTotal += amount;
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              'Income',
                              incomeTotal,
                              const Color(0xFF16865C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              'Expenses',
                              expenseTotal,
                              const Color(0xFFB3261E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${documents.length} transaction(s)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...documents.map((doc) {
                        final data = doc.data();
                        final income = _isIncome(data);
                        final amount = _amount(data['amount']);
                        final title = (data['title'] ??
                            data['payee'] ??
                            data['merchant'] ??
                            data['category'] ??
                            'Transaction')
                            .toString();

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFEDF0F5),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: income
                                  ? const Color(0xFFDDF7E9)
                                  : const Color(0xFFFFE6E6),
                              child: Icon(
                                income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: income
                                    ? const Color(0xFF16865C)
                                    : const Color(0xFFB3261E),
                              ),
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${data['category'] ?? 'General'}',
                            ),
                            trailing: Text(
                              '${income ? '+' : '-'}${_money(amount)}',
                              style: TextStyle(
                                color: income
                                    ? const Color(0xFF16865C)
                                    : const Color(0xFFB3261E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String value) {
    final selected = _filter == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _filter = value),
        style: OutlinedButton.styleFrom(
          backgroundColor:
          selected ? const Color(0xFF246BFD) : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.blueGrey,
          side: BorderSide(
            color: selected
                ? const Color(0xFF246BFD)
                : const Color(0xFFE0E5EC),
          ),
        ),
        child: Text(value),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(
            _money(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
