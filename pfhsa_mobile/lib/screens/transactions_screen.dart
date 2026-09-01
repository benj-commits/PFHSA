import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../providers/finance_provider.dart';
import '../widgets/ledger_widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final finance = context.read<FinanceProvider>();
      finance.loadCategories();
      finance.loadIncome();
      finance.loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.mutedInk,
          indicatorColor: AppColors.pine,
          tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpenseList(expenses: finance.expenseList, isLoading: finance.isLoading),
          _IncomeList(incomeList: finance.incomeList, isLoading: finance.isLoading),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddExpenseSheet(context);
          } else {
            _showAddIncomeSheet(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddExpenseSheet(),
    );
  }

  void _showAddIncomeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddIncomeSheet(),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final bool isLoading;
  const _ExpenseList({required this.expenses, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading && expenses.isEmpty) return const Center(child: CircularProgressIndicator());
    if (expenses.isEmpty) {
      return Center(child: Text('No expenses logged yet.', style: AppTextStyles.body(14, color: AppColors.mutedInk)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const LedgerDivider(),
      itemBuilder: (context, i) {
        final e = expenses[i];
        return LedgerRow(
          title: e.categoryName ?? 'Uncategorized',
          subtitle: '${e.description ?? ''}  ·  ${e.date.toIso8601String().split('T').first}'.trim(),
          amount: e.amount,
          onLongPress: () => _confirmDelete(context, () => context.read<FinanceProvider>().deleteExpense(e.expenseId!)),
        );
      },
    );
  }
}

class _IncomeList extends StatelessWidget {
  final List<Income> incomeList;
  final bool isLoading;
  const _IncomeList({required this.incomeList, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading && incomeList.isEmpty) return const Center(child: CircularProgressIndicator());
    if (incomeList.isEmpty) {
      return Center(child: Text('No income logged yet.', style: AppTextStyles.body(14, color: AppColors.mutedInk)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: incomeList.length,
      separatorBuilder: (_, __) => const LedgerDivider(),
      itemBuilder: (context, i) {
        final inc = incomeList[i];
        return LedgerRow(
          title: inc.source,
          subtitle: inc.date.toIso8601String().split('T').first,
          amount: inc.amount,
          isPositive: true,
          onLongPress: () => _confirmDelete(context, () => context.read<FinanceProvider>().deleteIncome(inc.incomeId!)),
        );
      },
    );
  }
}

void _confirmDelete(BuildContext context, Future<bool> Function() onConfirm) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete this record?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text('Delete', style: TextStyle(color: AppColors.clay)),
        ),
      ],
    ),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();
  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log an expense', style: AppTextStyles.display(20)),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Category'),
            items: finance.expenseCategories
                .map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          const SizedBox(height: 14),
          _DatePickerField(date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save expense'),
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
    final success = await context.read<FinanceProvider>().addExpense(
          Expense(categoryId: _categoryId, amount: amount, description: _descController.text, date: _date),
        );
    setState(() => _saving = false);
    if (success && mounted) Navigator.pop(context);
  }
}

class _AddIncomeSheet extends StatefulWidget {
  const _AddIncomeSheet();
  @override
  State<_AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<_AddIncomeSheet> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log income', style: AppTextStyles.display(20)),
          const SizedBox(height: 20),
          TextField(
            controller: _sourceController,
            decoration: const InputDecoration(labelText: 'Source (e.g. Salary, Freelancing)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 14),
          _DatePickerField(date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save income'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _sourceController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final success = await context.read<FinanceProvider>().addIncome(
          Income(source: _sourceController.text.trim(), amount: amount, date: _date),
        );
    setState(() => _saving = false);
    if (success && mounted) Navigator.pop(context);
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date'),
        child: Text(date.toIso8601String().split('T').first),
      ),
    );
  }
}
