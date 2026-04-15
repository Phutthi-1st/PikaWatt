import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรงกับโปรเจกต์ของคุณ)

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

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
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF0F0F0);
    final highlightBg = isDark ? const Color(0xFF2A2D43) : const Color(0xFFFFF9E7);
    
    // Gradient ด้านบน
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // ✅ ปรับพื้นหลัง Gradient ให้เข้ากับโหมด
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
              // --- Header ---
              _buildHeader(context, textColor, isDark),

              // --- Content Area ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor, // ✅ ปรับสีพื้นหลังเนื้อหา
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 60),
                    child: Column(
                      children: [
                        _buildFormulaCard(cardColor, textColor, textMid, highlightBg, isDark),
                        const SizedBox(height: 24),
                        _buildDefinitionCard(cardColor, textColor, textMid, dividerColor),
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
            backgroundColor: isDark ? Colors.white10 : Colors.white.withOpacity(0.35),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'คำอธิบาย',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w800, 
              color: textColor, 
              letterSpacing: -0.5
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. การ์ดสูตรการคำนวณ ---
  Widget _buildFormulaCard(Color cardColor, Color textColor, Color textMid, Color highlightBg, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _primary.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.calculate_rounded, color: _primaryDark, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'หลักการคำนวณ', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'แอปพลิเคชันนี้ใช้หลักการคำนวณพลังงานไฟฟ้าที่ใช้จากกำลังไฟของอุปกรณ์ และระยะเวลาการใช้งาน โดยมีสูตรดังนี้',
            style: TextStyle(fontSize: 15, color: textMid, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          
          // กล่องไฮไลต์สูตร
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: highlightBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  '( กำลังไฟฟ้า × ชั่วโมงการใช้งาน ÷ 1000 )',
                  style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w700, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Icon(Icons.clear_rounded, size: 20, color: _primaryDark), // เครื่องหมายคูณ
                const SizedBox(height: 8),
                Text(
                  'ค่าไฟต่อหน่วย',
                  style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. การ์ดคำอธิบายศัพท์ ---
  Widget _buildDefinitionCard(Color cardColor, Color textColor, Color textMid, Color dividerColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.menu_book_rounded, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'คำศัพท์ที่ควรรู้', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildDefinitionItem(
            icon: Icons.bolt_rounded,
            iconColor: Colors.orange,
            title: 'กำลังไฟฟ้า (Watt)',
            content: 'คือกำลังไฟที่เครื่องใช้ไฟฟ้าใช้ เช่น พัดลม 50W หรือ ไดร์เป่าผม 1200W',
            textColor: textColor,
            textMid: textMid,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: dividerColor, thickness: 1.5),
          ),
          
          _buildDefinitionItem(
            icon: Icons.schedule_rounded,
            iconColor: Colors.purple,
            title: 'ชั่วโมงการใช้งาน',
            content: 'ระยะเวลาที่เปิดใช้อุปกรณ์ ÷ 1000 เพื่อแปลงจากหน่วย Watt เป็น กิโลวัตต์ชั่วโมง (kWh) ซึ่งเป็นหน่วยที่การไฟฟ้าใช้คิดค่าไฟ',
            textColor: textColor,
            textMid: textMid,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: dividerColor, thickness: 1.5),
          ),
          
          _buildDefinitionItem(
            icon: Icons.payments_rounded,
            iconColor: Colors.green,
            title: 'ค่าไฟต่อหน่วย',
            content: 'ราคาค่าไฟต่อ 1 kWh ซึ่งผู้ใช้สามารถกำหนดได้ตามอัตราค่าไฟที่บ้านหรือหอพักตั้งไว้',
            textColor: textColor,
            textMid: textMid,
          ),
        ],
      ),
    );
  }

  // --- Widget ย่อยสำหรับรายการคำศัพท์ ---
  Widget _buildDefinitionItem({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String content,
    required Color textColor,
    required Color textMid,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: textMid, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
