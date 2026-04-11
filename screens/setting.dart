import 'package:flutter/material.dart';
import 'setting_abt.dart';
import 'setting_des.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const SettingsScreen({super.key, this.onBackToHome});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A), // สีเหลืองเดียวกับหน้าโฮม
      extendBody: true,
      body: Column(
        children: [
          // --- ส่วน Header ที่ปรับใหม่ให้เหมือนหน้าประวัติ ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    onPressed: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else {
                        // กลับหน้าโฮมแบบล้าง Stack ตามตัวอย่างที่คุณต้องการ
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      }
                    },
                  ),
                  const Text(
                    'การตั้งค่า',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // --- ส่วนเนื้อหาด้านล่าง ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2), // สีครีม/เทาอ่อนเดียวกับหน้าโฮม
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 40, bottom: 100),
                child: Column(
                  children: [
                    _buildThemeItem(),
                    const SizedBox(height: 20),
                    _buildSettingItem(
                      context,
                      title: 'เกี่ยวกับแอพ',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSettingItem(
                      context,
                      title: 'คำอธิบาย',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DescriptionScreen()));
                      },
                    ),
                    const SizedBox(height: 80),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget รายการตัวเลือก (Bold + White Card) ---

  Widget _buildThemeItem() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ธีมมืด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Switch(
            value: _isDarkMode,
            activeColor: Colors.amber,
            onChanged: (bool value) => setState(() => _isDarkMode = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: double.infinity,
        height: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: const Text('ออกจากระบบ', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }
}