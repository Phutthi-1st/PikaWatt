import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 
import '../theme_provider.dart'; 

import 'setting_abt.dart';
import 'setting_des.dart';
import 'setting_contact.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const SettingsScreen({super.key, this.onBackToHome});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Palette คงที่ ────────────────
  static const Color _primaryDark  = Color(0xFFF59E0B); 

  @override
  Widget build(BuildContext context) {
    // ✅ 1. ดึงข้อมูลธีมปัจจุบันจาก Provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // ✅ 2. ตั้งค่าสีแบบ Dynamic (สลับอัตโนมัติตามโหมด)
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);
    
    // Gradient พื้นหลังด้านบน (Light=สีเหลือง, Dark=สีกรมท่า)
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: topGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, textColor),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor, // สีพื้นหลังเปลี่ยนตามธีม
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
                    child: Column(
                      children: [
                        // --- การแสดงผล ---
                        _buildSectionHeader('การแสดงผล', textMid),
                        const SizedBox(height: 12),
                        _buildThemeItem(themeProvider, cardColor, textColor),
                        const SizedBox(height: 32),

                        // --- ข้อมูลแอปพลิเคชัน ---
                        _buildSectionHeader('ข้อมูลแอปพลิเคชัน', textMid),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          context,
                          title: 'เกี่ยวกับ PikaWatt',
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.blue,
                          cardColor: cardColor,
                          textColor: textColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen())),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          context,
                          title: 'คำอธิบายการใช้งาน',
                          icon: Icons.menu_book_rounded,
                          iconColor: Colors.orange,
                          cardColor: cardColor,
                          textColor: textColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DescriptionScreen())),
                        ),
                        const SizedBox(height: 16),
                        
                        // --- ติดต่อหน่วยงานไฟฟ้า ---
                        _buildSettingItem(
                          context,
                          title: 'ติดต่อหน่วยงานไฟฟ้า',
                          icon: Icons.support_agent_rounded,
                          iconColor: Colors.teal,
                          cardColor: cardColor,
                          textColor: textColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingContactScreen())),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // --- ออกจากระบบ ---
                        _buildLogoutButton(context, isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ส่งสีข้อความแบบ Dynamic เข้ามาด้วย
  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withOpacity(0.2), // โปร่งแสงนิดๆ จะสวยกว่าในโหมดมืด
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
              onPressed: () {
                if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'การตั้งค่า',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
      ),
    );
  }

  // ✅ เปลี่ยนจาก SnackBar เป็นการสั่งเปลี่ยนธีมจริงๆ
  Widget _buildThemeItem(ThemeProvider themeProvider, Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor, // สีการ์ด Dynamic
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.dark_mode_rounded, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 16),
              Text('โหมดกลางคืน ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            ],
          ),
          Switch(
            value: themeProvider.isDarkMode, // ดึงสถานะเปิด/ปิด จาก Provider
            activeColor: _primaryDark,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value); // สั่งสลับโหมดทันที!
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color iconColor, 
    required Color cardColor, 
    required Color textColor, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor, // สีการ์ด Dynamic
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    // ปรับสีพื้นหลังปุ่มแดงให้เข้ากับโหมดมืด
    final bgColor = isDark ? Colors.red.withOpacity(0.15) : const Color(0xFFFEF2F2);

    return InkWell(
      onTap: () async {
        try {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); 
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เกิดข้อผิดพลาดในการออกจากระบบ'), backgroundColor: Colors.red),
          );
        }
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: double.infinity,
        height: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Text('ออกจากระบบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
