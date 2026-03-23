import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = ""; // เก็บข้อความที่จะแสดง
  bool _hasError = false;    // เช็คว่ามี error หรือไม่

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ใช้ฟังก์ชัน helper เดิมเพื่อความสม่ำเสมอของดีไซน์
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD147), Color(0xFFFFF9E3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // โลโก้
                Image.asset('pictures/PikaWatt_Logo.png', width: 160, height: 160),
                const SizedBox(height: 10),
                // ชื่อแอป
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Pika', style: TextStyle(color: Color(0xFF202939))),
                      TextSpan(text: 'Watt', style: TextStyle(color: Color(0xFFF7941D))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ช่องกรอกข้อมูลตามลำดับ
                _buildTextField(controller: _usernameController, hintText: 'ชื่อผู้ใช้'),
                const SizedBox(height: 20),
                _buildTextField(controller: _passwordController, hintText: 'รหัสผ่าน', obscureText: true),
                const SizedBox(height: 20),
                _buildTextField(controller: _confirmPasswordController, hintText: 'ยืนยันรหัสผ่าน', obscureText: true),
                                
                const SizedBox(height: 10),

                // ส่วนแสดงข้อความแจ้งเตือนสีแดง
                if (_hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),

                // ปุ่มลงทะเบียน
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBC02D), Color(0xFFF9A825)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_usernameController.text.isEmpty || 
                            _passwordController.text.isEmpty || 
                            _confirmPasswordController.text.isEmpty) {
                          // กรณีมีช่องว่าง
                          _hasError = true;
                          _errorMessage = "กรุณากรอกข้อมูลให้ครบทุกช่อง";
                        } else if (_passwordController.text != _confirmPasswordController.text) {
                          // กรณีรหัสผ่านไม่ตรงกัน
                          _hasError = true;
                          _errorMessage = "รหัสผ่านไม่ตรงกัน กรุณาลองอีกครั้ง";
                        } else {
                          // กรณีผ่านฉลุย
                          _hasError = false;
                          _errorMessage = "";
                          print("ลงทะเบียนสำเร็จ");
                          Navigator.pop(context); // กลับไปหน้า Login
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      'ลงทะเบียน',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                
                // ปุ่มย้อนกลับ 
                const SizedBox(height: 30,),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ย้อนกลับ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF202939), // สีน้ำเงินเข้ม
                      decoration: TextDecoration.underline, // ขีดเส้นใต้
                      fontFamily: 'Arial', // หรือฟอนต์ภาษาไทยของคุณตั้งค่าไว้
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}