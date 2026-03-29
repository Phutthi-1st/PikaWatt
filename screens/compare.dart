import 'package:flutter/material.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  // สถานะสำหรับปุ่มสลับช่วงเวลา (วัน/เดือน/ปี)
  String _selectedPeriod = 'วัน';
  int _currentNavIndex = 0; // สำหรับจัดการ BottomNav

  @override
  Widget build(BuildContext context) {
    // --- 1. ดึงข้อมูล Arguments จากหน้าก่อนหน้า ---
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    
    final Map<String, dynamic>? productA = args?['productA'];
    final Map<String, dynamic>? productB = args?['productB'];

    // ดึงค่า Watt และ Hours
    final double wattA = double.tryParse(productA?['watt']?.toString() ?? '150') ?? 0.0;
    final double wattB = double.tryParse(productB?['watt']?.toString() ?? '120') ?? 0.0;
    final double hours = double.tryParse(productA?['hours']?.toString() ?? '6') ?? 0.0;
    const double rate = 7.0; // อัตราค่าไฟ

    // --- 2. Logic การคำนวณตามช่วงเวลาที่เลือก ---
    double multiplier = 1.0;
    if (_selectedPeriod == 'เดือน') multiplier = 30.0;
    if (_selectedPeriod == 'ปี') multiplier = 365.0;

    double costA = ((wattA / 1000) * hours * rate) * multiplier;
    double costB = ((wattB / 1000) * hours * rate) * multiplier;

    // คำนวณส่วนต่างและเปอร์เซ็นต์
    double costDifference = costA - costB;
    double savingPercent = costA > 0 ? (costDifference / costA) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFD147), // สีเหลืองหลัก
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เปรียบเทียบ', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // --- ส่วนที่ 1: ปุ่มสลับ วัน/เดือน/ปี ---
              _buildPeriodSwitcher(),
              const SizedBox(height: 30),

              // --- ส่วนที่ 2: VS Section ---
              _buildVSSection(productA, productB, costA, costB),
              const SizedBox(height: 30),

              // --- ส่วนที่ 3: การ์ดสรุปผลการประหยัด ---
              _buildSavingCard(costDifference, savingPercent),
              const SizedBox(height: 25),

              // --- ส่วนที่ 4: การ์ดคืนทุน ---
              _buildPaybackCard(),
              const SizedBox(height: 30),

              // --- ส่วนที่ 5: ปุ่ม ACTION เลือกรุ่น B ---
              _buildSelectBButton(context, productA),

              const SizedBox(height: 15),
              _buildFooterInfo(hours, rate),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(), // แก้ไขให้เหมือนหน้าอื่น
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                  color: isSelected ? const Color(0xFFFFD147) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVSSection(Map<String, dynamic>? pA, Map<String, dynamic>? pB, double costA, double costB) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildProductInfo(pA?['brand'] ?? 'รุ่น A', pA?['watt'] ?? '150', costA, Icons.bolt, false),
            const SizedBox(width: 40), 
            _buildProductInfo(pB?['brand'] ?? 'รุ่น B', pB?['watt'] ?? '120', costB, Icons.bolt, true),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white, 
            shape: BoxShape.circle, 
            border: Border.all(color: Colors.green, width: 2),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: const Text('VS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildProductInfo(String brand, dynamic watt, double cost, IconData icon, bool isB) {
    return Expanded(
      child: Column(
        children: [
          Text(brand, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 35,
            backgroundColor: isB ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Icon(icon, size: 40, color: isB ? Colors.green : Colors.orange),
          ),
          const SizedBox(height: 10),
          Text('${cost.toStringAsFixed(0)} บาท', 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('($watt Watt)', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSavingCard(double diff, double percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Text('ประหยัดได้มากกว่า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text('${diff.toStringAsFixed(0)} บาท / $_selectedPeriod', 
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
          Text('ลดลง ${percent.toStringAsFixed(1)}% ต่อ$_selectedPeriod', style: const TextStyle(color: Colors.black54)),
          const Divider(height: 40),
          _buildProgressBar('รุ่น A', 1.0, Colors.orange),
          const SizedBox(height: 15),
          _buildProgressBar('รุ่น B', (100 - percent) / 100, Colors.green),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double val, Color color) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildPaybackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4F5D4), 
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('จุดคืนทุนน่าสนใจ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 4),
                Text('คำนวณจากส่วนต่างราคาเครื่อง', style: TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.eco_outlined, size: 40, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildSelectBButton(BuildContext context, Map<String, dynamic>? pA) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/appliance', arguments: {
          'isSelectingB': true,
          'productA': pA,
        });
      },
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: const LinearGradient(colors: [Color(0xFFFFD147), Color(0xFFF7941D)]),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        alignment: Alignment.center,
        child: const Text('เลือกรุ่น B เพื่อเปรียบเทียบ', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildFooterInfo(double h, double r) {
    return Column(
      children: [
        Text('อ้างอิงการใช้งาน: ${h.toStringAsFixed(0)} ชม./วัน', style: const TextStyle(color: Colors.grey)),
        Text('ค่าไฟเฉลี่ย $r บาท/หน่วย', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        color: const Color(0xFFF7F4EB), 
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            child: BottomNavigationBar(
              currentIndex: _currentNavIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                if (index == 2) Navigator.pushNamed(context, '/settings');
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'หน้าหลัก'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'ประวัติ'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'ตั้งค่า'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}