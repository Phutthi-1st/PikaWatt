import 'package:flutter/material.dart';
import '/models/calculation_history.dart'; 

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? expandedId;

  final List<CalculationHistory> historyList = [
    CalculationHistory(id: '1', title: 'เครื่องปรับอากาศ LG 12000 BTU', usageHours: 8.0, costPerMonth: '1,234', costPerYear: '111,234', date: DateTime.now()),
    CalculationHistory(id: '2', title: 'โทรทัศน์ Samsung Q7F 43 นิ้ว', usageHours: 5.0, costPerMonth: '498', costPerYear: '5,976', date: DateTime.now()),
    CalculationHistory(id: '3', title: 'พัดลม Hatari S16M1', usageHours: 14.0, costPerMonth: '216', costPerYear: '2,592', date: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- ส่วนหัว (Header) ปรับขนาดให้เท่ากับหน้าตั้งค่า ---
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6D36A), Color(0xFFFFE082)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // ปรับระยะให้เท่ากับหน้า Setting
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    onPressed: () {
                      // กลับหน้าโฮม (Index 0)
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                  ),
                  const Text(
                    'ประวัติการคำนวณ',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- ส่วนเนื้อหา (History List) ---
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2), // สีเทาอ่อนเดียวกับหน้าโฮมและตั้งค่า
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 100),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                return _buildHistoryCard(historyList[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget การ์ดประวัติ (คงเดิมตาม Logic ของคุณ) ---
  Widget _buildHistoryCard(CalculationHistory item) {
    bool isExpanded = expandedId == item.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFF3D7),
                radius: 25,
                child: const Icon(Icons.flash_on, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('ใช้งานวันละ ${item.usageHours} ชม.', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          _rowInfo(Icons.monetization_on_outlined, 'ค่าไฟต่อเดือน:', '${item.costPerMonth} บาท'),
          const SizedBox(height: 10),
          _rowInfo(Icons.bar_chart, 'ค่าไฟต่อปี:', '${item.costPerYear} บาท'),

          if (isExpanded) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _rowDetail('ใช้ไฟต่อชั่วโมง:', '1.25 ยูนิต'),
                  _rowDetail('ใช้ไฟต่อวัน:', '10.00 ยูนิต'),
                  const Divider(color: Colors.deepOrangeAccent),
                  _rowDetail('ค่าไฟเฉลี่ยต่อวัน:', 'ประมาณ 41.13 บาท'),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                label: const Text('ลบประวัติ', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ),
          ],

          const SizedBox(height: 15),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  expandedId = isExpanded ? null : item.id;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF3D7),
                foregroundColor: Colors.brown,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isExpanded ? 'ปิดรายละเอียด' : 'ดูรายละเอียด',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}