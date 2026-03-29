import 'package:flutter/material.dart';
// import หน้าอื่นๆ เข้ามาเพื่อใช้นำทาง
import 'setting_abt.dart';
import 'setting_des.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // สถานะเปิด/ปิด ธีมมืด
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD147), // สีเหลืองหลักของแอป
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('การตั้งค่า', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB), // สีพื้นหลังครีมอ่อนๆ
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              // --- 1. ปุ่ม ธีมมืด (มี Switch) ---
              _buildThemeItem(),
              const SizedBox(height: 20),

              // --- 2. ปุ่ม เกี่ยวกับแอพ (กดเพื่อไปหน้าอื่น) ---
              _buildSettingItem(
                context,
                title: 'เกี่ยวกับแอพ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- 3. ปุ่ม คำอธิบาย (กดเพื่อไปหน้าอื่น) ---
              _buildSettingItem(
                context,
                title: 'คำอธิบาย',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DescriptionScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 100), // เพิ่มพื้นที่ด้านล่าง

              // --- 4. ปุ่ม ออกจากระบบ (สีแดง) ---
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar (UI ตกแต่ง)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Widget สำหรับปุ่ม ธีมมืด (แยก Logic Switch)
  Widget _buildThemeItem() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD), // สีเหลืองอ่อนมากๆ
        borderRadius: BorderRadius.circular(30),
        // ลบ Border สีดำออก และใช้เงาจางๆ แทน
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // เงาจางมาก
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ธีมมืด', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Switch(
            value: _isDarkMode,
            activeColor: Colors.amber, // สีตอนเปิด
            inactiveTrackColor: Colors.grey[300], // สีรางตอนปิด
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget สำหรับปุ่มตั้งค่าทั่วไป (เกี่ยวกับแอป, คำอธิบาย) - ไม่มีขอบดำ
  Widget _buildSettingItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD), // สีเหลืองอ่อนมากๆ
          borderRadius: BorderRadius.circular(30),
          // ลบ Border สีดำออก และใช้เงาจางๆ แทน
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // เงาจางมาก
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Text(title, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
    );
  }

  // Widget ปุ่มออกจากระบบ - ไม่มีขอบดำ
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // โค้ดสำหรับออกจากระบบจริงๆ เช่นล้าง Token
        Navigator.popUntil(context, (route) => route.isFirst); // กลับไปหน้าแรกสุด
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: double.infinity,
        height: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white, // พื้นหลังสีขาวตามแบบ
          borderRadius: BorderRadius.circular(35),
          // ลบขอบแดงออก และใช้เงาจางๆ
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Text('ออกจากระบบ', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      currentIndex: 2, // เลือกเมนูตั้งค่า
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'หน้าหลัก'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'ตั้งค่า'),
      ],
    );
  }
}