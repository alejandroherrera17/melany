import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../screens/inventory_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/employees_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == 'admin';
    final isSales = profile.role == 'sales';
    final isOps = profile.role == 'ops';

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(profile.name.isNotEmpty ? profile.name[0] : 'C'),
              ),
              title: Text(profile.name),
              subtitle: Text(profile.email),
            ),
            const Divider(),
            if (isAdmin || isSales)
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Inventario'),
                onTap: () => Navigator.pushNamed(context, InventoryScreen.routeName, arguments: profile),
              ),
            if (isAdmin || isSales)
              ListTile(
                leading: const Icon(Icons.point_of_sale_outlined),
                title: const Text('Ventas'),
                onTap: () => Navigator.pushNamed(context, SalesScreen.routeName, arguments: profile),
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Gastos'),
                onTap: () => Navigator.pushNamed(context, ExpensesScreen.routeName, arguments: profile),
              ),
            if (isAdmin || isOps)
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Empleados'),
                onTap: () => Navigator.pushNamed(context, EmployeesScreen.routeName, arguments: profile),
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Reportes'),
                onTap: () => Navigator.pushNamed(context, ReportsScreen.routeName, arguments: profile),
              ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName, arguments: profile),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
