import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/user_profile.dart';
import '../models/workday.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class EmployeesScreen extends StatelessWidget {
  static const routeName = '/employees';

  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context)!.settings.arguments as UserProfile;
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(context, service),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Equipo operativo'),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Employee>>(
                  stream: service.streamEmployees(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final employees = snapshot.data!;
                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(employee.name),
                                subtitle: Text("${employee.contractType} • ${employee.payType == 'daily' ? 'Pago diario' : 'Pago mensual'}"),
                                trailing: Text('\$${employee.rate.toStringAsFixed(2)}'),
                              ),
                              const SizedBox(height: 8),
                              StreamBuilder<List<Workday>>(
                                stream: service.streamWorkdaysForEmployee(employee.id),
                                builder: (context, workdaySnapshot) {
                                  final workdays = workdaySnapshot.data ?? [];
                                  final totalDays = workdays.length;
                                  final salary = employee.payType == 'daily'
                                      ? employee.rate * totalDays
                                      : employee.rate;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Días trabajados: $totalDays'),
                                      Text('Salario estimado: \$${salary.toStringAsFixed(2)}'),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await service.addWorkday(
                                      Workday(
                                        id: '',
                                        employeeId: employee.id,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.today_outlined),
                                  label: const Text('Registrar día'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if ((workdaySnapshot.data ?? []).isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  children: (workdaySnapshot.data ?? [])
                                      .take(5)
                                      .map((day) => Chip(label: Text(formatDate(day.date))))
                                      .toList(),
                                ),
                            ],
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

  Future<void> _showEmployeeDialog(BuildContext context, FirestoreService service) async {
    final nameController = TextEditingController();
    final contractController = TextEditingController();
    final rateController = TextEditingController();
    String payType = 'daily';
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo empleado'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contractController,
                  decoration: const InputDecoration(labelText: 'Tipo de contrato'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: payType,
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Pago por día')),
                    DropdownMenuItem(value: 'monthly', child: Text('Pago mensual')),
                  ],
                  onChanged: (value) => payType = value ?? 'daily',
                  decoration: const InputDecoration(labelText: 'Tipo de pago'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: 'Tarifa'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await service.addEmployee(
                Employee(
                  id: '',
                  name: nameController.text.trim(),
                  contractType: contractController.text.trim(),
                  payType: payType,
                  rate: double.tryParse(rateController.text) ?? 0,
                  createdAt: DateTime.now(),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
