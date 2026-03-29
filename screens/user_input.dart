import 'package:flutter/material.dart';

class UsageSettingScreen extends StatefulWidget {
  const UsageSettingScreen({super.key});

  @override
  State<UsageSettingScreen> createState() => _UsageSettingScreenState();
}

class _UsageSettingScreenState extends State<UsageSettingScreen> {
  String? _selectedType = 'หอพัก'; // ตั้ง Default ตามรูปตัวอย่าง
  double _usageHours = 13.0; // ตั้ง Default ตามรูปตัวอย่าง
  final List<bool> _selectedDays = List.generate(7, (index) => true); // เลือกทุกวันตามรูป
  final List<String> _dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    bool isReady = _selectedType != null && _usageHours > 0 && _selectedDays.contains(true);

    return Scaffold(
      backgroundColor: const Color(0xFFFFD147), // สีเหลืองสดใส (Header)
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
        centerTitle: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EB), // สีพื้นหลังนวลๆ
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                
                _buildRateInfo(),
                const SizedBox(height: 35),
                
                _buildSubmitButton(isReady, args),
                const SizedBox(height: 20), // เผื่อระยะด้านล่าง
              ],
            ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _typeItem(Icons.home_outlined, 'บ้าน'),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: Colors.black12),
          ),
          _typeItem(Icons.apartment_outlined, 'หอพัก'),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: Colors.black12),
          ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'ชั่วโมงการใช้งานต่อวัน',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Text(
                '${_usageHours.toInt()} ชั่วโมง',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _usageHours,
              min: 0,
              max: 24,
              activeColor: Colors.amber,
              inactiveColor: Colors.grey[200],
              onChanged: (val) => setState(() => _usageHours = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          return GestureDetector(
            onTap: () => setState(() => _selectedDays[index] = !_selectedDays[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 38,
              decoration: BoxDecoration(
                color: _selectedDays[index] ? Colors.amber : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDays[index] ? Colors.amber : Colors.black12,
                ),
                boxShadow: _selectedDays[index] 
                  ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 5)] 
                  : [],
              ),
              alignment: Alignment.center,
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _selectedDays[index] ? Colors.black : Colors.black45,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRateInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_active_outlined, size: 22, color: Colors.black54),
        const SizedBox(width: 10),
        const Text(
          'อัตราค่าไฟ (บาท/หน่วย)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE58F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '7.0 /หน่วย',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isReady, Map<String, dynamic>? args) {
    return InkWell(
      onTap: isReady ? () => Navigator.pushNamed(context, '/result', arguments: {
        'brand': args?['brand'],
        'model': args?['model'],
        'watt': args?['watt'],
        'hours': _usageHours.toInt().toString(),
      }) : null,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: double.infinity,
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: isReady
              ? const LinearGradient(colors: [Color(0xFFFFD147), Color(0xFFF7941D)])
              : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, size: 32, color: Colors.black),
            SizedBox(width: 15),
            Text(
              'บันทึกและคำนวณค่า',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
            child: BottomNavigationBar(
              currentIndex: _currentNavIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black45,
              selectedFontSize: 14,
              unselectedFontSize: 14,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                if (index == 2) Navigator.pushNamed(context, '/settings');
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 28), label: 'หน้าหลัก'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined, size: 28), label: 'ประวัติ'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined, size: 28), label: 'ตั้งค่า'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}