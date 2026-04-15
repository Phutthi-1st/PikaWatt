import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรง)

class GraphSimulatorScreen extends StatefulWidget {
  const GraphSimulatorScreen({super.key});

  @override
  State<GraphSimulatorScreen> createState() => _GraphSimulatorScreenState();
}

class _GraphSimulatorScreenState extends State<GraphSimulatorScreen> {
  // ── Palette คงที่ ────────────────
  static const Color _primary = Color(0xFFFFC926);
  static const Color _primaryDark = Color(0xFFF59E0B);

  // ── ตัวแปรควบคุม ──
  double _sliderHours = 8.0;
  late TextEditingController _priceAController;
  late TextEditingController _priceBController;
  bool _isInitialized = false;
  bool _fromHistory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final pA = args?['productA'];
      final pB = args?['productB'];

      _fromHistory = args?['fromHistory'] == true;

      double savedPriceA =
          double.tryParse(pA?['custom_price']?.toString() ?? '0') ?? 0;
      double savedPriceB =
          double.tryParse(pB?['custom_price']?.toString() ?? '0') ?? 0;
      _priceAController = TextEditingController(
        text: savedPriceA > 0 ? savedPriceA.toStringAsFixed(0) : '10000',
      );
      _priceBController = TextEditingController(
        text: savedPriceB > 0 ? savedPriceB.toStringAsFixed(0) : '15000',
      );

