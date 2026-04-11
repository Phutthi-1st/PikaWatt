import 'package:flutter/material.dart';
import '/models/appliance_model.dart';

class ModelSelectionScreen extends StatelessWidget {
  // ลบ categoryName ออกจาก Constructor เพื่อแก้ Error ใน main.dart
  const ModelSelectionScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    // 1. ดึงค่าจาก Arguments (ชื่อหมวดหมู่ และ ข้อมูลรุ่น A ถ้ามี)
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String categoryName = args?['categoryName'] ?? 'ไม่ระบุ';

    // 2. *** ส่วนที่เพิ่ม: ข้อมูลจำลองสำหรับแสดงผล (เปลี่ยนเป็นดึงจาก Database ได้ในภายหลัง) ***
    final List<ApplianceBrandModel> displayList = [
      ApplianceBrandModel(brand: 'Samsung', modelName: 'AR123', watts: 1000, imagePath: '', category: 'เครื่องปรับอากาศ'),
      ApplianceBrandModel(brand: 'LG', modelName: 'Dual Inverter', watts: 900, imagePath: '', category: 'เครื่องปรับอากาศ'),
      ApplianceBrandModel(brand: 'Sharp', modelName: 'Plasmacluster', watts: 850, imagePath: '', category: 'เครื่องปรับอากาศ'),
      ApplianceBrandModel(brand: 'Daikin', modelName: 'FTKC', watts: 1100, imagePath: '', category: 'เครื่องปรับอากาศ'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6D36A),
      body: SafeArea(
        child: Column(
          children: [
            // --- ส่วนหัว: ปุ่มย้อนกลับ และ ชื่อหมวดหมู่ ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios), 
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'รุ่นและยี่ห้อ ($categoryName)', 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), 
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // --- ช่องค้นหา (Search Bar) ---
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ค้นหา',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFFE8A1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), 
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // --- Grid รายการเครื่องใช้ไฟฟ้า ---
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          return _buildModelCard(context, displayList[index]);
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
    );
  }

  // --- ฟังก์ชันสร้างการ์ดพร้อม Logic การเปลี่ยนหน้า ---
  Widget _buildModelCard(BuildContext context, ApplianceBrandModel item) {
    return InkWell(
      onTap: () {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        bool isSelectingB = args?['isSelectingB'] ?? false;

        if (isSelectingB) {
          // --- ถ้ามาเลือกรุ่น B: ส่งค่ากลับหน้า Compare ทันที ---
          Navigator.pushNamed(
            context, 
            '/compare', 
            arguments: {
              'productA': args?['productA'], 
              'productB': {
                'brand': item.brand,
                'model': item.modelName,
                'watt': item.watts,
              },
              'hours': args?['hours'], 
              'rate': args?['rate'], 
            },
          );
        } else {
          // --- ถ้าเลือกรุ่นแรก (A): ไปหน้ากำหนดการใช้งาน ---
          Navigator.pushNamed(
            context, 
            '/userInput', // ตรวจสอบชื่อใน main.dart ว่าตรงกันไหม
            arguments: {
              'brand': item.brand,
              'model': item.modelName,
              'watt': item.watts,
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F3E3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.brand, 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              item.modelName, 
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'กำลังไฟ(${item.watts}W)', 
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}