import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // สร้าง Controller เพื่อดึงค่าจากช่องใส่ข้อมูล (Optional สำหรับตอนนี้)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ฟังก์ชัน helper สำหรับสร้างช่องใส่ข้อมูล (TextField)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // ขอบมน
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // เงาอ่อนๆ
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5), // เลื่อนเงาลงมาด้านล่าง
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'Arial', // หรือฟอนต์ภาษาไทยที่คุณตั้งค่าไว้
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: InputBorder.none, // ลบเส้นขอบปกติออก
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. พื้นหลังแบบ Gradient เหมือนหน้า Splash
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD147), // สีเหลืองเข้มด้านบน
              Color(0xFFFFF9E3), // สีครีมอ่อนด้านล่าง
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // ป้องกัน Overflow เวลาคีย์บอร์ดเด้งขึ้นมา
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80), // ระยะห่างจากด้านบน

                // 2. ส่วนของโลโก้ (ดึงจาก Assets)
                Image.asset(
                  'pictures/PikaWatt_Logo.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 10),

                // 3. ส่วนของชื่อแอป (PikaWatt Text)
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Pika',
                        style: TextStyle(color: Color(0xFF202939)), // สีน้ำเงินเข้ม
                      ),
                      TextSpan(
                        text: 'Watt',
                        style: TextStyle(color: Color(0xFFF7941D)), // สีเหลืองทอง
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60), // ระยะห่างก่อนถึงช่องใส่ข้อมูล

                // 4. ช่องใส่ "ชื่อผู้ใช้"
                _buildTextField(
                  controller: _usernameController,
                  hintText: 'ชื่อผู้ใช้',
                ),
                const SizedBox(height: 20),

                // 5. ช่องใส่ "รหัสผ่าน"
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'รหัสผ่าน',
                  obscureText: true, // ซ่อนตัวอักษร
                ),
                const SizedBox(height: 40), // ระยะห่างก่อนถึงปุ่ม

                // 6. ปุ่ม "เข้าสู่ระบบ" (แบบ Gradient + Shadow)
                Container(
                  width: double.infinity, // เต็มความกว้าง
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFBC02D), // สีเหลืองสว่าง
                        Color(0xFFF9A825), // สีเหลืองเข้ม/ส้ม
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // จัดการ logic การเข้าสู่ระบบตรงนี้
                      print('Username: ${_usernameController.text}');
                      print('Password: ${_passwordController.text}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // ใช้สีจาก Container
                      shadowColor: Colors.transparent, // ปิดเงาปกติของปุ่ม
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Arial', // หรือฟอนต์ภาษาไทยของคุณตั้งค่าไว้
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 7. ลิงก์ "ลงทะเบียน"
                TextButton(
                  onPressed: () {
                    // ไปหน้าลงทะเบียน
                  },
                  child: const Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF202939), // สีน้ำเงินเข้ม
                      decoration: TextDecoration.underline, // ขีดเส้นใต้
                      fontFamily: 'Arial', // หรือฟอนต์ภาษาไทยของคุณตั้งค่าไว้
                    ),
                  ),
                ),
                const SizedBox(height: 80), // ระยะห่างด้านล่างสุด
              ],
            ),
          ),
        ),
      ),
    );
  }
}
