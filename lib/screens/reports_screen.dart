import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class ReportsScreen extends StatelessWidget {
  static const routeName = '/reports';

  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context)!.settings.arguments as UserProfile;
    final service = FirestoreService();
    final todayStart = startOfDay(DateTime.now());
    final monthStart = startOfMonth(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Sale>>(
            stream: service.streamSales(),
            builder: (context, salesSnapshot) {
              final sales = salesSnapshot.data ?? [];
              final salesToday = sales.where((sale) => sale.createdAt.isAfter(todayStart)).toList();
              final salesMonth = sales.where((sale) => sale.createdAt.isAfter(monthStart)).toList();
              final salesTodayTotal = salesToday.fold<double>(0, (sum, sale) => sum + sale.total);
              final salesMonthTotal = salesMonth.fold<double>(0, (sum, sale) => sum + sale.total);

              return StreamBuilder<List<Expense>>(
                stream: service.streamExpenses(),
                builder: (context, expenseSnapshot) {
                  final expenses = expenseSnapshot.data ?? [];
                  final expensesMonth =
                      expenses.where((expense) => expense.createdAt.isAfter(monthStart)).toList();
                  final expenseMonthTotal =
                      expensesMonth.fold<double>(0, (sum, expense) => sum + expense.amount);
                  final netProfit = salesMonthTotal - expenseMonthTotal;

                  return StreamBuilder<List<Product>>(
                    stream: service.streamProducts(),
                    builder: (context, productSnapshot) {
                      final products = productSnapshot.data ?? [];
                      final productCategory = {
                        for (final product in products) product.name: product.category,
                      };
                      final salesByProduct = <String, double>{};
                      final salesByCategory = <String, double>{};
                      final salesByEmployee = <String, double>{};
                      for (final sale in salesMonth) {
                        salesByProduct.update(sale.productName, (value) => value + sale.total,
                            ifAbsent: () => sale.total);
                        final category = productCategory[sale.productName] ?? 'Otros';
                        salesByCategory.update(category, (value) => value + sale.total,
                            ifAbsent: () => sale.total);
                        salesByEmployee.update(sale.employeeName, (value) => value + sale.total,
                            ifAbsent: () => sale.total);
                      }

                      return ListView(
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Resumen'),
                                const SizedBox(height: 8),
                                _SummaryRow(label: 'Ventas del día', value: salesTodayTotal),
                                _SummaryRow(label: 'Ventas del mes', value: salesMonthTotal),
                                _SummaryRow(label: 'Gastos del mes', value: expenseMonthTotal),
                                _SummaryRow(label: 'Ganancia neta', value: netProfit),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Ventas por producto'),
                                const SizedBox(height: 8),
                                ...salesByProduct.entries.map(
                                  (entry) => _LabelValueRow(
                                    label: entry.key,
                                    value: entry.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Ventas por categoría'),
                                const SizedBox(height: 8),
                                ...salesByCategory.entries.map(
                                  (entry) => _LabelValueRow(
                                    label: entry.key,
                                    value: entry.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Ventas por empleado'),
                                const SizedBox(height: 8),
                                ...salesByEmployee.entries.map(
                                  (entry) => _LabelValueRow(
                                    label: entry.key,
                                    value: entry.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Detalle de gastos del mes'),
                                const SizedBox(height: 8),
                                ...expensesMonth.map(
                                  (expense) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(expense.category),
                                    subtitle: Text('${expense.description} • ${formatDate(expense.createdAt)}'),
                                    trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  final String label;
  final double value;

  const _LabelValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text('\$${value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
