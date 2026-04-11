import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE082), // สีเหลืองหลัก
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เกี่ยวกับแอพ', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB), // สีครีมอ่อน
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. ส่วนเวอร์ชัน ---
                _buildInfoSection('เวอร์ชัน 1.0'),
                const Divider(height: 30),

                // --- 2. ส่วนผู้พัฒนา ---
                _buildInfoSection(
                  'ผู้พัฒนา',
                  content: 'พุฒิสรรค์ ขมิ้นเครือ\nภูริณัฐ เขียวสังข์',
                ),
                const Divider(height: 30),

                // --- 3. ส่วนรายวิชา ---
                _buildInfoSection(
                  'รายวิชา',
                  content: 'ITDS283:\nMobile Application Development',
                ),
                const Divider(height: 30),

                // --- 4. ปีการศึกษา ---
                _buildInfoSection('ปีการศึกษา 2568'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างส่วนแสดงข้อมูลแต่ละส่วน
  Widget _buildInfoSection(String title, {String? content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        if (content != null) ...[
          const SizedBox(height: 8),
          Text(content, 
            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)), // เพิ่ม height ให้อ่านง่าย
        ],
      ],
    );
}
}