
import 'package:flutter/material.dart';

import '../theme/finova_theme.dart';

// Authentication
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/forgot_password_screen.dart';

// Dashboard
import '../features/dashboard/screens/dashboard_screen.dart';

// Transactions
import '../features/transactions/screens/transactions_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/authentication/screens/splash_screen.dart';
// Budgets
import '../features/budgets/screens/budgets_screen.dart';
import '../features/budgets/screens/add_budget_screen.dart';

// Savings
import '../features/savings/screens/savings_goals_screen.dart';
import '../features/savings/screens/add_savings_goal_screen.dart';

// Other modules
import '../features/profile/screens/profile_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/bills/screens/bills_screen.dart';
import '../features/reports/screens/reports_screen.dart';

// AI and challenges
import '../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../features/challenges/screens/challenges_screen.dart';

import '../navigation/main_navigation.dart';

class FinovaApp extends StatelessWidget {
const FinovaApp({super.key});

@override
Widget build(BuildContext context) {
final Map<String, WidgetBuilder> appRoutes = {
// Authentication
LoginScreen.routeName: (_) => const LoginScreen(),
RegisterScreen.routeName: (_) => const RegisterScreen(),
ForgotPasswordScreen.routeName: (_) =>
const ForgotPasswordScreen(),

// Dashboard

// Transactions
TransactionsScreen.routeName: (_) =>
const TransactionsScreen(),
AddTransactionScreen.routeName: (_) =>
const AddTransactionScreen(),

// Budgets
BudgetsScreen.routeName: (_) => const BudgetsScreen(),
AddBudgetScreen.routeName: (_) => const AddBudgetScreen(),

// Savings
SavingsGoalsScreen.routeName: (_) =>
const SavingsGoalsScreen(),
AddSavingsGoalScreen.routeName: (_) =>
const AddSavingsGoalScreen(),

// Other modules
ProfileScreen.routeName: (_) => const ProfileScreen(),
InsightsScreen.routeName: (_) => const InsightsScreen(),
BillsScreen.routeName: (_) => const BillsScreen(),
ReportsScreen.routeName: (_) => const ReportsScreen(),
AiAssistantScreen.routeName: (_) =>
const AiAssistantScreen(),
ChallengesScreen.routeName: (_) =>
const ChallengesScreen(),
  SplashScreen.routeName: (_) => const SplashScreen(),
// Main navigation
MainNavigation.routeName: (_) => const MainNavigation(),
};

assert(() {
final routeNames = <String>[
LoginScreen.routeName,
RegisterScreen.routeName,
ForgotPasswordScreen.routeName,
DashboardScreen.routeName,
TransactionsScreen.routeName,
AddTransactionScreen.routeName,
BudgetsScreen.routeName,
AddBudgetScreen.routeName,
SavingsGoalsScreen.routeName,
AddSavingsGoalScreen.routeName,
ProfileScreen.routeName,
InsightsScreen.routeName,
BillsScreen.routeName,
ReportsScreen.routeName,
AiAssistantScreen.routeName,
ChallengesScreen.routeName,
MainNavigation.routeName,
];

final seen = <String>{};
for (final name in routeNames) {
if (!seen.add(name)) {
throw FlutterError('Duplicate Finova route name: $name');
}
}
return true;
}());

return MaterialApp(
title: 'Finova',
debugShowCheckedModeBanner: false,
theme: FinovaTheme.light(),
initialRoute: SplashScreen.routeName,
routes: appRoutes,
);
}
}
