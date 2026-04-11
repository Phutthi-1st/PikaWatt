import 'package:flutter/material.dart';

class CalculationResultScreen extends StatefulWidget {
  const CalculationResultScreen({super.key});

  @override
  State<CalculationResultScreen> createState() => _CalculationResultScreenState();
}

class _CalculationResultScreenState extends State<CalculationResultScreen> {
  // เริ่มต้นที่ 'เดือน' ตามรูปภาพ
  String _selectedPeriod = 'เดือน';
  
  @override
  Widget build(BuildContext context) {
    // 1. ดึงค่า Arguments (brand, model, watt, hours)
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final double watt = double.tryParse(args?['watt']?.toString() ?? '0') ?? 0.0;
    final double hours = double.tryParse(args?['hours']?.toString() ?? '0') ?? 0.0;
    
    // อัตราค่าไฟ (7 บาท/หน่วย ตามที่ตั้งไว้)
    const double rate = 7.0;

    // 2. Logic การคำนวณพลังงาน (kWh)
    double dailyKwh = (watt / 1000) * hours;
    double monthlyKwh = dailyKwh * 30;
    double yearlyKwh = dailyKwh * 365;

    // 3. Logic การคำนวณราคา (บาท) ตามช่วงเวลาที่เลือก
    double displayCost;
    if (_selectedPeriod == 'วัน') {
      displayCost = dailyKwh * rate;
    } else if (_selectedPeriod == 'เดือน') {
      displayCost = monthlyKwh * rate;
    } else {
      displayCost = yearlyKwh * rate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFD147), // สีเหลืองด้านบน
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ผลการคำนวณ', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB), // สีพื้นหลังครีม
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              // หัวข้อ: ค่าไฟรวม + ไอคอนสายฟ้า
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD147),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 35),
                  ),
                  const SizedBox(width: 15),
                  const Text('ค่าไฟรวม', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // การ์ดแสดงตัวเลขหลัก (สีขาวขอบมน)
              _buildMainCostCard(displayCost),

              const SizedBox(height: 25),

              // การ์ดแสดงการใช้พลังงาน (kWh)
              _buildEnergyUsageCard(dailyKwh, monthlyKwh, yearlyKwh),

              const SizedBox(height: 25),

              // ปุ่มเปรียบเทียบ (สีม่วงอ่อน)
              _buildCompareButton(args),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar ที่เพิ่มฟังก์ชันกดได้จริง
    );
  }

  // --- Widget: การ์ดตัวเลขใหญ่ + ตัวเลือก วัน/เดือน/ปี ---
  Widget _buildMainCostCard(double cost) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD), 
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Text(cost.toStringAsFixed(0), 
                  style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
                Text('ประมาณค่าไฟต่อ$_selectedPeriod', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE58F),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: ['วัน', 'เดือน', 'ปี'].map((p) {
                bool isSelected = _selectedPeriod == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(p, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: isSelected ? Colors.black : Colors.black54
                        )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: การ์ดแสดงรายละเอียด kWh ---
  Widget _buildEnergyUsageCard(double d, double m, double y) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.orange, size: 25),
              SizedBox(width: 10),
              Text('การใช้พลังงาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          _usageRow('${d.toStringAsFixed(1)} kWh', 'วัน'),
          _usageRow('${m.toStringAsFixed(1)} kWh', 'เดือน'),
          _usageRow('${y.toStringAsFixed(1)} kWh', 'ปี'),
        ],
      ),
    );
  }

  Widget _usageRow(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

  // --- Widget: ปุ่มเปรียบเทียบ ---
  Widget _buildCompareButton(Map<String, dynamic>? args) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/compare', arguments: {'productA': args});
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, color: Colors.indigo, size: 30),
            SizedBox(width: 15),
            Text('เปรียบเทียบ', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }
}