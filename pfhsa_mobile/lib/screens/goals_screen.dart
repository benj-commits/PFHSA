import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: goalProvider.isLoading && goalProvider.goals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : goalProvider.goals.isEmpty
              ? Center(
                  child: Text('No goals yet.\nTap + to start saving for something.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(14, color: AppColors.mutedInk)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: goalProvider.goals.length,
                  itemBuilder: (context, i) {
                    final Goal g = goalProvider.goals[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paperDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(g.name, style: AppTextStyles.body(15, weight: FontWeight.w600))),
                              GestureDetector(
                                onTap: () => _showContributeDialog(context, g),
                                child: Icon(Icons.add_circle_outline, color: AppColors.pine),
                              ),
                            ],
                          ),
                          if (g.deadline != null) ...[
                            const SizedBox(height: 2),
                            Text('Target date: ${g.deadline!.toIso8601String().split('T').first}',
                                style: AppTextStyles.body(12, color: AppColors.mutedInk)),
                          ],
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (g.progressPercent / 100).clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: AppColors.hairline,
                              color: AppColors.brass,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${formatter.format(g.currentAmount)} of ${formatter.format(g.targetAmount)}',
                                  style: AppTextStyles.mono(13, color: AppColors.mutedInk)),
                              Text('${g.progressPercent.toStringAsFixed(0)}%',
                                  style: AppTextStyles.mono(13, color: AppColors.brass, weight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showContributeDialog(BuildContext context, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "${goal.name}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                context.read<GoalProvider>().contribute(goal.goalId, amount);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddGoalSheet(),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();
  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _deadline;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New goal', style: AppTextStyles.display(20)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Goal name (e.g. Laptop)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target amount'),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _deadline = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Target date (optional)'),
              child: Text(_deadline?.toIso8601String().split('T').first ?? 'Not set'),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create goal'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final target = double.tryParse(_targetController.text);
    if (target == null || target <= 0 || _nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final success = await context.read<GoalProvider>().createGoal(
          name: _nameController.text.trim(),
          targetAmount: target,
          deadline: _deadline,
        );
    setState(() => _saving = false);
    if (success && mounted) Navigator.pop(context);
  }
}
