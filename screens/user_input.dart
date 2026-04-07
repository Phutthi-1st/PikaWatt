import 'package:flutter/material.dart';

class UsageSettingScreen extends StatefulWidget {
  const UsageSettingScreen({super.key});

  @override
  State<UsageSettingScreen> createState() => _UsageSettingScreenState();
}

class _UsageSettingScreenState extends State<UsageSettingScreen> {
  String? _selectedType = 'หอพัก'; 
  double _usageHours = 13.0; 
  final List<bool> _selectedDays = List.generate(7, (index) => true); 
  final List<String> _dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  // --- เพิ่ม Controller สำหรับค่าไฟกำหนดเอง ---
  final TextEditingController _customRateController = TextEditingController(text: '0.0');
  int _currentNavIndex = 0;

  // ฟังก์ชันคำนวณเรทที่จะนำไปแสดงผลและใช้งาน
  double get _currentRate {
    if (_selectedType == 'บ้าน') return 4.42; // เรทบ้านเฉลี่ย
    if (_selectedType == 'หอพัก') return 7.0;  // เรทหอพัก
    return double.tryParse(_customRateController.text) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // ตรวจสอบความพร้อม: เลือกประเภท, ชั่วโมง > 0, และถ้าเลือกกำหนดเองต้องกรอกเลข > 0
    bool isReady = _selectedType != null && 
                   _usageHours > 0 && 
                   (_selectedType != 'กำหนดเอง' || _currentRate > 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'กำหนดการใช้งาน',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เลือกรูปแบบที่อยู่อาศัย',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              _buildTypeSelector(),
              const SizedBox(height: 25),
              
              _buildHourSlider(),
              const SizedBox(height: 25),
              
              _buildDayPicker(), 
              const SizedBox(height: 30),
              
              // --- ส่วนแสดงเรทค่าไฟและช่องกรอก Custom ---
              _buildRateSection(),
              const SizedBox(height: 35),
              
              _buildSubmitButton(isReady, args),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        children: [
          _typeItem(Icons.home_outlined, 'บ้าน'),
          const Divider(height: 1, indent: 60),
          _typeItem(Icons.apartment_outlined, 'หอพัก'),
          const Divider(height: 1, indent: 60),
          _typeItem(Icons.tune_outlined, 'กำหนดเอง'),
        ],
      ),
    );
  }

  Widget _typeItem(IconData icon, String title) {
    return RadioListTile<String>(
      value: title,
      groupValue: _selectedType,
      activeColor: Colors.amber,
      title: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        ],
      ),
      onChanged: (value) => setState(() {
        _selectedType = value;
      }),
    );
  }

  // --- ส่วนแสดงเรทค่าไฟแบบใหม่ ---
  Widget _buildRateSection() {
    return Column(
      children: [
        // แสดงช่องกรอกเมื่อเลือก "กำหนดเอง" เท่านั้น
        if (_selectedType == 'กำหนดเอง')
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              controller: _customRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
              decoration: InputDecoration(
                labelText: 'ระบุค่าไฟต่อหน่วยของคุณ',
                hintText: '0.00',
                suffixText: 'บาท / หน่วย',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() {}), // อัปเดต UI เมื่อพิมพ์
            ),
          ),
        
        // แถบโชว์ค่าไฟที่สรุปแล้ว
Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_outlined, size: 22, color: Colors.black54),
          const SizedBox(width: 10),
          const Text(
            'อัตราค่าไฟที่ใช้คำนวณ:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          
          // --- ส่วนที่แก้ไข: Container คลุมเฉพาะตัวเลข ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE58F), // สีเหลืองตามรูป
              borderRadius: BorderRadius.circular(12), // ขอบมน
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_currentRate.toStringAsFixed(2)} /หน่วย',
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      ],
    );
  }

  Widget _buildHourSlider() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ชั่วโมงการใช้งานต่อวัน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_usageHours.toInt()} ชั่วโมง', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Slider(
            value: _usageHours,
            min: 0, max: 24,
            activeColor: Colors.amber,
            onChanged: (val) => setState(() => _usageHours = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          return GestureDetector(
            onTap: () => setState(() => _selectedDays[index] = !_selectedDays[index]),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _selectedDays[index] ? Colors.amber : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(_dayLabels[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ),
    );
  }

Widget _buildSubmitButton(bool isReady, Map<String, dynamic>? args) {
    return InkWell(
      onTap: isReady ? () {
        // 1. คำนวณจำนวนวันที่เลือกใน 1 สัปดาห์
        int activeDays = _selectedDays.where((d) => d).length;
        
        // 2. เปลี่ยนการส่งค่าให้ตรงกับที่หน้า CompareScreen ต้องการ
        // เราจะส่งข้อมูลสินค้าปัจจุบันไปในชื่อ 'productA'
        Navigator.pushNamed(context, '/compare', arguments: {
          'productA': {
            'brand': args?['brand'] ?? 'ไม่ระบุ',
            'model': args?['model'] ?? 'ไม่ระบุ',
            'watt': args?['watt'] ?? 0,
            'hours': _usageHours.toInt(),
            'daysPerWeek': activeDays,
            'rate': _currentRate,
          },
          // ส่ง 'productB' เป็น null ไปก่อนในครั้งแรก เพื่อให้ปุ่ม "เลือกรุ่น B" ปรากฏ
          'productB': null, 
          
          // ส่งค่ากลางอื่นๆ ไปด้วย (ถ้าต้องการใช้ในหน้าเปรียบเทียบ)
          'hours': _usageHours.toInt(),
          'rate': _currentRate,
        });
      } : null,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: isReady 
            ? const LinearGradient(colors: [Color(0xFFFFD147), Color(0xFFF7941D)])
            : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: const Center(
          child: Text(
            'บันทึกและคำนวณค่า', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      selectedItemColor: Colors.amber[800],
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'หน้าหลัก'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'ตั้งค่า'),
      ],
    );
  }
}
