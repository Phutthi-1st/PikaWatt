import 'package:flutter/material.dart';

class ApplianceCategoryScreen extends StatelessWidget {
  const ApplianceCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // รายชื่อหมวดหมู่ พร้อมไอคอนและสีสลับ
    final List<Map<String, dynamic>> categories = [
      {'name': 'เครื่องปรับอากาศ', 'icon': Icons.air, 'isDark': false},
      {'name': 'ตู้เย็น', 'icon': Icons.kitchen_outlined, 'isDark': true},
      {'name': 'โทรทัศน์', 'icon': Icons.tv_outlined, 'isDark': false},
      {'name': 'พัดลม', 'icon': Icons.air, 'isDark': true},
      {'name': 'เครื่องซักผ้า', 'icon': Icons.local_laundry_service_outlined, 'isDark': false},
      {'name': 'เครื่องใช้ไฟฟ้าในครัว', 'icon': Icons.microwave_outlined, 'isDark': true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A), // สีเหลืองหลักส่วนบน
      body: SafeArea(
        child: Column(
          children: [
            // --- ส่วนหัว (AppBar จำลอง) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'ประเภทเครื่องใช้ไฟฟ้า',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- พื้นหลังสีขาวเทาขอบโค้ง ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return _buildCategoryButton(
                      context,
                      item['name'],
                      item['icon'],
                      item['isDark'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: ปุ่มหมวดหมู่แบบ Custom
  Widget _buildCategoryButton(BuildContext context, String title, IconData icon, bool isLightYellow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 60,
      decoration: BoxDecoration(
        color: isLightYellow ? const Color(0xFFFFF1C1) : const Color(0xFFFFCC4D),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // ดึงค่า Arguments เดิมที่ติดตัวมาจากหน้า Compare (ถ้ามี)
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          Navigator.pushNamed(
            context, 
            '/model_selection', 
            arguments: {
              ...?args, // คัดลอกข้อมูลเดิมทั้งหมด (isSelectingB, productA, hours, rate)
              'categoryName': title, // *** แก้ตรงนี้: ใช้ title แทน categories['name'] ***
            },
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

}