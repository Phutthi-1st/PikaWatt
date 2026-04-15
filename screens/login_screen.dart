import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoginFailed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // ล็อกพื้นหลังเป็นสีขาว
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
        // ✅ บังคับสีตัวอักษรเป็นสีเข้มเสมอ ป้องกันอาการตัวหนังสือสีเทา/ขาว
        style: const TextStyle(color: Color(0xFF202939), fontWeight: FontWeight.w600), 
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'Arial',
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ ครอบด้วย Theme และสั่งให้เป็น ThemeData.light()
    // สิ่งนี้จะทำให้ทุก Widget ที่อยู่ข้างในนี้มองเห็นว่าเป็นโหมดสว่างเสมอ
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
              colors: [
                Color(0xFFFFD147),
                Color(0xFFFFF9E3),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // เพิ่ม Bouncing ให้เลื่อนสมูทขึ้น
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'pictures/PikaWatt_Logo.png',
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 10),

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 20),

                    if (_isLoginFailed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Text(
                          'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    _buildTextField(
                      controller: _usernameController,
                      hintText: 'อีเมล (Email)',
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'รหัสผ่าน',
                      obscureText: true, 
                    ),
                    const SizedBox(height: 40),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFBC02D), 
                            Color(0xFFF9A825), 
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
                        onPressed: _isLoading ? null : () async {
                          setState(() {
                            _isLoginFailed = false;
                            _isLoading = true;
                          });

                          if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                            setState(() {
                              _isLoginFailed = true;
                              _isLoading = false;
                            });
                            return;
                          }

                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _usernameController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _isLoginFailed = true;
                              _isLoading = false;
                            });
                            print('Firebase Login Error: ${e.code}');
                          } catch (e) {
                            setState(() {
                              _isLoginFailed = true;
                              _isLoading = false;
                            });
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
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            )
                          : const Text(
                              'เข้าสู่ระบบ',
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
                      onPressed: () {      
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'ลงทะเบียน',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF202939), 
                          decoration: TextDecoration.underline, 
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🚪 ปุ่ม Guest Mode 
                    TextButton(
                      onPressed: () async {
                        // 1. สั่งเตะคนที่ล็อกอินค้างอยู่ออกไปก่อน (ล้างสมอง Firebase)
                        await FirebaseAuth.instance.signOut();

                        // 2. พอตัวแปร user กลายเป็น null ชัวร์ๆ แล้ว ค่อยพาเข้าหน้า Home
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: Text(
                        'ทดลองใช้งานแบบไม่ล็อกอิน (Guest)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700], 
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
