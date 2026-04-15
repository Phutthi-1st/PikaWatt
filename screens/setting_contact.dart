import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรงกับของคุณ)

class SettingContactScreen extends StatelessWidget {
  const SettingContactScreen({super.key});

  // ฟังก์ชันสำหรับเปิดเว็บไซต์
  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ฟังก์ชันสำหรับโทรออก
  Future<void> _launchPhone(String phoneNumber, BuildContext context) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเปิดหน้าโทรศัพท์ได้'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌗 ดึงค่า Theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 ตั้งค่าสี Dynamic
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);
    
    // Gradient ด้านบน
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
            colors: topGradient, // ✅ ใช้สี Gradient ตามโหมด
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isDark ? Colors.white10 : Colors.white.withOpacity(0.35), // ✅ ปรับสีปุ่ม Back
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'ติดต่อหน่วยงานไฟฟ้า',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),

              // --- ส่วนเนื้อหา ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor, // ✅ ใช้สีพื้นหลังตามโหมด
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 40),
                    child: Column(
                      children: [
                        // ไอคอนตกแต่งด้านบน
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent_rounded, size: 50, color: Colors.teal),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'ช่องทางช่วยเหลือและแจ้งปัญหา',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor), // ✅
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'เลือกหน่วยงานที่คุณต้องการติดต่อ\nระบบจะพาคุณไปยังเว็บไซต์หรือโทรออกทันที',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: textMid, height: 1.5), // ✅
                        ),
                        const SizedBox(height: 32),

                        // --- การ์ดติดต่อ กฟผ. ---
                        _buildContactCard(
                          title: 'เว็บไซต์ กฟผ. (ฉลากเบอร์ 5)',
                          subtitle: 'เช็คข้อมูลเครื่องใช้ไฟฟ้าประหยัดพลังงาน',
                          icon: Icons.language_rounded,
                          color: Colors.blue,
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                          onTap: () => _launchURL('https://labelno5.egat.co.th/', context),
                        ),
                        const SizedBox(height: 16),
                        
                        // --- การ์ดติดต่อ กฟผ. (เบอร์โทร) ---
                        _buildContactCard(
                          title: 'สายด่วน กฟผ. (EGAT)',
                          subtitle: 'ผลิตไฟฟ้า & แจ้งเรื่องฉลากเบอร์ 5',
                          icon: Icons.phone_in_talk_rounded,
                          color: Colors.blueAccent,
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                          onTap: () => _launchPhone('1416', context),
                        ),
                        const SizedBox(height: 16),

                        // --- การ์ดติดต่อ กฟน. ---
                        _buildContactCard(
                          title: 'สายด่วน กฟน. (MEA)',
                          subtitle: 'แจ้งไฟขัดข้อง กรุงเทพฯ นนทบุรี สมุทรปราการ',
                          icon: Icons.phone_in_talk_rounded,
                          color: Colors.deepOrange,
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                          onTap: () => _launchPhone('1130', context),
                        ),
                        const SizedBox(height: 16),

                        // --- การ์ดติดต่อ กฟภ. ---
                        _buildContactCard(
                          title: 'สายด่วน กฟภ. (PEA)',
                          subtitle: 'แจ้งไฟขัดข้อง ส่วนภูมิภาค/ต่างจังหวัด',
                          icon: Icons.phone_in_talk_rounded,
                          color: Colors.purple,
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                          onTap: () => _launchPhone('1129', context),
                        ),
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

  // Widget สร้างการ์ดปุ่มกดติดต่อ (ส่งตัวแปรสีเข้ามารับค่า)
  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color textMid,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor, // ✅
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), // ✅
              blurRadius: 15, 
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)), // ✅
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textMid)), // ✅
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)), // ✅
          ],
        ),
      ),
    );
  }
}