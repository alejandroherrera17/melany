import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class ExpensesScreen extends StatefulWidget {
  static const routeName = '/expenses';

  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _service = FirestoreService();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    if (_categoryController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() => _loading = true);
    await _service.addExpense(
      Expense(
        id: '',
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0,
        createdAt: DateTime.now(),
      ),
    );
    setState(() => _loading = false);
    _categoryController.clear();
    _descriptionController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context)!.settings.arguments as UserProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Registrar gasto'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Monto'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _addExpense,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar gasto'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Gastos recientes'),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Expense>>(
                  stream: _service.streamExpenses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final expenses = snapshot.data!;
                    return ListView.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return AppCard(
                          child: ListTile(
                            title: Text(expense.category),
                            subtitle: Text('${expense.description} • ${formatDate(expense.createdAt)}'),
                            trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
