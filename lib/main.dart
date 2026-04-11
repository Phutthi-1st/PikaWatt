import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/user_input.dart';
import 'screens/model_selection_screen.dart';

void main() {
  runApp(const PikaWattApp());
}

class PikaWattApp extends StatelessWidget {
  const PikaWattApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PikaWatt',
      debugShowCheckedModeBanner: false,
      // กำหนดหน้าแรก
      initialRoute: '/',
      // รวม Path ทั้งหมดในแอปไว้ที่นี่
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        '/category': (context) => const ApplianceCategoryScreen(),
        '/compare': (context) => const CompareScreen(),
        '/userInput': (context) => const UsageSettingScreen(),
        '/model_selection': (context) => const ModelSelectionScreen()
      },
    );
  }
}
