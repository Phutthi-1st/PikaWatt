import 'package:flutter/material.dart';
import 'models/calculation_history.dart'; // import model ที่เราสร้างไว้

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Mock Data: ข้อมูลสมมติสำหรับทำ Front-end (รอเปลี่ยนเป็นข้อมูลจาก Back-end ทีหลัง) ---
    final List<CalculationHistory> historyList = [
      CalculationHistory(
        id: '1',
        title: 'เครื่องปรับอากาศ LG 12000 BTU',
        usageHours: 8.0,
        costPerMonth: '1,234',
        costPerYear: '111,234',
      ),
      CalculationHistory(
        id: '2',
        title: 'ตู้เย็น 2 ประตู 14 คิว',
        usageHours: 24.0,
        costPerMonth: '450',
        costPerYear: '5,400',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Logo & Name
            _buildHeader(),
            
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'พลังงานที่คำนวณ ล่าสุด',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- ส่วนกระดานประวัติ (Dynamic ListView) ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          return _buildCalculationCard(historyList[index]);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildStartButton(),
                    const SizedBox(height: 20),
                    _buildEnergyTip(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Widget Components ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('pictures/PikaWatt_Logo.png', height: 50),
          const SizedBox(width: 10),
          const Text(
            'PikaWatt',
            style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard(CalculationHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.blue, size: 30),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(history.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('ใช้งานวันละ ${history.usageHours} ชม.', style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const Divider(height: 25),
            _rowInfo(Icons.monetization_on_outlined, 'ค่าไฟต่อเดือน:', history.costPerMonth),
            const SizedBox(height: 8),
            _rowInfo(Icons.bar_chart, 'ค่าไฟต่อปี:', history.costPerYear),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEDBF),
                foregroundColor: Colors.brown,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ดูรายละเอียด', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        Text('$value บาท', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bolt, color: Colors.black, size: 30),
            SizedBox(width: 10),
            Text('เริ่มคำนวณค่าไฟ', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDFFFD6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Quick Energy Tip\nการล้างแอร์ทุก 6 เดือน ช่วยลดค่าไฟได้ 5-10%',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.orange,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
      ],
    );
  }
}