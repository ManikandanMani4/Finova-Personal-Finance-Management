
import 'package:flutter/material.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../features/budgets/screens/budgets_screen.dart';
import '../features/savings/screens/savings_goals_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/bills/screens/bills_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static const String routeName = '/main-navigation';
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    SavingsGoalsScreen(),
    InsightsScreen(),
    ReportsScreen(),
    BillsScreen(),
    ProfileScreen(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 4) {
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) {
                return SafeArea(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.pie_chart_outline),
                        title: const Text('Budgets'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => _selectedIndex = 2);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: const Text('Reports'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => _selectedIndex = 5);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('Bills'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => _selectedIndex = 6);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => _selectedIndex = 7);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
            return;
          }

          const destinationIndexes = [0, 1, 3, 4];
          setState(() {
            _selectedIndex = destinationIndexes[index];
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Savings',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),

    );
  }
}
