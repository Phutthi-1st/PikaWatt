import 'package:flutter/material.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD147), // สีเหลืองหลัก
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('คำอธิบาย',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB), // สีครีมอ่อน
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              // --- 1. การ์ดสูตรการคำนวณ ---
              _buildFormulaCard(),
              const SizedBox(height: 25),

              // --- 2. การ์ดคำนวณอธิบายศัพท์ ---
              _buildDefinitionCard(),
              const SizedBox(height: 20), // พื้นที่ด้านล่าง
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Widget สำหรับการ์ดสูตรการคำนวณ
  Widget _buildFormulaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'แอปพลิเคชันนี้ใช้หลักการคำนวณพลังงานไฟฟ้าที่ใช้จากกำลังไฟของอุปกรณ์ และระยะเวลาการใช้งาน โดยมีสูตรดังนี้',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
          SizedBox(height: 20),
          Text('สูตรการคำนวณ',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 15),
          Center(
            // จัดกึ่งกลางสูตร
            child: Text(
                '(กำลังไฟฟ้า × จำนวนชั่วโมงที่ใช้งาน ÷ 1000)\n× ค่าไฟต่อหน่วย',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.6)),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับการ์ดคำอธิบายศัพท์ (วัตต์, ชั่วโมง, บาท)
  Widget _buildDefinitionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('คำอธิบาย',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 20),
          // --- 1. กำลังไฟฟ้า (Watt) ---
          _buildDefinitionItem('กำลังไฟฟ้า (Watt)',
              'คือกำลังไฟที่เครื่องใช้ไฟฟ้าใช้\nเช่น พัดลม 50W หรือ ไดร์เป่าผม 1200W'),
          const SizedBox(height: 20),
          // --- 2. ชั่วโมงการใช้งาน ---
          _buildDefinitionItem('ชั่วโมงการใช้งาน',
              'ระยะเวลาที่เปิดใช้อุปกรณ์ ÷ 1000 เพื่อแปลงจากหน่วย Watt เป็น กิโลวัตต์ชั่วโมง (kWh) ซึ่งเป็นหน่วยที่การไฟฟ้าใช้คิดค่าไฟ'),
          const SizedBox(height: 20),
          // --- 3. ค่าไฟต่อหน่วย ---
          _buildDefinitionItem('ค่าไฟต่อหน่วย',
              'ราคาค่าไฟต่อ 1 kWh ซึ่งผู้ใช้สามารถกำหนดได้ตามอัตราค่าไฟที่ใช้งาน'),
        ],
      ),
    );
  }

  // Widget ช่วยสร้างรายการคำอธิบายศัพท์แต่ละตัว (คงไว้ตัวเดียวพอครับ)
  Widget _buildDefinitionItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content,
            style: const TextStyle(
                fontSize: 15, color: Colors.black87, height: 1.5)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'หน้าหลัก'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'ตั้งค่า'),
      ],
    );
  }
}