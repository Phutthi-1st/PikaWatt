import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../theme_provider.dart'; // ✅ Import ThemeProvider (ปรับ path ให้ตรง)

class ModelSelectionScreen extends StatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  // ── Palette คงที่ ────────────────
  static const Color _primary      = Color(0xFFFFC926); 
  static const Color _primaryDark  = Color(0xFFF59E0B); 

  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final searchBgColor = isDark ? const Color(0xFF252545) : Colors.white;
    final hintColor = isDark ? Colors.white54 : Colors.black38;

    // รับค่า Arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String categoryName = args?['categoryName'] ?? 'เครื่องใช้ไฟฟ้า';
    final String categoryId = args?['categoryId'] ?? '';
    final bool isSelectingB = args?['isSelectingB'] == true;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: topGradient, // สลับสี Header ตามโหมด
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
                      child: Text(
                        isSelectingB ? 'เลือกรุ่น B : $categoryName' : categoryName,
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w800, 
                          color: textColor,
                          letterSpacing: -0.5
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      // ── Search Bar ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: searchBgColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04), 
                                blurRadius: 15, 
                                offset: const Offset(0, 4)
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'ค้นหายี่ห้อหรือรุ่น...',
                              hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.normal),
                              prefixIcon: const Icon(Icons.search_rounded, color: _primaryDark, size: 24),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.cancel_rounded, color: isDark ? Colors.white24 : Colors.black26),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => searchQuery = "");
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                          ),
                        ),
                      ),

                      // ── GridView ──
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('appliances')
                              .where('category', isEqualTo: categoryId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล', style: TextStyle(color: textColor)));
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: _primaryDark));
                            }

                            // ระบบกรองคำค้นหา
                            final docs = snapshot.data!.docs.where((doc) {
                              final brand = doc['brand'].toString().toLowerCase();
                              final model = doc['model_name'].toString().toLowerCase();
                              return brand.contains(searchQuery) || model.contains(searchQuery);
                            }).toList();

                            if (docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 60, color: textMid.withOpacity(0.3)),
                                    const SizedBox(height: 12),
                                    Text('ไม่พบรุ่นที่ค้นหา', style: TextStyle(fontSize: 16, color: textMid, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72, 
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                return _buildModelCard(context, data, args, isDark, textColor, textMid);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget การ์ดรุ่น ──
  Widget _buildModelCard(BuildContext context, Map<String, dynamic> item, Map<String, dynamic>? args, bool isDark, Color textColor, Color textMid) {
    bool isSelectingB = args?['isSelectingB'] ?? false;

    // 🎨 Dynamic Colors สำหรับการ์ด
    final cardColor = isDark ? const Color(0xFF252545) : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFF0F0F0);
    final shadowColor = isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04);
    final imageBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 6))
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            final selectedData = {
              'brand': item['brand'],
              'model': item['model_name'],
              'watt': item['watts'],
              'image_url': item['image_url'],
            };
            
            if (isSelectingB) {
              Navigator.pushNamed(context, '/compare', arguments: {...?args, 'productB': selectedData});
            } else {
              Navigator.pushNamed(context, '/userInput', arguments: {...?args, ...selectedData});
            }
          },
          child: Column(
            children: [
              // โซนรูปภาพ
              Container(
                width: double.infinity,
                height: 110,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: imageBgColor, // ในโหมดมืดจะมีสีพื้นหลังรูปจางๆ จะได้ดูมีมิติ
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                ),
                child: Center(
                  child: item['image_url'] != null && item['image_url'] != ""
                      ? Image.network(
                          item['image_url'],
                          fit: BoxFit.contain,
                          // ✅ ใส่ระบบ Loading ให้รูปภาพระหว่างดึงมาจาก Firebase
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                color: _primaryDark,
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported_rounded, color: isDark ? Colors.white12 : Colors.black12, size: 40),
                        )
                      : Icon(Icons.image_rounded, color: isDark ? Colors.white12 : Colors.black12, size: 40),
                ),
              ),
              
              // โซนข้อความและกำลังไฟ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      item['brand'] ?? 'ไม่ระบุ',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['model_name'] ?? '-',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMid),
                    ),
                    const SizedBox(height: 12),
                    
                    // ป้ายบอกกำลังไฟ (Watt)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? _primary.withOpacity(0.15) : _primary.withOpacity(0.2), 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['watts']} W',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
