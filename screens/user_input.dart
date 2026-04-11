import 'package:flutter/material.dart';

class UsageSettingScreen extends StatefulWidget {
  const UsageSettingScreen({super.key});

  @override
  State<UsageSettingScreen> createState() => _UsageSettingScreenState();
}

class _UsageSettingScreenState extends State<UsageSettingScreen> {
  // --- 1. ปรับค่าเริ่มต้นเป็น 0 หรือ null ทั้งหมด ---
  String? _selectedType; // ยังไม่เลือกที่พัก
  double _usageHours = 0.0; // เริ่มต้นที่ 0 ชม.
  final List<bool> _selectedDays = List.generate(7, (index) => false); // ยังไม่เลือกวันเลย
  final List<String> _dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  final TextEditingController _customRateController = TextEditingController(text: '0.0');

  double get _currentRate {
    if (_selectedType == 'บ้าน') return 4.42;
    if (_selectedType == 'หอพัก') return 7.0;
    return double.tryParse(_customRateController.text) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // --- 2. ปรับเงื่อนไขความพร้อม (isReady) ---
    // ต้องนับว่ามีการเลือกวันอย่างน้อย 1 วันไหม
    int activeDays = _selectedDays.where((day) => day).length;

    bool isReady = _selectedType != null && 
                   _usageHours > 0 && 
                   activeDays > 0 && 
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
              
              _buildRateSection(),
              const SizedBox(height: 35),
              
              _buildSubmitButton(isReady, args, activeDays), // ส่ง activeDays เข้าไป
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- ส่วนของ Widget ต่างๆ (ใช้โค้ดเดิมของคุณ แต่จะทำงานสัมพันธ์กับค่า 0 อัตโนมัติ) ---

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
      onChanged: (value) => setState(() => _selectedType = value),
    );
  }

  Widget _buildHourSlider() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ชั่วโมงการใช้งานต่อวัน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_usageHours.toInt()} ชั่วโมง', 
                   style: TextStyle(
                     fontWeight: FontWeight.bold, 
                     fontSize: 18, 
                     color: _usageHours == 0 ? Colors.grey : Colors.black // ถ้าเป็น 0 ให้เป็นสีเทา
                   )),
            ],
          ),
          Slider(
            value: _usageHours,
            min: 0, max: 24,
            divisions: 24, // เพิ่มขีดแบ่งเพื่อให้เลือกง่ายขึ้น
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
              child: Text(_dayLabels[index], 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedDays[index] ? Colors.black : Colors.black45
                          )),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRateSection() {
    return Column(
      children: [
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
              onChanged: (val) => setState(() {}),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active_outlined, size: 22, color: Colors.black54),
            const SizedBox(width: 10),
            const Text('อัตราค่าไฟที่ใช้คำนวณ:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedType == null ? Colors.grey[300] : const Color(0xFFFFE58F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentRate.toStringAsFixed(2)} /หน่วย',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isReady, Map<String, dynamic>? args, int activeDays) {
    return InkWell(
      onTap: isReady ? () {
        Navigator.pushNamed(context, '/compare', arguments: {
          'productA': {
            'brand': args?['productA']?['brand'] ?? args?['brand'] ?? 'ไม่ระบุ',
            'model': args?['productA']?['model'] ?? args?['model'] ?? 'ไม่ระบุ',
            'watt': args?['productA']?['watt'] ?? args?['watt'] ?? 0,
            'hours': _usageHours.toInt(),
            'daysPerWeek': activeDays,
            'rate': _currentRate,
          },
          'productB': null,
          'hours': _usageHours.toInt(),
          'rate': _currentRate,
          'daysPerWeek': activeDays,
        });
      } : null,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: isReady 
            ? const LinearGradient(colors: [Color(0xFFFFD147), Color(0xFFFFCC33)])
            : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
          boxShadow: [if (isReady) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Text(
            'บันทึกและคำนวณค่า', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isReady ? Colors.black : Colors.black38)
          ),
        ),
      ),
    );
  }
}