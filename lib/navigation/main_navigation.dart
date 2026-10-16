
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
  // Actual screen index in IndexedStack.
  int _screenIndex = 0;

  // Selected item in the five-item bottom navigation.
  int _navIndex = 0;

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

  void _openScreen(int screenIndex) {
    setState(() {
      _screenIndex = screenIndex;

      // More remains selected for screens accessed through More.
      if (screenIndex == 0) {
        _navIndex = 0;
      } else if (screenIndex == 1) {
        _navIndex = 1;
      } else if (screenIndex == 3) {
        _navIndex = 2;
      } else if (screenIndex == 4) {
        _navIndex = 3;
      } else {
        _navIndex = 4;
      }
    });
  }

  void _showMoreMenu() {
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
                  _openScreen(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openScreen(5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Bills'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openScreen(6);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openScreen(7);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        _openScreen(0);
        break;
      case 1:
        _openScreen(1);
        break;
      case 2:
        _openScreen(3);
        break;
      case 3:
        _openScreen(4);
        break;
      case 4:
        _showMoreMenu();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _screenIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onDestinationSelected,
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
