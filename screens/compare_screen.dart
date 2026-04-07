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
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

  // 1. ดึงข้อมูลสินค้า A และ B
  final Map<String, dynamic>? productA = args?['productA'];
  final Map<String, dynamic>? productB = args?['productB'];

  // 2. ดึงค่ากลาง (Hours และ Rate) ที่ส่งมาจากหน้า Usage/ModelSelection
  // แก้ตรงนี้: ให้ดึงจาก args โดยตรง (เพราะเราส่งแยกมาคู่กับ productA/B)
  final double hours = double.tryParse(args?['hours']?.toString() ?? '0') ?? 0.0;
  final double rate = double.tryParse(args?['rate']?.toString() ?? '4.42') ?? 4.42;

  // 3. ดึงค่า Watt ของแต่ละรุ่น
  final double wattA = double.tryParse(productA?['watt']?.toString() ?? '0') ?? 0.0;
  final double wattB = double.tryParse(productB?['watt']?.toString() ?? '0') ?? 0.0;

  // --- Logic การคำนวณ (คงเดิมไว้ได้เลย) ---
  double multiplier = 1.0;
  if (_selectedPeriod == 'เดือน') multiplier = 30.0;
  if (_selectedPeriod == 'ปี') multiplier = 365.0;

  double costA = ((wattA / 1000) * hours * rate) * multiplier;
  double costB = ((wattB / 1000) * hours * rate) * multiplier;

    // คำนวณส่วนต่างและเปอร์เซ็นต์
    double costDifference = costA - costB;
    double savingPercent = costA > 0 ? (costDifference / costA) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A), // สีเหลืองหลัก
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

              // --- ส่วนที่ 2: VS Section (เพิ่มส่ง productB เข้าไปเช็ค null) ---
              _buildVSSection(productA, productB, costA, costB),
              const SizedBox(height: 30),

              _buildSavingCard(costDifference, savingPercent),
              const SizedBox(height: 25),

              _buildPaybackCard(savingPercent),
              const SizedBox(height: 30),

              // --- ส่วนที่ 5: ปุ่ม ACTION (เพิ่มส่ง hours และ rate เข้าไป) ---
              productB == null 
                ? _buildSelectBButton(context, productA, hours, rate)
                : _buildSaveComparisonButton(context, productA, productB, costA, costB), // ส่งเพิ่ม 4 ตัวนี้

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
                  color: isSelected ? const Color(0xFFF6D36A) : Colors.transparent,
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
          // ส่ง pA เข้าไปตัวสุดท้าย
          _buildProductInfo(pA?['brand'] ?? 'รุ่น A', pA?['watt'] ?? '0', costA, Icons.bolt, false, pA),
          const SizedBox(width: 40), 
          // ส่ง pB เข้าไปตัวสุดท้าย เพื่อให้มันเช็คได้ว่าว่างไหม
          _buildProductInfo(pB?['brand'] ?? 'รุ่น B', pB?['watt'] ?? '0', costB, Icons.bolt, true, pB),
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

  Widget _buildProductInfo(String brand, dynamic watt, double cost, IconData icon, bool isB, Map<String, dynamic>? product) {
  return Expanded(
    child: Column(
      children: [
        // ถ้ายังไม่มีข้อมูลรุ่น B ให้ขึ้นว่า "ยังไม่ได้เลือก"
        Text(
          product == null && isB ? 'ชื่อรุ่น' : brand, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
          textAlign: TextAlign.center
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 35,
          backgroundColor: isB ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          // ถ้ายังไม่มี B ให้ใช้ไอคอนเครื่องหมายคำถามหรือบวก
          child: Icon(
            product == null && isB ? Icons.add : icon, 
            size: 40, 
            color: isB ? Colors.green : Colors.orange
          ),
        ),
        const SizedBox(height: 10),
        // ถ้าไม่มีข้อมูล ให้โชว์ 0 บาท
        Text(
          product == null && isB ? '0 บาท' : '${cost.toStringAsFixed(0)} บาท', 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ],
    ),
  );
}

  Widget _buildSavingCard(double diff, double percent) {
  // 1. สร้าง Logic เช็คสถานะ
  bool isSaving = diff >= 0; // ถ้า diff เป็นบวก แปลว่า A แพงกว่า B (B ประหยัดกว่า)
  
  // 2. กำหนดข้อความและสีตามสถานะ
  String titleText = isSaving ? 'ประหยัดได้มากกว่า' : 'ค่าไฟเพิ่มขึ้น';
  Color mainColor = isSaving ? Colors.green : Colors.red;
  
  // ปรับค่าส่วนต่างให้เป็นค่าบวกเสมอเพื่อการแสดงผล (ใช้ .abs())
  String diffDisplay = diff.abs().toStringAsFixed(0);
  String percentDisplay = percent.abs().toStringAsFixed(1);

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
        Text(
          titleText, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
        ),
        const SizedBox(height: 5),
        Text(
          '$diffDisplay บาท / $_selectedPeriod', 
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            color: mainColor // ใช้สีที่เปลี่ยนตามสถานะ
          )
        ),
        Text(
          isSaving 
            ? 'ลดลง $percentDisplay% ต่อ$_selectedPeriod' 
            : 'เพิ่มขึ้น $percentDisplay% ต่อ$_selectedPeriod', 
          style: const TextStyle(color: Colors.black54)
        ),
        const Divider(height: 40),
        
        // กราฟ Progress Bar ก็ปรับให้สัมพันธ์กัน
        _buildProgressBar('รุ่น A', 1.0, Colors.orange),
        const SizedBox(height: 15),
        // ถ้าค่าไฟเพิ่มขึ้น ให้ Bar ของรุ่น B ยาวกว่า (หรือแสดงตามสัดส่วนจริง)
        _buildProgressBar('รุ่น B', isSaving ? (100 - percent.abs()) / 100 : (100 + percent.abs()) / 100, isSaving ? Colors.green : Colors.red),
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

Widget _buildPaybackCard(double savingPercent) {
  // Logic เลือกข้อความ Tips
  String tipText = "คำนวณจากส่วนต่างราคาเครื่อง";
  
  if (savingPercent > 30) {
    tipText = "ว้าว! รุ่นนี้ประหยัดไฟกว่าเดิมถึง ${savingPercent.toStringAsFixed(0)}% คุ้มค่าสุดๆ";
  } else if (savingPercent > 0) {
    tipText = "การเลือกวัตต์ที่ต่ำกว่า ช่วยให้คุณมีเงินเหลือเก็บในกระเป๋ามากขึ้น";
  } else {
    tipText = "ลองเช็คฉลากประหยัดไฟเบอร์ 5 เพื่อประสิทธิภาพสูงสุด";
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFD4F5D4), 
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เกร็ดน่ารู้จาก PikaWatt', // เปลี่ยนหัวข้อให้ดูเป็นกันเอง
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
              ),
              const SizedBox(height: 4),
              Text(
                tipText, // แสดงข้อความ Tips ที่เราเลือกไว้
                style: const TextStyle(color: Colors.black87, fontSize: 14)
              ),
            ],
          ),
        ),
        const Icon(Icons.lightbulb_outline, size: 40, color: Colors.green), // เปลี่ยนไอคอนเป็นหลอดไฟไอเดีย
      ],
    ),
  );
}

