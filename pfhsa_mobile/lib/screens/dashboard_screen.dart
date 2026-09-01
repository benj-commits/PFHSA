import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/health_score_gauge.dart';
import '../widgets/ledger_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final user = context.watch<AuthProvider>().user;
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());
    final firstName = (user?.name.isNotEmpty ?? false) ? user!.name.split(' ').first : '';

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().loadDashboard(),
        child: dashboard.isLoading && dashboard.healthScore == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  _HeroCard(greeting: 'Hello, $firstName!'),
                  const SizedBox(height: 20),
                  const _WeekStrip(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ColorStatCard(
                          icon: Icons.call_received_rounded,
                          chipColor: AppColors.pine,
                          label: 'Income',
                          value: formatter.format(dashboard.totalIncome),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ColorStatCard(
                          icon: Icons.call_made_rounded,
                          chipColor: AppColors.clay,
                          label: 'Expenses',
                          value: formatter.format(dashboard.totalExpenses),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ColorStatCard(
                          icon: Icons.savings_rounded,
                          chipColor: AppColors.brass,
                          label: 'Savings',
                          value: formatter.format(dashboard.savings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SectionCard(
                    title: monthLabel,
                    child: Column(
                      children: [
                        if (dashboard.healthScore != null)
                          HealthScoreGauge(
                            score: dashboard.healthScore!.score,
                            rating: dashboard.healthScore!.rating,
                            emoji: dashboard.healthScore!.emoji,
                          ),
                      ],
                    ),
                  ),
                  if (dashboard.categoryBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SectionCard(
                      title: 'Where it went',
                      child: Column(
                        children: [
                          for (final c in dashboard.categoryBreakdown.take(6)) ...[
                            LedgerRow(title: c.categoryName, amount: c.total),
                            const LedgerDivider(),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (dashboard.healthScore != null && dashboard.healthScore!.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SectionCard(
                      title: 'Recommendations',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final r in dashboard.healthScore!.recommendations)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('· ', style: AppTextStyles.body(15, color: AppColors.brass)),
                                  Expanded(child: Text(r, style: AppTextStyles.body(14))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Gradient greeting banner — the dashboard's "hero" element, matching
/// the colorful card-dashboard reference rather than a plain header.
class _HeroCard extends StatelessWidget {
  final String greeting;
  const _HeroCard({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brass, AppColors.pine],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTextStyles.display(22, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Welcome back to your financial overview',
                    style: AppTextStyles.body(12, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.trending_up_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// A decorative current-week strip (Mon–Sun), highlighting today —
/// echoes the calendar strip in the reference dashboard mockup.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: List.generate(7, (i) {
        final d = monday.add(Duration(days: i));
        final isToday = d.day == today.day && d.month == today.month && d.year == today.year;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isToday ? AppColors.clay : AppColors.paperDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(labels[i],
                    style: AppTextStyles.body(10, color: isToday ? Colors.white : AppColors.mutedInk)),
                const SizedBox(height: 4),
                Text('${d.day}',
                    style: AppTextStyles.mono(13, color: isToday ? Colors.white : AppColors.ink, weight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Small stat tile with a colored icon chip — the "weekly report" card
/// pattern from the reference dashboard, adapted to our ledger palette.
class _ColorStatCard extends StatelessWidget {
  final IconData icon;
  final Color chipColor;
  final String label;
  final String value;

  const _ColorStatCard({required this.icon, required this.chipColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.paperDim, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: chipColor.withOpacity(0.16), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: chipColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.body(11, color: AppColors.mutedInk)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.mono(14, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
