import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';
import '../models/budget.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
      context.read<FinanceProvider>().loadCategories();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'exceeded':
        return AppColors.clay;
      case 'warning':
        return AppColors.brass;
      default:
        return AppColors.pine;
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgetProvider.isLoading && budgetProvider.budgets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : budgetProvider.budgets.isEmpty
              ? Center(
                  child: Text('No budgets set yet.\nTap + to set your first spending limit.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(14, color: AppColors.mutedInk)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: budgetProvider.budgets.length,
                  itemBuilder: (context, i) {
                    final Budget b = budgetProvider.budgets[i];
                    final color = _statusColor(b.status);
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
                              Text(b.categoryName ?? 'All categories', style: AppTextStyles.body(15, weight: FontWeight.w600)),
                              GestureDetector(
                                onTap: () => _confirmDeleteBudget(context, b.budgetId),
                                child: Icon(Icons.close, size: 18, color: AppColors.mutedInk),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (b.percentUsed / 100).clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: AppColors.hairline,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${formatter.format(b.spent)} of ${formatter.format(b.amount)}',
                                  style: AppTextStyles.mono(13, color: AppColors.mutedInk)),
                              Text('${b.percentUsed.toStringAsFixed(0)}%',
                                  style: AppTextStyles.mono(13, color: color, weight: FontWeight.w600)),
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
        onPressed: () => _showAddBudgetSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this budget?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetProvider>().deleteBudget(id);
            },
            child: Text('Remove', style: TextStyle(color: AppColors.clay)),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddBudgetSheet(),
    );
  }
}

class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet();
  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountController = TextEditingController();
  int? _categoryId;
  String _period = 'monthly';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set a budget', style: AppTextStyles.display(20)),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Category (leave blank for overall)'),
            items: finance.expenseCategories.map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Limit amount'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Period'),
            value: _period,
            items: const [
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
            onChanged: (v) => setState(() => _period = v ?? 'monthly'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save budget'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    final success = await context.read<BudgetProvider>().createBudget(
          categoryId: _categoryId,
          amount: amount,
          period: _period,
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        );
    setState(() => _saving = false);
    if (success && mounted) Navigator.pop(context);
  }
}
