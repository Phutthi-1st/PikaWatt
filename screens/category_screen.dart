import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรงกับของคุณ)

class ApplianceCategoryScreen extends StatelessWidget {
  const ApplianceCategoryScreen({super.key});

  // ── Palette (ดึงเฉพาะสีหลักๆ ที่ยังคงที่ไว้) ────────────────
  static const Color _primary     = Color(0xFFFFC926);
  static const Color _primaryDark = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    // 🌗 ดึงสถานะธีมปัจจุบัน
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 ตั้งค่าสีแบบ Dynamic
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isSelectingB = args?['isSelectingB'] == true;

    final List<Map<String, dynamic>> categories = [
      {'name': 'เครื่องปรับอากาศ', 'icon': Icons.ac_unit_rounded,             'id': 'air_conditioner'},
      {'name': 'ตู้เย็น',           'icon': Icons.kitchen_rounded,             'id': 'refrigerator'},
      {'name': 'โทรทัศน์',          'icon': Icons.tv_rounded,                  'id': 'television'},
      {'name': 'พัดลม',             'icon': Icons.air_rounded,                 'id': 'fan'},
      {'name': 'เครื่องซักผ้า',     'icon': Icons.local_laundry_service_rounded,'id': 'washing_machine'},
      {'name': 'เครื่องครัว',       'icon': Icons.microwave_rounded,           'id': 'household'},
    ];

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: topGradient, // ✅ เปลี่ยน Gradient ตามโหมด
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(isDark ? 0.15 : 0.35),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      isSelectingB ? 'เลือกหมวดหมู่รุ่น B' : 'หมวดหมู่ไฟฟ้า',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor, // ✅ เปลี่ยนสีตามโหมด
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Grid ──────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor, // ✅ เปลี่ยนสีพื้นหลังขาว/กรมท่า
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return _buildCategoryCard(
                        context,
                        item['name'],
                        item['icon'],
                        item['id'],
                        args,
                        isDark, // ✅ ส่งสถานะโหมดไปให้การ์ด
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    String categoryId,
    Map<String, dynamic>? args,
    bool isDark,
  ) {
    // 🎨 ตั้งค่าสีของการ์ดในโหมดมืดและสว่าง
    final cardBgColor = isDark ? const Color(0xFF252545) : Colors.white;
    final cardTextColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    // ในโหมดมืด จะเปลี่ยนเงาให้เป็นสีดำเข้มแทน
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06);
    // ไอคอนวงกลมด้านใน ในโหมดมืดปรับสีให้หม่นลงนิดนึงจะได้ไม่สว่างแยงตา
    final iconBgColor = isDark ? _primary.withOpacity(0.1) : _primary.withOpacity(0.18);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/model_selection',
              arguments: {...?args, 'categoryName': title, 'categoryId': categoryId},
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _primaryDark, size: 34),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cardTextColor, // ✅ ตัวอักษรสีขาว/ดำ
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
