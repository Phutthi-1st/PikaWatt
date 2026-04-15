import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // ✅ เพิ่ม Import
import 'firebase_options.dart';

// Import ระบบธีมและหน้าจอต่างๆ
import 'theme_provider.dart'; 
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/user_input.dart';
import 'screens/model_selection_screen.dart';
import 'screens/result.dart';
import 'screens/graph_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // ✅ 1. ครอบแอปด้วย ThemeProvider เพื่อให้เปลี่ยนสีได้ทั้งแอปทันที
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PikaWattApp(),
    ),
  );
}

class PikaWattApp extends StatelessWidget {
  const PikaWattApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 2. ใช้ Consumer เพื่อเฝ้าดูการสลับโหมดจากหน้า Setting
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PikaWatt',
          debugShowCheckedModeBanner: false,

          // ✅ 3. ตั้งค่าระบบธีม (Dark Mode / Light Mode)
          themeMode: themeProvider.themeMode,
          
          // ☀️ ค่าสีโหมดปกติ (Light Mode)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFFBF0), // สีพื้นหลังเดิม
            colorSchemeSeed: const Color(0xFFFFC926), // สีเหลืองหลัก
          ),

          // 🌙 ค่าสีโหมดมืด (Dark Mode)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A1A2E), // สีน้ำเงินเข้ม
            cardColor: const Color(0xFF252545),
            colorSchemeSeed: const Color(0xFFFFC926),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeDashboardScreen(),
            '/category': (context) => const ApplianceCategoryScreen(),
            '/compare': (context) => const CompareScreen(),
            '/userInput': (context) => const UsageSettingScreen(),
            '/model_selection': (context) => const ModelSelectionScreen(),
            '/result': (context) => const CalculationResultScreen(),
            '/graph_simulator': (context) => const GraphSimulatorScreen()
          },
        );
      },
    );
  } 
}
