import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_card.dart';
import '../screens/inventory_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/employees_screen.dart';
import '../screens/reports_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  final UserProfile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == 'admin';
    final isSales = profile.role == 'sales';
    final isOps = profile.role == 'ops';

    final tiles = <_HomeTileData>[
      if (isAdmin || isSales)
        _HomeTileData(
          title: 'Inventario',
          subtitle: 'Control de stock y productos',
          icon: Icons.inventory_2_outlined,
          route: InventoryScreen.routeName,
        ),
      if (isAdmin || isSales)
        _HomeTileData(
          title: 'Ventas',
          subtitle: 'Registrar ventas y pagos',
          icon: Icons.point_of_sale_outlined,
          route: SalesScreen.routeName,
        ),
      if (isAdmin)
        _HomeTileData(
          title: 'Gastos',
          subtitle: 'Registrar gastos mensuales',
          icon: Icons.payments_outlined,
          route: ExpensesScreen.routeName,
        ),
      if (isAdmin || isOps)
        _HomeTileData(
          title: 'Empleados',
          subtitle: 'Jornadas y contratos',
          icon: Icons.groups_outlined,
          route: EmployeesScreen.routeName,
        ),
      if (isAdmin)
        _HomeTileData(
          title: 'Reportes',
          subtitle: 'Análisis de resultados',
          icon: Icons.bar_chart_outlined,
          route: ReportsScreen.routeName,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CoreBiz'),
      ),
      drawer: AppDrawer(
        profile: profile,
        onLogout: () async {
          await AuthService().logout();
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Hola, ${profile.name}',
                  key: ValueKey(profile.name),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rol: ${_roleLabel(profile.role)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 900
                        ? 3
                        : constraints.maxWidth > 600
                            ? 2
                            : 1;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: GridView.count(
                        key: ValueKey(columns),
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: tiles
                            .map(
                              (tile) => InkWell(
                                onTap: () => Navigator.pushNamed(context, tile.route, arguments: profile),
                                borderRadius: BorderRadius.circular(16),
                                child: AppCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        child: Icon(tile.icon, color: Theme.of(context).colorScheme.primary),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        tile.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(tile.subtitle),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
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

class _HomeTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  _HomeTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

String _roleLabel(String role) {
  switch (role) {
    case 'admin':
      return 'Administrador';
    case 'ops':
      return 'Operativo / Planta';
    default:
      return 'Empleado de ventas';
  }
}
