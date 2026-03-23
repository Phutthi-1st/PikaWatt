import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
// import 'screens/home_screen.dart'; // import หน้าอื่นๆ ที่คุณจะสร้าง

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
        '/home': (context) => const Scaffold(body: Center(child: Text("Home Page"))), 
        // '/login': (context) => const LoginScreen(),
      },
    );
  }
}