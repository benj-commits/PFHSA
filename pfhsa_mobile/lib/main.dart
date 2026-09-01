import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/theme_controller.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.init(); // restore saved light/dark preference
  runApp(const PfhsaApp());
}

class PfhsaApp extends StatelessWidget {
  const PfhsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      // Rebuilds the whole app (and re-evaluates buildAppTheme()) whenever
      // the dark-mode toggle in the sidebar fires.
      child: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          return MaterialApp(
            title: 'PFHSA',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