      if (args?['usageHours'] != null) {
        _sliderHours = double.tryParse(args!['usageHours'].toString()) ?? 8.0;
      }

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _priceAController.dispose();
    _priceBController.dispose();
    super.dispose();
  }

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
    final gridLineColor = isDark
        ? Colors.white10
        : Colors.grey.withOpacity(0.2);

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final pA = args?['productA'];
    final pB = args?['productB'];

    final String brandA = pA?['brand'] ?? 'รุ่น A';
    final String modelA = pA?['model'] ?? '';
    final String brandB = pB?['brand'] ?? 'รุ่น B';
    final String modelB = pB?['model'] ?? '';

    final double wattA = double.tryParse(pA?['watt']?.toString() ?? '0') ?? 0;
    final double wattB = double.tryParse(pB?['watt']?.toString() ?? '0') ?? 0;
    final double rate =
        double.tryParse(args?['rate']?.toString() ?? '4.42') ?? 4.42;
    final int daysPerWeek =
        int.tryParse(args?['daysPerWeek']?.toString() ?? '7') ?? 7;

    final double currentTemp =
        double.tryParse(args?['currentTemp']?.toString() ?? '30') ?? 30;
    final String categoryId = args?['categoryId'] ?? '';
    double heatMul = 1.0;
    if (currentTemp > 30.0 &&
        (categoryId == 'air_conditioner' || categoryId == 'refrigerator')) {
      heatMul = 1.0 + (((currentTemp - 30.0) * 3) / 100);
    }

    double monthlyCostA =
        ((wattA / 1000) * _sliderHours * rate * heatMul) * daysPerWeek * 4.34;
    double monthlyCostB =
        ((wattB / 1000) * _sliderHours * rate * heatMul) * daysPerWeek * 4.34;

    double priceA = double.tryParse(_priceAController.text) ?? 0;
    double priceB = double.tryParse(_priceBController.text) ?? 0;

    double breakEvenMonth = -1;
    if (monthlyCostA != monthlyCostB) {
      breakEvenMonth = (priceB - priceA) / (monthlyCostA - monthlyCostB);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'จำลองจุดคุ้มทุน (5 ปี)',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // กล่องคำแนะนำ
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? _primary.withOpacity(0.1)
                              : _primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 24,
                              color: _primaryDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ระบุราคาเครื่องตามป้ายจริงที่คุณเจอ เพื่อให้กราฟคำนวณจุดคุ้มทุนระยะยาวได้แม่นยำที่สุด',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // กล่องกรอกราคา
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPriceInput(
                              brandA,
                              modelA,
                              _priceAController,
                              Colors.redAccent,
                              cardColor,
                              textColor,
                              textMid,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPriceInput(
                              brandB,
                              modelB,
                              _priceBController,
                              Colors.green,
                              cardColor,
                              textColor,
                              textMid,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // กราฟ
                    Container(
                      height: 300,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      padding: const EdgeInsets.only(
                        right: 24,
                        top: 30,
                        bottom: 16,
                        left: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((
                                  LineBarSpot touchedSpot,
                                ) {
                                  return LineTooltipItem(
                                    '฿${touchedSpot.y.toStringAsFixed(0)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10000,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: gridLineColor,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 12,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0)
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'เริ่ม',
                                        style: TextStyle(
                                          color: textMid,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'ปี ${value ~/ 12}',
                                      style: TextStyle(
                                        color: textMid,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: 10000,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0)
                                    return Text(
                                      '0k',
                                      style: TextStyle(
                                        color: textMid,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  return Text(
                                    '${(value / 1000).toStringAsFixed(0)}k',
                                    style: TextStyle(
                                      color: textMid,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: gridLineColor,
                                width: 2,
                              ),
                              left: const BorderSide(color: Colors.transparent),
                              right: const BorderSide(
                                color: Colors.transparent,
                              ),
                              top: const BorderSide(color: Colors.transparent),
                            ),
                          ),
                          minX: 0,
                          maxX: 60,
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                61,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  priceA + (monthlyCostA * index),
                                ),
                              ),
                              isCurved: false,
                              color: Colors.redAccent,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(
                                61,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  priceB + (monthlyCostB * index),
                                ),
                              ),
                              isCurved: false,
                              color: Colors.green,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildBreakEvenBanner(
                        breakEvenMonth,
                        isDark,
                        textMid,
                        textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // แผงควบคุมด้านล่าง (Bottom Sheet)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ทดลองปรับชั่วโมงใช้งาน',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${_sliderHours.toStringAsFixed(1)} ชม./วัน',
                        style: const TextStyle(
                          color: _primaryDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: _primaryDark,
                      inactiveTrackColor: _primary.withOpacity(0.2),
                      thumbColor: _primaryDark,
                      overlayColor: _primaryDark.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: _sliderHours,
                      min: 1,
                      max: 24,
                      divisions: 23,
                      onChanged: (val) => setState(() => _sliderHours = val),
                    ),
                  ),

                  if (!_fromHistory) ...[
                    const SizedBox(height: 16),
                    _buildSaveButton(
                      context,
                      pA,
                      pB,
                      rate,
                      daysPerWeek,
                      heatMul,
                      priceA,
                      priceB,
                      currentTemp,
                      isDark,
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green.withOpacity(0.15)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '✅ ข้อมูลนี้ถูกบันทึกในประวัติแล้ว',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 กล่องกรอกราคา
  Widget _buildPriceInput(
    String brand,
    String model,
    TextEditingController controller,
    Color color,
    Color cardColor,
    Color textColor,
    Color textMid,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (model.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              model,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMid,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: InputBorder.none,
                suffixText: '฿',
                suffixStyle: TextStyle(
                  color: textMid,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🚩 ป้ายแจ้งจุดคุ้มทุน
  Widget _buildBreakEvenBanner(
    double month,
    bool isDark,
    Color textMid,
    Color textColor,
  ) {
    if (month <= 0 || month > 60) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'ไม่พบจุดคุ้มทุนภายใน 5 ปี',
          style: TextStyle(
            color: textMid,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
    }

    int years = month ~/ 12;
    int months = (month % 12).ceil();
    String timeText = years > 0 ? '$years ปี $months เดือน' : '$months เดือน';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.withOpacity(0.15)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_circle_rounded, color: Colors.green, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'จุดคุ้มทุน (Break-even)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'รุ่น B จะคุ้มค่ากว่าเมื่อผ่านไป $timeText',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 ปุ่มบันทึกข้อมูล
  Widget _buildSaveButton(
    BuildContext context,
    Map<String, dynamic>? pA,
    Map<String, dynamic>? pB,
    double rate,
    int daysPerWeek,
    double heatMul,
    double customPriceA,
    double customPriceB,
    double currentTemp,
    bool isDark,
  ) {
    return InkWell(
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && pA != null && pB != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กำลังบันทึกข้อมูล...'),
              duration: Duration(seconds: 1),
            ),
          );

          // (Logic คำนวณและบันทึกคงเดิม)
          final double wattA =
              double.tryParse(pA['watt']?.toString() ?? '0') ?? 0.0;
          final double wattB =
              double.tryParse(pB['watt']?.toString() ?? '0') ?? 0.0;
          double dayA = (wattA / 1000) * _sliderHours * rate * heatMul;
          double monthA = dayA * daysPerWeek * 4.34;
          double yearA = monthA * 12;
          double dayB = (wattB / 1000) * _sliderHours * rate * heatMul;
          double monthB = dayB * daysPerWeek * 4.34;
          double yearB = monthB * 12;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('history')
              .add({
                'type': 'comparison',
                'timestamp': FieldValue.serverTimestamp(),
                'settings': {
                  'usageHours': _sliderHours,
                  'daysPerWeek': daysPerWeek,
                  'rate': rate,
                  'currentTemp': currentTemp,
                },
                'productA': {
                  'brand': pA['brand'] ?? 'ไม่ระบุ',
                  'model': pA['model'] ?? '-',
                  'watt': pA['watt'] ?? 0,
                  'image_url': pA['image_url'] ?? '',
                  'custom_price': customPriceA,
                  'costDay': dayA,
                  'costMonth': monthA,
                  'costYear': yearA,
                },
                'productB': {
                  'brand': pB['brand'] ?? 'ไม่ระบุ',
                  'model': pB['model'] ?? '-',
                  'watt': pB['watt'] ?? 0,
                  'image_url': pB['image_url'] ?? '',
                  'custom_price': customPriceB,
                  'costDay': dayB,
                  'costMonth': monthB,
                  'costYear': yearB,
                },
                'saving': {
                  'percent': monthA > 0
                      ? ((monthA - monthB).abs() / monthA) * 100
                      : 0,
                  'winnerBrand': monthA > monthB ? pB['brand'] : pA['brand'],
                },
              });

          if (context.mounted) {
            String title = "${pA['brand']} vs ${pB['brand']}";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('บันทึกผล $title เรียบร้อย!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาเข้าสู่ระบบก่อนบันทึกประวัติ'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // ปรับปุ่มเซฟเป็นสีเหลือง Gradient เพื่อให้เด่นในโหมดมืด
          gradient: const LinearGradient(colors: [_primary, _primaryDark]),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        // ตัวหนังสือสีเข้มเพราะอยู่บนปุ่มเหลือง
        child: const Text(
          'บันทึกผลการจำลอง',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
