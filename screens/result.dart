import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรง)

class CalculationResultScreen extends StatefulWidget {
  const CalculationResultScreen({super.key});

  @override
  State<CalculationResultScreen> createState() => _CalculationResultScreenState();
}

class _CalculationResultScreenState extends State<CalculationResultScreen> {
  String _selectedPeriod = 'เดือน';
  
  // ── Palette คงที่ ────────────────
  static const Color _primary      = Color(0xFFFFC926); 
  static const Color _primaryDark  = Color(0xFFF59E0B); 

  @override
  Widget build(BuildContext context) {
    // 🌗 ดึงค่า Theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 ตั้งค่าสี Dynamic
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);
    final shadowColor = isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04);
    
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    
    // 1. ดึงข้อมูลพื้นฐาน
    final String brand = args?['brand'] ?? '';
    final String model = args?['model'] ?? '';
    final double watt = double.tryParse(args?['watt']?.toString() ?? '0') ?? 0.0;
    final int hours = args?['usageHours'] ?? 0;
    final int daysPerWeek = args?['daysPerWeek'] ?? 0;
    final double rate = args?['rate'] ?? 0.0;
    final String categoryId = args?['categoryId'] ?? ''; 
    
    // 2. ดึงอุณหภูมิปัจจุบัน
    final double currentTemp = double.tryParse(args?['currentTemp']?.toString() ?? '30') ?? 30.0;

    // ── 3. Logic อากาศร้อน ──
    double heatMultiplier = 1.0;
    int percentIncrease = 0;
    
    bool isCoolingAppliance = (categoryId == 'air_conditioner' || categoryId == 'refrigerator');
    
    if (currentTemp > 30.0 && isCoolingAppliance) {
      double diffTemp = currentTemp - 30.0;
      percentIncrease = (diffTemp * 3).toInt(); 
      heatMultiplier = 1.0 + (percentIncrease / 100);
    }

    // 4. คำนวณพลังงาน
    double dailyKwh = (watt / 1000) * hours * heatMultiplier;
    double monthlyKwh = dailyKwh * daysPerWeek * 4.34; 
    double yearlyKwh = monthlyKwh * 12;

    double displayCost;
    if (_selectedPeriod == 'วัน') {
      displayCost = dailyKwh * rate;
    } else if (_selectedPeriod == 'เดือน') {
      displayCost = monthlyKwh * rate;
    } else {
      displayCost = yearlyKwh * rate;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(isDark ? 0.15 : 0.35),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ผลการคำนวณ',
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.w800, 
                              color: textColor, 
                              letterSpacing: -0.5
                            ),
                          ),
                          if (brand.isNotEmpty)
                            Text(
                              '$brand $model',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // ปุ่มลัดกลับหน้าโฮม
                    IconButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                      icon: Icon(Icons.home_rounded, color: textColor, size: 28),
                    )
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
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ป้ายเตือนสภาพอากาศ
                        if (percentIncrease > 0) 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _buildWeatherAlertBanner(currentTemp, percentIncrease, isDark),
                          ),

                        // หัวข้อ "ค่าไฟประมาณการ"
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.2), 
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(Icons.bolt_rounded, color: _primaryDark, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'ค่าไฟประมาณการ', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // การ์ดหลัก (ราคา)
                        _buildMainCostCard(displayCost, cardColor, textColor, textMid, isDark),
                        const SizedBox(height: 24),

                        // หัวข้อ "พลังงานที่ใช้"
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15), 
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(Icons.analytics_rounded, color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'พลังงานที่ใช้ (ยูนิต)', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // การ์ดรอง (หน่วยไฟ)
                        _buildEnergyUsageCard(dailyKwh, monthlyKwh, yearlyKwh, cardColor, textColor, textMid, isDark),
                        const SizedBox(height: 24),

                        // กล่องสรุปสูตร
                        _buildCalculationInfo(watt, hours, daysPerWeek, rate, cardColor, textColor, textMid, isDark),
                        const SizedBox(height: 32),

                        // ปุ่มเปรียบเทียบ
                        _buildCompareButton(args, isDark, textColor),
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

  // 🌡️ แจ้งเตือนสภาพอากาศ 
  Widget _buildWeatherAlertBanner(double temp, int percent, bool isDark) {
    final bgColor = isDark ? Colors.red.withOpacity(0.15) : const Color(0xFFFFF0F0);
    final borderColor = isDark ? Colors.red.withOpacity(0.4) : Colors.red.withOpacity(0.2);
    final textColor1 = isDark ? Colors.redAccent : Colors.red;
    final textColor2 = isDark ? Colors.red[300]! : const Color(0xFFD93838);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.thermostat_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'อุณหภูมิภายนอก ${temp.toStringAsFixed(1)}°C', 
                  style: TextStyle(fontWeight: FontWeight.w800, color: textColor1, fontSize: 15)
                ),
                const SizedBox(height: 4),
                Text(
                  'แอร์ทำงานหนักขึ้น ค่าไฟบวกเพิ่ม $percent%', 
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor2, fontSize: 13)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💳 การ์ดราคาหลัก
  Widget _buildMainCostCard(double cost, Color cardColor, Color textColor, Color textMid, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: isDark ? _primary.withOpacity(0.05) : const Color(0xFFFFF9E7), 
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _primary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  cost.toStringAsFixed(2), 
                  style: TextStyle(
                    fontSize: 56, 
                    fontWeight: FontWeight.w900, 
                    color: textColor, 
                    letterSpacing: -1.5,
                    height: 1.0,
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  'บาท / $_selectedPeriod', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryDark)
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF4F4F5), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              children: ['วัน', 'เดือน', 'ปี'].map((p) {
                bool isSelected = _selectedPeriod == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? _primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(p, 
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 15, 
                          color: isSelected ? const Color(0xFF1A1A2E) : textMid
                        )
                      ),
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

  // 📊 การ์ดยูนิตไฟ
  Widget _buildEnergyUsageCard(double d, double m, double y, Color cardColor, Color textColor, Color textMid, bool isDark) {
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: Column(
        children: [
          _usageRow('ต่อวัน', '${d.toStringAsFixed(2)} kWh', textColor, textMid),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: dividerColor, thickness: 1),
          ),
          _usageRow('ต่อเดือน', '${m.toStringAsFixed(2)} kWh', textColor, textMid),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: dividerColor, thickness: 1),
          ),
          _usageRow('ต่อปี', '${y.toStringAsFixed(2)} kWh', textColor, textMid),
        ],
      ),
    );
  }

  // แสดงแถวการใช้ไฟ
  Widget _usageRow(String label, String value, Color textColor, Color textMid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: textMid, fontWeight: FontWeight.w500)),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w700, 
            color: textColor 
          )
        ),
      ],
    );
  }

  // 📝 กล่องสรุปที่มา
  Widget _buildCalculationInfo(double watt, int hours, int days, double rate, Color cardColor, Color textColor, Color textMid, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ข้อมูลที่ใช้คำนวณ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 8),
          Text(
            '• กำลังไฟ ${watt.toInt()} วัตต์\n• ใช้งานวันละ $hours ชม. ($days วัน/สัปดาห์)\n• อัตราค่าไฟ ฿${rate.toStringAsFixed(2)} ต่อหน่วย',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textMid, height: 1.6),
          ),
        ],
      ),
    );
  }

  // 🔄 ปุ่มเปรียบเทียบ
  Widget _buildCompareButton(Map<String, dynamic>? args, bool isDark, Color textColor) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/compare', arguments: {'productA': args}),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFD1D5DB), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows_rounded, color: textColor, size: 24),
            const SizedBox(width: 10),
            Text('เปรียบเทียบกับรุ่นอื่น', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.3)
            ),
          ],
        ),
      ),
    );
  }
}
