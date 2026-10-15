
import 'package:flutter/material.dart';
import '../../../theme/finova_theme.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  static const String routeName = '/bills';

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _filter = 'All';

  final List<Map<String, dynamic>> _bills = [
    {
      'name': 'Electricity',
      'provider': 'Electricity Board',
      'amount': 1250.0,
      'date': '20 Oct 2026',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFF59E0B),
      'paid': false,
    },
    {
      'name': 'Internet',
      'provider': 'Broadband',
      'amount': 799.0,
      'date': '22 Oct 2026',
      'icon': Icons.wifi_rounded,
      'color': Color(0xFF2563EB),
      'paid': false,
    },
    {
      'name': 'Mobile Recharge',
      'provider': 'Mobile Network',
      'amount': 399.0,
      'date': '25 Oct 2026',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF8B5CF6),
      'paid': true,
    },
    {
      'name': 'Water',
      'provider': 'Water Supply',
      'amount': 450.0,
      'date': '28 Oct 2026',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF06B6D4),
      'paid': false,
    },
    {
      'name': 'OTT Subscription',
      'provider': 'Entertainment',
      'amount': 299.0,
      'date': '30 Oct 2026',
      'icon': Icons.live_tv_rounded,
      'color': Color(0xFFEC4899),
      'paid': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredBills {
    final query = _searchController.text.trim().toLowerCase();

    return _bills.where((bill) {
      final matchesSearch =
          bill['name'].toString().toLowerCase().contains(query) ||
              bill['provider'].toString().toLowerCase().contains(query);

      final matchesFilter = _filter == 'All' ||
          (_filter == 'Pending' && !bill['paid']) ||
          (_filter == 'Paid' && bill['paid']);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  double get _pendingAmount => _bills
      .where((bill) => !bill['paid'])
      .fold(0.0, (sum, bill) => sum + (bill['amount'] as double));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _markAsPaid(Map<String, dynamic> bill) {
    if (bill['paid'] == true) return;

    setState(() {
      bill['paid'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${bill['name']} marked as paid.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bills & Payments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Pending bill amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${_pendingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_bills.where((bill) => !bill['paid']).length} bills awaiting payment',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search bills...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Wrap(
              spacing: 10,
              children: ['All', 'Pending', 'Paid'].map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  selectedColor: FinovaTheme.blue.withAlpha(35),
                  onSelected: (_) {
                    setState(() => _filter = filter);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            const Text(
              'Your bills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FinovaTheme.navy,
              ),
            ),
            const SizedBox(height: 14),

            if (_filteredBills.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    'No bills found.',
                    style: TextStyle(color: FinovaTheme.muted),
                  ),
                ),
              )
            else
              ..._filteredBills.map((bill) {
                final bool paid = bill['paid'] as bool;
                final Color iconColor = bill['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.withAlpha(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: iconColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              bill['icon'] as IconData,
                              color: iconColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bill['provider'] as String,
                                  style: const TextStyle(
                                    color: FinovaTheme.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${(bill['amount'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                paid ? 'PAID' : 'PENDING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: paid
                                      ? Colors.green
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 26),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 17,
                            color: FinovaTheme.muted,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Due: ${bill['date']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          if (!paid)
                            FilledButton(
                              onPressed: () => _markAsPaid(bill),
                              style: FilledButton.styleFrom(
                                backgroundColor: FinovaTheme.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text('Mark as paid'),
                            )
                          else
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                        ],
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
