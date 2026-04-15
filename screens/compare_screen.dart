import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรง)

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String _selectedPeriod = 'เดือน';

  // ── Palette หลัก ────────────────
  static const Color _primary = Color(0xFFFFC926);
  static const Color _primaryDark = Color(0xFFF59E0B);

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
    
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final Map<String, dynamic>? productA = args?['productA'];
    final Map<String, dynamic>? productB = args?['productB'];

    // 1. ดึงข้อมูลพื้นฐาน
    final double hours = double.tryParse((productA?['hours'] ?? args?['usageHours'] ?? '0').toString()) ?? 0.0;
    final double rate = double.tryParse((productA?['rate'] ?? args?['rate'] ?? '4.42').toString()) ?? 4.42;
    final int daysPerWeek = int.tryParse((productA?['daysPerWeek'] ?? args?['daysPerWeek'] ?? '7').toString()) ?? 7;

    final double wattA = double.tryParse(productA?['watt']?.toString() ?? '0') ?? 0.0;
    final double wattB = double.tryParse(productB?['watt']?.toString() ?? '0') ?? 0.0;

    // ── 2. Logic อากาศร้อน ──
    final double currentTemp = double.tryParse(args?['currentTemp']?.toString() ?? '30') ?? 30.0;
    final String categoryId = args?['categoryId'] ?? '';
    double heatMultiplier = 1.0;

    bool isCoolingAppliance = (categoryId == 'air_conditioner' || categoryId == 'refrigerator');
    if (currentTemp > 30.0 && isCoolingAppliance) {
      double diffTemp = currentTemp - 30.0;
      int percentIncrease = (diffTemp * 3).toInt();
      heatMultiplier = 1.0 + (percentIncrease / 100);
    }

    // 3. คำนวณพลังงาน
    double dailyA = (wattA / 1000) * hours * rate * heatMultiplier;
    double dailyB = (wattB / 1000) * hours * rate * heatMultiplier;

    double costA = 0;
    double costB = 0;

    if (_selectedPeriod == 'วัน') {
      costA = dailyA;
      costB = dailyB;
    } else if (_selectedPeriod == 'เดือน') {
      costA = dailyA * daysPerWeek * 4.34;
      costB = dailyB * daysPerWeek * 4.34;
    } else if (_selectedPeriod == 'ปี') {
      costA = dailyA * daysPerWeek * 52;
      costB = dailyB * daysPerWeek * 52;
    }

    // 4. คำนวณส่วนต่าง
    double costDifference = costA - costB;
    double savingPercent = costA > 0 ? (costDifference / costA) * 100 : 0;

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
                    Text('เปรียบเทียบรุ่น', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
                  ],
                ),
              ),

              // ── Content Area ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                    child: Column(
                      children: [
                        _buildPeriodSwitcher(isDark, textColor, textMid),
                        const SizedBox(height: 24),

                        _buildVSSection(productA, productB, costA, costB, isDark, cardColor, textColor, textMid, bgColor),
                        const SizedBox(height: 24),

                        if (productB != null) ...[
                          _buildSavingCard(costDifference, savingPercent, isDark, cardColor, textColor, textMid),
                          const SizedBox(height: 20),
                          _buildPaybackCard(savingPercent, isDark),
                          const SizedBox(height: 20),
                          _buildGraphButton(context, args, rate, daysPerWeek, productA, productB, isDark),
                          const SizedBox(height: 32),
                        ],

                        productB == null
                            ? _buildSelectBButton(context, productA ?? args, hours, rate)
                            : _buildSaveComparisonButton(context, productA, productB, costA, costB, args),

                        const SizedBox(height: 24),
                        _buildFooterInfo(hours, rate, daysPerWeek, textMid),
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

  // 🎛️ ปุ่มสลับช่วงเวลา
  Widget _buildPeriodSwitcher(bool isDark, Color textColor, Color textMid) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF2F2F2), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: ['วัน', 'เดือน', 'ปี'].map((p) {
          bool isSelected = _selectedPeriod == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 8)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  p, 
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 16, 
                    // ตัวที่ถูกเลือกให้เป็นสีเข้มเสมอเพราะอยู่บนปุ่มสีเหลือง
                    color: isSelected ? const Color(0xFF1A1A2E) : (isDark ? Colors.white54 : Colors.black38)
                  )
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ⚔️ ส่วนประชัน VS
  Widget _buildVSSection(Map<String, dynamic>? pA, Map<String, dynamic>? pB, double costA, double costB, bool isDark, Color cardColor, Color textColor, Color textMid, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInfo(pA?['brand'] ?? 'รุ่น A', costA, false, pA, isDark, textColor, textMid),
              _buildProductInfo(pB?['brand'] ?? 'รุ่น B', costB, true, pB, isDark, textColor, textMid),
            ],
          ),
          Positioned(
            top: 50,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor, // ใช้สีเดียวกับพื้นหลังแอป
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white10 : Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: const Text('VS', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // 📦 กล่องแสดงสินค้า
  Widget _buildProductInfo(String brand, double cost, bool isB, Map<String, dynamic>? product, bool isDark, Color textColor, Color textMid) {
    bool isEmpty = product == null && isB;
    
    String imageUrl = product?['image_url'] ?? '';
    String modelName = product?['model'] ?? '-';
    String wattText = product?['watt']?.toString() ?? '0';

    final emptyCircleBg = isDark ? Colors.white10 : Colors.grey.withOpacity(0.1);
    final filledCircleBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;

    return Expanded(
      child: Column(
        children: [
          Text(
            isEmpty ? 'เลือกรุ่นเปรียบเทียบ' : brand,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isEmpty ? textMid : textColor),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: isEmpty ? emptyCircleBg : filledCircleBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isEmpty ? Colors.transparent : (isB ? Colors.green.withOpacity(0.3) : _primaryDark.withOpacity(0.3)), 
                width: 3
              ),
              boxShadow: isEmpty ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ClipOval(
              child: isEmpty 
                ? Icon(Icons.add_rounded, size: 40, color: isDark ? Colors.white24 : Colors.grey)
                : (imageUrl.isNotEmpty 
                    ? Image.network(
                        imageUrl, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: isDark ? Colors.white24 : Colors.grey[400]),
                      )
                    : Icon(Icons.bolt_rounded, size: 40, color: isB ? Colors.green : _primaryDark)),
            ),
          ),
          
          if (!isEmpty) ...[
            const SizedBox(height: 10),
            Text(modelName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textMid), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('$wattText วัตต์', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey)),
          ],

          const SizedBox(height: 16),
          Text(
            isEmpty ? '-' : '฿${cost.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isEmpty ? textMid : textColor, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  // 💰 การ์ดสรุปความคุ้มค่า
  Widget _buildSavingCard(double diff, double percent, bool isDark, Color cardColor, Color textColor, Color textMid) {
    bool isSaving = diff >= 0;
    String titleText = isSaving ? 'ประหยัดได้มากกว่า' : 'ค่าไฟแพงกว่ารุ่น A';
    Color mainColor = isSaving ? Colors.green : Colors.red;
    String diffDisplay = diff.abs().toStringAsFixed(0);
    String percentDisplay = percent.abs().toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
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
          Text(titleText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textMid)),
          const SizedBox(height: 8),
          Text('$diffDisplay บาท', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: mainColor, letterSpacing: -1)),
          Text(
            isSaving ? 'ประหยัดลง $percentDisplay% ต่อ$_selectedPeriod' : 'จ่ายเพิ่ม $percentDisplay% ต่อ$_selectedPeriod',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textMid),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20), 
            child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFEEEEEE), thickness: 1.5)
          ),
          _buildProgressBar('รุ่น A', 1.0, _primaryDark, isDark, textColor),
          const SizedBox(height: 16),
          _buildProgressBar('รุ่น B', isSaving ? (100 - percent.abs()) / 100 : (100 + percent.abs()) / 100, mainColor, isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double val, Color color, bool isDark, Color textColor) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: textColor))),
        Expanded(
          child: LinearProgressIndicator(
            value: val.clamp(0.0, 1.0), 
            backgroundColor: isDark ? Colors.white10 : const Color(0xFFF0F0F0), 
            color: color, 
            minHeight: 14, 
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // 💡 กล่องทิปส์
  Widget _buildPaybackCard(double savingPercent, bool isDark) {
    String tipText = "การเลือกวัตต์ที่เหมาะสม ช่วยให้คุณมีเงินเหลือเก็บมากขึ้น";
    if (savingPercent > 30) {
      tipText = "ว้าว! รุ่นนี้ประหยัดไฟกว่าเดิมถึง ${savingPercent.toStringAsFixed(0)}% คุ้มค่าสุดๆ";
    } else if (savingPercent < 0) {
      tipText = "รุ่น B กินไฟมากกว่า หากใช้งานบ่อยอาจทำให้ค่าไฟบานปลายได้";
    }

    final bgColor = isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE8F5E9);
    final borderColor = isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.3);
    final descColor = isDark ? Colors.greenAccent : const Color(0xFF1B5E20);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: borderColor, width: 1)
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded, size: 28, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('เกร็ดน่ารู้จาก PikaWatt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.green)),
                const SizedBox(height: 4),
                Text(tipText, style: TextStyle(color: descColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📈 ปุ่มกราฟจำลองจุดคุ้มทุน
  Widget _buildGraphButton(BuildContext context, Map<String, dynamic>? args, double rate, int daysPerWeek, Map<String, dynamic>? pA, Map<String, dynamic>? pB, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/graph_simulator', arguments: {
          ...?args,
          'rate': rate,
          'daysPerWeek': daysPerWeek,
          'productA': pA,
          'productB': pB,
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity, height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryDark, width: 2),
          color: isDark ? _primary.withOpacity(0.15) : _primary.withOpacity(0.1),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph_rounded, color: _primaryDark),
            SizedBox(width: 8),
            Text('จำลองจุดคุ้มทุนระยะยาว (กราฟ)', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // 🔘 ปุ่มเลือกรุ่น B
  Widget _buildSelectBButton(BuildContext context, Map<String, dynamic>? pA, double h, double r) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/category', arguments: { ...?pA, 'isSelectingB': true, 'productA': pA });
      },
      child: Container(
        width: double.infinity, height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35), 
          gradient: const LinearGradient(colors: [_primary, _primaryDark]),
          boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        // ล็อกสีอักษรเป็นสีเข้มเสมอเพราะอยู่บนปุ่มสีเหลือง
        child: const Text('เลือกรุ่น B เพื่อเปรียบเทียบ', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }

  // 🔘 ปุ่มบันทึกผล
  Widget _buildSaveComparisonButton(BuildContext context, Map<String, dynamic>? pA, Map<String, dynamic>? pB, double cA, double cB, Map<String, dynamic>? args) {
    return InkWell(
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        
        if (user != null && pA != null && pB != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กำลังบันทึกข้อมูล...'), duration: Duration(seconds: 1)),
          );

          final double wattA = double.tryParse(pA['watt']?.toString() ?? '0') ?? 0.0;
          final double wattB = double.tryParse(pB['watt']?.toString() ?? '0') ?? 0.0;
          final double h = double.tryParse((pA['usageHours'] ?? pA['hours'] ?? '0').toString()) ?? 0.0;
          final double r = double.tryParse((pA['rate'] ?? '4.42').toString()) ?? 4.42;
          final int dWeek = int.tryParse((pA['daysPerWeek'] ?? '7').toString()) ?? 7;

          final double currentTemp = double.tryParse(args?['currentTemp']?.toString() ?? '30') ?? 30.0;
          double heatMul = 1.0;
          if (currentTemp > 30.0 && (args?['categoryId'] == 'air_conditioner' || args?['categoryId'] == 'refrigerator')) {
            heatMul = 1.0 + (((currentTemp - 30.0) * 3) / 100);
          }

          double dayA = (wattA / 1000) * h * r * heatMul;
          double monthA = dayA * dWeek * 4.34;
          double yearA = monthA * 12;

          double dayB = (wattB / 1000) * h * r * heatMul;
          double monthB = dayB * dWeek * 4.34;
          double yearB = monthB * 12;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('history')
              .add({
            'type': 'comparison', 
            'timestamp': FieldValue.serverTimestamp(),
            'settings': {
              'usageHours': h,
              'daysPerWeek': dWeek,
              'rate': r,
              'currentTemp': currentTemp,
            },
            'productA': {
              'brand': pA['brand'] ?? 'ไม่ระบุ',
              'model': pA['model'] ?? '-',
              'watt': pA['watt'] ?? 0,
              'image_url': pA['image_url'] ?? '',
              'costDay': dayA,
              'costMonth': monthA,
              'costYear': yearA,
            },
            'productB': {
              'brand': pB['brand'] ?? 'ไม่ระบุ',
              'model': pB['model'] ?? '-',
              'watt': pB['watt'] ?? 0,
              'image_url': pB['image_url'] ?? '',
              'costDay': dayB,
              'costMonth': monthB,
              'costYear': yearB,
            },
            'saving': {
              'percent': monthA > 0 ? ((monthA - monthB).abs() / monthA) * 100 : 0,
              'winnerBrand': monthA > monthB ? pB['brand'] : pA['brand'],
            }
          });

          String title = "${pA['brand']} vs ${pB['brand']}";
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('บันทึกผล $title เรียบร้อย!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนบันทึกประวัติ'), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        width: double.infinity, height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35), color: const Color(0xFF1E293B), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: const Text('บันทึกผลการเปรียบเทียบ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildFooterInfo(double h, double r, int days, Color textMid) {
    return Column(
      children: [
        Text('คำนวณจาก: ${h.toStringAsFixed(0)} ชม./วัน ($days วัน/สัปดาห์)', style: TextStyle(color: textMid, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text('อัตราค่าไฟเฉลี่ย $r บาท/หน่วย', style: TextStyle(color: textMid, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
