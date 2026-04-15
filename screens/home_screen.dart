import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 

import 'history_screen.dart';
import 'setting.dart';
import '../theme_provider.dart'; 

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with TickerProviderStateMixin {
  bool isExpanded = false;
  int _currentIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentTemp = "--";
  String _weatherDesc = "กำลังโหลด...";
  String _locationName = "ระบุพิกัด...";
  bool _isLoadingWeather = true;

  // ✅ เพิ่มตัวแปรเช็คสถานะตอนแอปเพิ่งเปิด
  bool _isCheckingAuth = true; 
  Stream<QuerySnapshot>? _latestHistoryStream;
  String? _currentUid;

  // ── Palette หลัก ───────────────────────────────────
  static const Color _primary = Color(0xFFFFC926);
  static const Color _primaryDark = Color(0xFFF59E0B);
  static const Color _primaryDeep = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _fetchWeather();

    // ✅ ท่าไม้ตาย: สั่งให้รอเช็ค Auth ให้ชัวร์ก่อน แล้วค่อยวาดจอ
    _initializeAuthAndStream();
  }

  // ✅ ฟังก์ชันช่วยจัดการจังหวะการโหลด Firebase
  Future<void> _initializeAuthAndStream() async {
    // 1. รอให้ Firebase Auth พร้อมใช้งานจริงๆ
    User? user = FirebaseAuth.instance.currentUser;
    
    // ถ้าเพิ่งเปิดแอป บางที currentUser อาจจะยังโหลดไม่เสร็จ
    // เราเลยใช้ authStateChanges().first เพื่อบังคับรอให้รู้ผลชัวร์ๆ ก่อน 1 รอบ
    user ??= await FirebaseAuth.instance.authStateChanges().first;

    if (user != null && mounted) {
      setState(() {
        _currentUid = user!.uid;
        _latestHistoryStream = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .limit(1) 
            .snapshots();
      });
    }
    
    // 2. เช็คเสร็จแล้ว ปิดตัวโหลด (ให้ UI เริ่มทำงานได้)
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    const String apiKey = 'e254b3fd0e83d4135b5d8bf2028fb49e';
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _weatherDesc = "ไม่ได้อนุญาต GPS";
              _isLoadingWeather = false;
            });
          }
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey&lang=th',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _currentTemp = data['main']['temp'].round().toString();
            _weatherDesc = data['weather'][0]['description'];
            _locationName = data['name'];
            _isLoadingWeather = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _weatherDesc = "เซิร์ฟเวอร์ขัดข้อง";
            _isLoadingWeather = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherDesc = "การเชื่อมต่อขัดข้อง";
          _isLoadingWeather = false;
        });
      }
    }
  }

  final List<String> _energyTips = [
    'การล้างแอร์ทุก 6 เดือน ช่วยลดค่าไฟได้ 5-10%',
    'ปิดไฟดวงที่ไม่ใช้งาน ช่วยประหยัดค่าไฟ',
    'ถอดปลั๊กเมื่อไม่ใช้งาน ป้องกันไฟรั่วไหล',
    'เลือกใช้หลอดไฟ LED ประหยัดไฟกว่า 80%',
    'ตั้งอุณหภูมิแอร์ที่ 25-26 องศา ประหยัดที่สุด',
  ];

  Widget _getPage(int index, bool isDark) {
    switch (index) {
      case 0:
        return _buildMainDashboard(isDark);
      case 1:
        return const HistoryScreen();
      case 2:
        return SettingsScreen(onBackToHome: () => setState(() => _currentIndex = 0));
      default:
        return _buildMainDashboard(isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);

    return Scaffold(
      backgroundColor: bgColor,
      body: _getPage(_currentIndex, isDark),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildMainDashboard(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildWeatherCard(), 
                    const SizedBox(height: 28),
                    _buildSectionLabel('คำนวณล่าสุด', isDark),
                    const SizedBox(height: 14),
                    _buildHistoryCard(isDark), 
                    const SizedBox(height: 28),
                    _buildStartButton(), 
                    const SizedBox(height: 28),
                    _buildSectionLabel('เคล็ดลับประหยัดไฟ', isDark),
                    const SizedBox(height: 14),
                    _buildEnergyTip(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final gradientColors = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : const Color(0x40FFC926),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'pictures/PikaWatt_Logo.png',
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Text(
            'PikaWatt',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60B8F8), Color(0xFF1D78D4)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x551D78D4),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _isLoadingWeather ? 'กำลังระบุ...' : _locationName,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentTemp,
                            style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w800, height: 1.0, letterSpacing: -2),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('°C', style: TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weatherDesc,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.wb_sunny_rounded, size: 60, color: Colors.white.withOpacity(0.75)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── History Card ───────────────────────────────────────────
  Widget _buildHistoryCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    // ✅ ถ้าระบบยังเช็ค Auth ไม่เสร็จ ให้โชว์วงกลมโหลดเงียบๆ ตรงการ์ด (ไม่ขึ้นข้อความหลอก)
    if (_isCheckingAuth) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: CircularProgressIndicator(color: _primaryDark)
        )
      );
    }

    if (_currentUid == null || _latestHistoryStream == null) {
      return _buildFallbackCard('กรุณาเข้าสู่ระบบเพื่อดูประวัติ', isDark);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _latestHistoryStream, 
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildFallbackCard('เกิดข้อผิดพลาดในการโหลดข้อมูล', isDark);
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: _primaryDark)));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildFallbackCard('ยังไม่มีประวัติการเปรียบเทียบล่าสุด', isDark);
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final pA = data['productA'] ?? {};
        final pB = data['productB'] ?? {};
        final saving = data['saving'] ?? {};
        final settings = data['settings'] ?? {};

        String title = "${pA['brand'] ?? 'รุ่น A'} VS ${pB['brand'] ?? 'รุ่น B'}";
        double monthA = double.tryParse((pA['costMonth'] ?? pA['cost'] ?? '0').toString()) ?? 0;
        double monthB = double.tryParse((pB['costMonth'] ?? pB['cost'] ?? '0').toString()) ?? 0;
        String diff = (monthA - monthB).abs().toStringAsFixed(0);
        String percent = (saving['percent'] ?? 0).toStringAsFixed(1);
        String winner = saving['winnerBrand'] ?? '-';
        String usage = "${settings['usageHours'] ?? 0}";

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200), 
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                decoration: BoxDecoration(
                  color: isDark ? _primary.withOpacity(0.05) : _primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: _primary.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.compare_arrows_rounded, color: _primaryDark, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title, 
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textColor), 
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  children: [
                    _costRow(label: 'ประหยัดกว่าด้วย', value: winner, icon: Icons.emoji_events_rounded, valColor: Colors.green, isDark: isDark),
                    const SizedBox(height: 12),
                    _costRow(label: 'ช่วยประหยัดเงินได้', value: '$diff บาท/เดือน', icon: Icons.savings_rounded, isDark: isDark),
                    
                    AnimatedSize(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                      child: isExpanded 
                        ? Column(
                            children: [
                              const SizedBox(height: 12),
                              _costRow(label: 'เวลาใช้งาน', value: '$usage ชม./วัน', icon: Icons.access_time_rounded, isDark: isDark),
                              const SizedBox(height: 12),
                              _costRow(label: 'ประหยัดพลังงานลง', value: '$percent %', icon: Icons.eco_rounded, isDark: isDark),
                            ],
                          )
                        : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                style: TextButton.styleFrom(foregroundColor: _primaryDark, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        isExpanded ? 'ปิดรายละเอียด' : 'ดูรายละเอียด',
                        key: ValueKey(isExpanded),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0, 
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0)),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text('ดูประวัติทั้งหมด', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _primaryDark)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackCard(String message, bool isDark) {
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 42, color: textMid.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: textMid, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _costRow({required String label, required String value, required IconData icon, Color? valColor, required bool isDark}) {
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);
    final textDark = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: _primaryDark),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: textMid)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: valColor ?? textDark)),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        double temp = double.tryParse(_currentTemp) ?? 30.0;
        Navigator.pushNamed(context, '/category', arguments: {'currentTemp': temp});
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD95A), Color(0xFFFFC926)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _primary.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, color: Color(0xFF1A1A2E), size: 22),
            SizedBox(width: 10),
            Text(
              'เริ่มคำนวณค่าไฟ',
              style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyTip(bool isDark) {
    final tip = _energyTips[Random().nextInt(_energyTips.length)];
    
    final bgColor = isDark ? Colors.green.withOpacity(0.1) : const Color.fromARGB(255, 189, 255, 191);
    final borderColor = isDark ? Colors.green.withOpacity(0.3) : const Color.fromARGB(255, 122, 231, 110);
    final textColor = isDark ? Colors.greenAccent : const Color(0xFF065F46);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [BoxShadow(color: Color.fromARGB(32, 77, 255, 80), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFC926), size: 28),
          const SizedBox(width: 14),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 14, color: textColor, height: 1.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'หน้าหลัก'},
      {'icon': Icons.history_rounded, 'label': 'ประวัติ'},
      {'icon': Icons.settings_rounded, 'label': 'ตั้งค่า'},
    ];
    
    final navBgColor = isDark ? const Color(0xFF252545) : Colors.white;
    final textMid = isDark ? Colors.grey[500]! : const Color(0xFF78716C);

    return Container(
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07), 
            blurRadius: 16, 
            offset: const Offset(0, -4)
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary.withOpacity(0.18) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[index]['icon'] as IconData, color: isSelected ? _primaryDark : textMid, size: 24),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          items[index]['label'] as String,
                          style: const TextStyle(color: _primaryDark, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