Widget _buildSelectBButton(BuildContext context, Map<String, dynamic>? pA, double h, double r) {
  return InkWell(
    onTap: () {
      // ส่งค่า Flag ไปว่ากำลังเลือก B และถือข้อมูล A, h, r ติดมือไปด้วย
      Navigator.pushNamed(context, '/category', arguments: {
        'isSelectingB': true,
        'productA': pA,
        'hours': h, // ใช้ h จากหน้าจอนี้
        'rate': r,  // ใช้ r จากหน้าจอนี้
      });
    },
    child: Container(
      // ... UI ปุ่มเหมือนเดิม ...
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: const Color(0xFFFFCC33),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      alignment: Alignment.center,
      child: const Text(
        'เลือกรุ่น B เพื่อเปรียบเทียบ', 
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)
      ),
    ),
  );
}

Widget _buildSaveComparisonButton(
    BuildContext context, 
    Map<String, dynamic>? pA, 
    Map<String, dynamic>? pB, 
    double cA, 
    double cB) { // รับค่าที่ส่งมา
  return InkWell(
    onTap: () {
      // ตรงนี้คือจุดที่จะใส่ Logic เซฟลง Database ในอนาคต
      String title = "${pA?['brand']} vs ${pB?['brand']}";
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกผลการเปรียบเทียบ $title เรียบร้อย!'),
          backgroundColor: Colors.green,
        ),
      );

      // บันทึกเสร็จแล้วกลับหน้า Home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    },
    child: Container(
      // ... UI ปุ่มสีเขียวของคุณ ...
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      alignment: Alignment.center,
      child: const Text(
        'บันทึกผลการเปรียบเทียบ', 
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
      ),
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
