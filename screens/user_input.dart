import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class UsageSettingScreen extends StatefulWidget {
  const UsageSettingScreen({super.key});

  @override
  State<UsageSettingScreen> createState() => _UsageSettingScreenState();
}

class _UsageSettingScreenState extends State<UsageSettingScreen> {
  // ── Palette หลัก (ยังเก็บไว้สำหรับจุดเด่น) ────────────────
  static const Color _primary      = Color(0xFFFFC926); 
  static const Color _primaryDark  = Color(0xFFF59E0B); 

  String? _selectedType;
  double _usageHours = 0.0;
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<String> _dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  final TextEditingController _customRateController = TextEditingController(text: '0.0');

  double get _currentRate {
    if (_selectedType == 'บ้าน') return 4.42;
    if (_selectedType == 'หอพัก') return 7.0;
    return double.tryParse(_customRateController.text) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // 🌗 ดึงค่า Theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 ตั้งค่าสี Dynamic
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF444444);
    
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    // รับข้อมูล
    final productArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final size = MediaQuery.of(context).size;
    int activeDays = _selectedDays.where((day) => day).length;

    bool isReady = _selectedType != null && 
                   _usageHours > 0 && 
                   activeDays > 0 && 
                   (_selectedType != 'กำหนดเอง' || _currentRate > 0);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: topGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(isDark ? 0.15 : 0.35),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'กำหนดการใช้งาน',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),

              // ── Content Area ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40), 
                      topRight: Radius.circular(40)
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductBanner(productArgs, isDark, textColor, textMid),
                        const SizedBox(height: 30),

                        _sectionTitle('เลือกรูปแบบที่อยู่อาศัย', textColor),
                        const SizedBox(height: 15),
                        _buildTypeSelector(cardColor, textColor, textMid, isDark),
                        
                        const SizedBox(height: 30),
                        _sectionTitle('ชั่วโมงการใช้งานต่อวัน', textColor),
                        const SizedBox(height: 15),
                        _buildHourSlider(cardColor),
                        
                        const SizedBox(height: 30),
                        _sectionTitle('จำนวนวันที่ใช้งานต่อสัปดาห์', textColor),
                        const SizedBox(height: 15),
                        _buildDayPicker(cardColor, textColor, textMid), 
                        
                        const SizedBox(height: 35),
                        _buildRateSection(isDark, cardColor),
                        
                        const SizedBox(height: 40),
                        _buildSubmitButton(isReady, productArgs, activeDays),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
    );
  }

  Widget _buildProductBanner(Map<String, dynamic>? product, bool isDark, Color textColor, Color textMid) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _primary.withOpacity(0.05) : _primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: _primaryDark, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product?['brand'] ?? 'ไม่ระบุ'} - ${product?['model'] ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                ),
                Text(
                  'กำลังไฟฟ้า: ${product?['watt'] ?? 0} วัตต์',
                  style: TextStyle(fontSize: 13, color: textMid, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(Color cardColor, Color textColor, Color textMid, bool isDark) {
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFEEEEEE);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          _typeItem(Icons.home_rounded, 'บ้าน', textColor, textMid),
          Divider(height: 1, indent: 60, color: dividerColor),
          _typeItem(Icons.apartment_rounded, 'หอพัก', textColor, textMid),
          Divider(height: 1, indent: 60, color: dividerColor),
          _typeItem(Icons.tune_rounded, 'กำหนดเอง', textColor, textMid),
        ],
      ),
    );
  }

  Widget _typeItem(IconData icon, String title, Color textColor, Color textMid) {
    return RadioListTile<String>(
      value: title,
      groupValue: _selectedType,
      activeColor: _primaryDark,
      title: Row(
        children: [
          Icon(icon, color: textMid, size: 24),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        ],
      ),
      onChanged: (value) => setState(() => _selectedType = value),
    );
  }

  Widget _buildHourSlider(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: _primaryDark,
              inactiveTrackColor: _primary.withOpacity(0.2),
              thumbColor: _primaryDark,
              overlayColor: _primaryDark.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _usageHours,
              min: 0, max: 24,
              divisions: 24,
              onChanged: (val) => setState(() => _usageHours = val),
            ),
          ),
          Text(
            '${_usageHours.toInt()} ชั่วโมง / วัน', 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _primaryDark)
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker(Color cardColor, Color textColor, Color textMid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        bool isSelected = _selectedDays[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedDays[index] = !_selectedDays[index]),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? _primary : cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? _primaryDark : Colors.black12),
              boxShadow: isSelected ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8)] : [],
            ),
            alignment: Alignment.center,
            child: Text(
              _dayLabels[index], 
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1A1A2E) : textMid)
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRateSection(bool isDark, Color cardColor) {
    final inputBg = isDark ? Colors.white10 : Colors.white;
    final hintColor = isDark ? Colors.white54 : Colors.black38;

    return Column(
      children: [
        if (_selectedType == 'กำหนดเอง')
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              controller: _customRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'ระบุค่าไฟต่อหน่วย',
                labelStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5), 
            borderRadius: BorderRadius.circular(20)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on_rounded, color: _primaryDark),
              const SizedBox(width: 8),
              Text('อัตราค่าไฟ:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(width: 10),
              Text(
                '${_currentRate.toStringAsFixed(2)} บาท/หน่วย', 
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 17)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isReady, Map<String, dynamic>? product, int activeDays) {
    return InkWell(
      onTap: isReady ? () {
        Navigator.pushNamed(context, '/result', arguments: {
          ...?product, 
          'usageHours': _usageHours.toInt(), 
          'daysPerWeek': activeDays,
          'rate': _currentRate,
          'homeType': _selectedType,
        });
      } : null,
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(37.5),
          gradient: isReady 
            ? const LinearGradient(colors: [_primary, _primaryDark])
            : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
          boxShadow: isReady ? [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: Center(
          child: Text(
            'คำนวณค่าไฟ', 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: isReady ? const Color(0xFF1A1A2E) : Colors.white70
            )
          ),
        ),
      ),
    );
  }
}
