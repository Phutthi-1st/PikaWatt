import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  // เช็คว่าตอนนี้เป็น Dark Mode หรือเปล่า
  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme(); // โหลดค่าที่เคยเซฟไว้ตอนเปิดแอป
  }

  // ฟังก์ชันสลับธีม
  void toggleTheme(bool isOn) async {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // สั่งให้ทั้งแอปเปลี่ยนสีทันที!
    
    // บันทึกค่าลงในเครื่อง
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isOn);
  }

  // ฟังก์ชันโหลดค่าธีม
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDarkMode') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}