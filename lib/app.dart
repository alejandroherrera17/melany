import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/theme.dart';

class CoreBizApp extends StatelessWidget {
  const CoreBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoreBiz',
      theme: buildCoreBizTheme(),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (!snapshot.hasData) {
            return const LoginScreen();
          }
          return const AuthGate();
        },
      ),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        InventoryScreen.routeName: (_) => const InventoryScreen(),
        SalesScreen.routeName: (_) => const SalesScreen(),
        ExpensesScreen.routeName: (_) => const ExpensesScreen(),
        EmployeesScreen.routeName: (_) => const EmployeesScreen(),
        ReportsScreen.routeName: (_) => const ReportsScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
    );
  }
}
