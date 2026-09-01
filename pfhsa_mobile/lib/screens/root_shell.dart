import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';

/// Top-level shell: the sidebar is always present — on the login/register
/// flow and on every authenticated view — matching the same persistent
/// layout as the web app, rather than each screen owning its own nav.
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  bool _checkedAuth = false;
  String _authView = 'login'; // 'login' | 'register'
  String _appView = 'overview';

  final _appScreens = const {
    'overview': DashboardScreen(),
    'ledger': TransactionsScreen(),
    'budgets': BudgetsScreen(),
    'goals': GoalsScreen(),
    'profile': ProfileScreen(),
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().tryAutoLogin();
    if (mounted) setState(() => _checkedAuth = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget body;
    if (!_checkedAuth) {
      body = const Center(child: CircularProgressIndicator());
    } else if (auth.isAuthenticated) {
      body = IndexedStack(
        index: _appScreens.keys.toList().indexOf(_appView),
        children: _appScreens.values.toList(),
      );
    } else if (_authView == 'register') {
      body = RegisterScreen(onSwitchToLogin: () => setState(() => _authView = 'login'));
    } else {
      body = LoginScreen(onSwitchToRegister: () => setState(() => _authView = 'register'));
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Row(
        children: [
          AppSidebar(
            isAuthenticated: auth.isAuthenticated,
            currentView: _appView,
            onViewSelected: (view) => setState(() => _appView = view),
            onLogout: () async {
              await auth.logout();
              setState(() => _authView = 'login');
            },
            user: auth.user,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
