import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // เหลือแค่ 3 ช่อง: อีเมล, รหัสผ่าน, ยืนยันรหัสผ่าน
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _errorMessage = "";
  bool _hasError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสมัครสมาชิกและบันทึกข้อมูลลง Firestore
  Future<void> _registerAccount() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 1. สร้างบัญชีผู้ใช้ใหม่ใน Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. ดึงรหัส UID ของคนที่เพิ่งสมัครสำเร็จ
      String uid = userCredential.user!.uid;

      // 3. บันทึกเฉพาะข้อมูลที่มีลง Cloud Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // เก็บแค่เวลาที่สมัคร และ อีเมล
      });

      // 4. ถ้าสำเร็จ ให้กลับไปหน้า Login และแสดงข้อความ
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างบัญชีสำเร็จ! กรุณาเข้าสู่ระบบ', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // ให้ป๊อปอัปเด้งลอยๆ สวยๆ
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _hasError = true;
        if (e.code == 'weak-password') {
          _errorMessage = "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร";
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = "อีเมลนี้ถูกใช้งานไปแล้ว";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "รูปแบบอีเมลไม่ถูกต้อง";
        } else {
          _errorMessage = e.message ?? "เกิดข้อผิดพลาด กรุณาลองใหม่";
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "ไม่สามารถเชื่อมต่อฐานข้อมูลได้";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันวาดช่องกรอกข้อมูล
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // ล็อกพื้นสีขาวไว้
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
        // ✅ บังคับสีตัวอักษรเป็นสีเข้มเสมอ (เหมือนหน้า Login)
        style: const TextStyle(color: Color(0xFF202939), fontWeight: FontWeight.w600), 
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Arial'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ นำ Theme มาครอบเหมือนกับหน้า LoginScreen เพื่อบังคับเป็น Light Mode
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFBC02D),
      ),
      child: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD147), Color(0xFFFFF9E3)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'pictures/PikaWatt_Logo.png',
                      width: 160,
                      height: 160,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pika',
                            style: TextStyle(color: Color(0xFF202939)),
                          ),
                          TextSpan(
                            text: 'Watt',
                            style: TextStyle(color: Color(0xFFF7941D)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ช่องกรอกข้อมูลเหลือ 3 ช่อง
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'อีเมล (Email)',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'รหัสผ่าน',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'ยืนยันรหัสผ่าน',
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    // ส่วนแสดง Error
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

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
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_emailController.text.trim().isEmpty ||
                                    _passwordController.text.trim().isEmpty ||
                                    _confirmPasswordController.text.trim().isEmpty) {
                                  setState(() {
                                    _hasError = true;
                                    _errorMessage = "กรุณากรอกข้อมูลให้ครบทุกช่อง";
                                  });
                                } else if (_passwordController.text !=
                                    _confirmPasswordController.text) {
                                  setState(() {
                                    _hasError = true;
                                    _errorMessage = "รหัสผ่านไม่ตรงกัน กรุณาลองอีกครั้ง";
                                  });
                                } else {
                                  _registerAccount();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'ลงทะเบียน',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Arial',
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ย้อนกลับ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF202939),
                          decoration: TextDecoration.underline,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
