import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรง)

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? expandedId;
  
  // ✅ 1. เพิ่มตัวแปรสำหรับเก็บ Stream ไว้ จะได้ไม่ต้องโหลดใหม่ทุกครั้งที่กดขยายการ์ด
  Stream<QuerySnapshot>? _historyStream;
  String? _currentUserId;

  // ── Palette คงที่ ────────────────
  static const Color _primary      = Color(0xFFFFC926); 
  static const Color _primaryDark  = Color(0xFFF59E0B); 

  @override
  void initState() {
    super.initState();
    // ✅ 2. สั่งให้ดึงข้อมูลจาก Firebase แค่ "ครั้งเดียว" ตอนเปิดหน้านี้
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _historyStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌗 ดึงค่า Theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 ตั้งค่าสี Dynamic
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textMid = isDark ? Colors.grey[400]! : const Color(0xFF78716C);
    
    final topGradient = isDark 
        ? const [Color(0xFF2A2D43), Color(0xFF1A1A2E)] 
        : const [Color(0xFFFFD95A), Color(0xFFFFC926)];

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
              // --- Header ---
              _buildHeader(context, textColor),

              // --- ส่วนเนื้อหา ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  // ✅ 3. เช็คว่ามี User ไหม ถ้ามีก็แสดง StreamBuilder แบบดึงจากท่อเดิม
                  child: _currentUserId == null || _historyStream == null
                      ? Center(
                          child: Text(
                            "กรุณาเข้าสู่ระบบเพื่อดูประวัติ", 
                            style: TextStyle(color: textMid, fontSize: 16, fontWeight: FontWeight.w600)
                          )
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: _historyStream, // ✅ 4. เรียกใช้ Stream ที่โหลดไว้แล้วใน initState
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล", style: TextStyle(color: textColor)));
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: _primaryDark));
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  "ยังไม่มีประวัติการเปรียบเทียบ", 
                                  style: TextStyle(color: textMid, fontSize: 16, fontWeight: FontWeight.w600)
                                )
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var doc = snapshot.data!.docs[index];
                                var data = doc.data() as Map<String, dynamic>;
                                
                                if (data['type'] != 'comparison') return const SizedBox();

                                return _buildComparisonCard(doc.id, data, _currentUserId!, isDark, textColor, textMid);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Widget ---
  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            'ประวัติการเปรียบเทียบ', 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w800, 
              color: textColor, 
              letterSpacing: -0.5
            )
          ),
        ],
      ),
    );
  }

  // --- การ์ดประวัติแบบเปรียบเทียบ (Slow & Smooth 800ms) ---
  Widget _buildComparisonCard(String docId, Map<String, dynamic> data, String uid, bool isDark, Color textColor, Color textMid) {
    bool isExpanded = expandedId == docId;

    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05);

    final pA = data['productA'] ?? {};
    final pB = data['productB'] ?? {};
    final saving = data['saving'] ?? {};
    final settings = data['settings'] ?? {};

    double percent = (saving['percent'] ?? 0).toDouble();
    String winnerBrand = saving['winnerBrand'] ?? 'รุ่นที่ประหยัดกว่า';

    double monthA = double.tryParse((pA['costMonth'] ?? pA['cost'] ?? '0').toString()) ?? 0.0;
    double monthB = double.tryParse((pB['costMonth'] ?? pB['cost'] ?? '0').toString()) ?? 0.0;
    
    double usageHours = double.tryParse(settings['usageHours']?.toString() ?? '0') ?? 0.0;
    double priceA = double.tryParse(pA['custom_price']?.toString() ?? '0') ?? 0.0;
    double priceB = double.tryParse(pB['custom_price']?.toString() ?? '0') ?? 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 🏆 ป้ายบอกความคุ้มค่า
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ประหยัดลง ${percent.toStringAsFixed(1)}% ด้วย $winnerBrand',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ⚔️ ส่วนประชันหน้า (VS Area)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductDisplay(pA['brand'], monthA, pA['image_url'], isDark, textColor, textMid),
              
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFBF0),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white10 : Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                  ),
                  child: const Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: _primaryDark, fontSize: 14)), 
                ),
              ),
              
              _buildProductDisplay(pB['brand'], monthB, pB['image_url'], isDark, textColor, textMid),
            ],
          ),

          // 🔽 ส่วนรายละเอียด
          AnimatedSize(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            child: isExpanded
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0), thickness: 1.5),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            if (priceA > 0 || priceB > 0) ...[
                              _buildCostRow('ราคาเครื่อง (จำลอง)', priceA, priceB, isDark, textColor, textMid),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0))),
                            ],
                            _buildCostRow('ค่าไฟต่อวัน', pA['costDay'], pB['costDay'], isDark, textColor, textMid),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0))),
                            _buildCostRow('ค่าไฟต่อปี', pA['costYear'], pB['costYear'], isDark, textColor, textMid),
                            
                            if (usageHours > 0) ...[
                              Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('เวลาใช้งานที่ตั้งไว้', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textMid)),
                                  Text('${usageHours.toStringAsFixed(1)} ชม./วัน', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _primaryDark)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ปุ่มดูกราฟจำลองจุดคุ้มทุน
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/graph_simulator', arguments: {
                              'productA': pA,
                              'productB': pB,
                              'rate': settings['rate'] ?? 4.42,
                              'daysPerWeek': settings['daysPerWeek'] ?? 7,
                              'currentTemp': settings['currentTemp'] ?? 30.0,
                              'usageHours': settings['usageHours'] ?? 8.0,
                              'fromHistory': true,
                            });
                          },
                          icon: const Icon(Icons.auto_graph_rounded),
                          label: const Text('ดูกราฟจำลองจุดคุ้มทุน', style: TextStyle(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? _primary.withOpacity(0.15) : _primary.withOpacity(0.15),
                            foregroundColor: _primaryDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('users').doc(uid).collection('history').doc(docId).delete();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ลบประวัติการเปรียบเทียบเรียบร้อยแล้ว'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          label: const Text('ลบประวัตินี้', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16), 
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          if (!isExpanded) const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => expandedId = isExpanded ? null : docId),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFFFF9E7),
                foregroundColor: isDark ? _primary : _primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      isExpanded ? 'ย่อรายละเอียด' : 'ดูข้อมูลเพิ่มเติม',
                      key: ValueKey(isExpanded),
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
          ),
        ],
      ),
    );
  }

  // 📦 แสดงข้อมูลรูปภาพ ชื่อแบรนด์ และค่าไฟรายเดือน
  Widget _buildProductDisplay(String? brand, double cost, String? imageUrl, bool isDark, Color textColor, Color textMid) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _primary.withOpacity(0.3), width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ClipOval(
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: _primaryDark,
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: isDark ? Colors.white24 : Colors.grey),
                    )
                  : const Icon(Icons.bolt_rounded, size: 35, color: _primaryDark),
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            brand ?? 'ไม่ระบุ',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          Text(
            '฿${cost.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1),
          ),
          Text(
            'บาท / เดือน', 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMid)
          ),
        ],
      ),
    );
  }

  // 📝 แถวเปรียบเทียบข้อมูล
  Widget _buildCostRow(String title, dynamic valA, dynamic valB, bool isDark, Color textColor, Color textMid) {
    double costA = double.tryParse(valA?.toString() ?? '0') ?? 0.0;
    double costB = double.tryParse(valB?.toString() ?? '0') ?? 0.0;
    
    Color colorA = costA <= costB ? Colors.green : textColor;
    Color colorB = costB <= costA ? Colors.green : textColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textMid)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('รุ่น A: ฿${costA.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorA)),
            Text('รุ่น B: ฿${costB.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorB)),
          ],
        ),
      ],
    );
  }
}
