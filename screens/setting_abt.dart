import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรงกับของคุณ)

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  // ── Palette (คุมโทน PikaWatt) ────────────────
  static const Color _primary      = Color(0xFFFFC926); 
  static const Color _primaryDark  = Color(0xFFF59E0B); 

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
          // พื้นหลัง Gradient แบบเดียวกับหน้าอื่นๆ
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: topGradient, // ✅
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- Header ---
              _buildHeader(context, textColor, isDark),

              // --- Content Area ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor, // ✅
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
                    child: Column(
                      children: [
                        // --- ส่วนโลโก้แอป ---
                        _buildAppLogo(textColor, textMid, isDark),
                        const SizedBox(height: 32),

                        // --- ส่วนข้อมูล ---
                        _buildInfoCard(
                          icon: Icons.code_rounded,
                          iconColor: Colors.blue,
                          title: 'ผู้พัฒนา',
                          content: 'พุฒิสรรค์ ขมิ้นเครือ\nภูริณัฐ เขียวสังข์',
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoCard(
                          icon: Icons.school_rounded,
                          iconColor: Colors.purple,
                          title: 'รายวิชา',
                          content: 'ITDS283:\nMobile Application Development',
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.calendar_month_rounded,
                          iconColor: Colors.green,
                          title: 'ปีการศึกษา',
                          content: '2568',
                          cardColor: cardColor,
                          textColor: textColor,
                          textMid: textMid,
                          isDark: isDark,
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

  // --- Header Widget ---
  Widget _buildHeader(BuildContext context, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? Colors.white10 : Colors.white.withOpacity(0.35), // ✅
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18), // ✅
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'เกี่ยวกับ PikaWatt',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w800, 
              color: textColor, // ✅
              letterSpacing: -0.5
            ),
          ),
        ],
      ),
    );
  }

  // --- โลโก้แอป ---
  Widget _buildAppLogo(Color textColor, Color textMid, bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252545) : Colors.white, // ✅
            shape: BoxShape.circle,
            border: Border.all(color: _primary.withOpacity(0.5), width: 4),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.4) : _primaryDark.withOpacity(0.2), // ✅
                blurRadius: 20, 
                offset: const Offset(0, 10)
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, size: 50, color: _primaryDark),
          ),
        ),
        const SizedBox(height: 16),
        Text('PikaWatt', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1)), // ✅
        const SizedBox(height: 4),
        Text('เวอร์ชัน 1.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMid)), // ✅
      ],
    );
  }

  // --- กล่องข้อมูล (Cards) ---
  Widget _buildInfoCard({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String content,
    required Color cardColor,
    required Color textColor,
    required Color textMid,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // ✅
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03), // ✅
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2), // ดันให้ชื่อหัวข้อตรงกับไอคอน
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textMid)), // ✅
                const SizedBox(height: 6),
                Text(
                  content, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor, height: 1.5) // ✅
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
