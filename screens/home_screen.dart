import 'package:flutter/material.dart';
import '/models/calculation_history.dart';
import 'category_screen.dart';
import 'history_screen.dart';
import 'setting.dart';
import 'dart:math';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

// ส่วนของ State (จัดการข้อมูลและการสุ่ม Tips)
class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool isExpanded = false;
  int _currentIndex = 0; // เก็บสถานะหน้าปัจจุบัน

  final CalculationHistory latestHistory = CalculationHistory(
    id: '1',
    title: 'เครื่องปรับอากาศ LG 12000 BTU',
    usageHours: 8.0,
    costPerMonth: '1,234',
    costPerYear: '111,234',
    date: DateTime.now()
  );

  final List<String> _energyTips = [
    'การล้างแอร์ทุก 6 เดือน ช่วยลดค่าไฟได้ 5-10%',
    'ปิดไฟดวงที่ไม่ใช้งาน ช่วยประหยัดค่าไฟและถนอมหลอดไฟ',
    'ถอดปลั๊กเครื่องใช้ไฟฟ้าเมื่อไม่ใช้งาน ป้องกันไฟรั่วไหล',
    'เลือกใช้หลอดไฟ LED แทนหลอดไส้ ประหยัดไฟได้มากกว่า 80%',
    'ตั้งอุณหภูมิแอร์ที่ 25-26 องศา เป็นช่วงที่ประหยัดพลังงานที่สุด',
    'เปิดหน้าต่างรับลมธรรมชาติแทนการเปิดแอร์ในวันที่อากาศดี',
    'ไม่ควรนำของร้อนเข้าตู้เย็น เพราะจะทำให้คอมเพรสเซอร์ทำงานหนัก',
  ];

  // ในไฟล์ home_screen.dart (หรือ HomeDashboardScreen)
  @override
  Widget build(BuildContext context) {
    // ย้าย List ของหน้ามาไว้ใน build เพื่อให้ดึง currentIndex ล่าสุดได้เสมอ
    final List<Widget> _pages = [
      _buildMainDashboard(), 
      const HistoryScreen(),
      // ส่งฟังก์ชัน setState ไปเพื่อให้หน้า Setting สั่งเปลี่ยนหน้ากลับมาที่ Index 0 ได้
      SettingsScreen(onBackToHome: () {
        setState(() {
          _currentIndex = 0; 
        });
      }),
    ];

    return Scaffold(
      // กำหนดสีพื้นหลังพื้นฐานเพื่อไม่ให้เห็นขอบขาวเวลาสลับหน้า
      backgroundColor: const Color(0xFFF2F2F2), 
      body: _pages[_currentIndex], 
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- แยกส่วน UI ของ Dashboard เดิมออกมาเป็น Widget ---
  Widget _buildMainDashboard() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(), // ส่วนหัวที่มีโลโก้
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
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'พลังงานที่คำนวณ ล่าสุด',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildHistoryCard(),
                    const SizedBox(height: 30),
                    _buildStartButton(),
                    const SizedBox(height: 40),
                    _buildEnergyTip(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget ส่วนหัว (Header) ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6D36A), Color(0xFFFFE082)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'pictures/PikaWatt_Logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.flash_on, size: 50, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              const Text(
                'PikaWatt',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget การ์ดประวัติ ---
  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Colors.lightBlue, size: 35),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(latestHistory.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('ใช้งานวันละ ${latestHistory.usageHours} ชม.', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          _rowInfo(Icons.monetization_on_outlined, 'ค่าไฟต่อเดือน:', latestHistory.costPerMonth),
          const SizedBox(height: 10),
          _rowInfo(Icons.bar_chart, 'ค่าไฟต่อปี:', latestHistory.costPerYear),
          if (isExpanded) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF9E7), borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _rowDetail('ใช้ไฟต่อชั่วโมง:', '1.25 ยูนิต'),
                  _rowDetail('ใช้ไฟต่อวัน:', '10.00 ยูนิต'),
                ],
              ),
            )
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => isExpanded = !isExpanded),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF3D7),
                foregroundColor: Colors.brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(isExpanded ? 'ปิดรายละเอียด' : 'ดูรายละเอียด', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget ปุ่มเริ่มคำนวณ ---
  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApplianceCategoryScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bolt, color: Colors.orange, size: 35),
            SizedBox(width: 10),
            Text('เริ่มคำนวณค่าไฟ', style: TextStyle(color: Color(0xFF333333), fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- Widget แถบเมนูด้านล่าง ---
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.black54,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // เปลี่ยนหน้าเมื่อกดปุ่ม
            }); 
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
          ],
        ),
      ),
    );
  }

  // ส่วนประกอบ UI เล็กๆ อื่นๆ
  Widget _buildEnergyTip() {
    // ใช้ Random เพื่อสุ่มลำดับใน List
    final randomTip = _energyTips[Random().nextInt(_energyTips.length)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FCD9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ใส่แอนิเมชั่นเบาๆ หรือ Icon สีสดใส
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Energy Tip',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  randomTip, // แสดงข้อความที่สุ่มมา
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 10),
        Text(label),
        const Spacer(),
        Text('$value บาท', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _rowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}