import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/appliance_category.dart';
import 'screens/user_input.dart';
import 'screens/result.dart';
import 'screens/compare.dart';
import 'screens/setting.dart';
import 'screens/setting_abt.dart';
import 'screens/setting_des.dart';


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
        '/appliance': (context) => const ModelBrandScreen(),
        '/userinput': (context) => const UsageSettingScreen(),
        '/result': (context) => const CalculationResultScreen(),
        '/compare': (context) => const CompareScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/setting_abt': (context) => const AboutAppScreen(),
        '/setting_des': (context) => const DescriptionScreen(),
      },
    );
  }
}
