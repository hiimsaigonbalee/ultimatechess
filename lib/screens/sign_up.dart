import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _emailInvalid = false;
  bool _passwordInvalid = false;
  bool _confirmPasswordInvalid = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void onSignUpClicked() async {
    setState(() {
      _emailInvalid = !_emailController.text.contains("@");
      _passwordInvalid = _passwordController.text.length < 6;
      _confirmPasswordInvalid = _passwordController.text != _confirmPasswordController.text;
    });

    if (!_emailInvalid && !_passwordInvalid && !_confirmPasswordInvalid) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo tài khoản thành công!')),
        );
        // Quay về trang đăng nhập
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo trục dọc
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo trục ngang
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20), // Khoảng cách dưới animation
                  child: Container(
                    height: 150, // Chiều cao mong muốn
                    width: 150,  // Chiều rộng mong muốn
                    child: Lottie.asset(
                      'assets/animations/chess.json', // Đường dẫn đến tệp Lottie
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 60), // Khoảng cách dưới tiêu đề
                  child: Text(
                    'ULTIMATE CHESS',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Permanent Marker',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center, // Căn giữa tiêu đề
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: TextField(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'EMAIL',
                      errorText: _emailInvalid ? "Email không hợp lệ" : null,
                      labelStyle: const TextStyle(
                        color: Color(0xff888888),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      TextField(
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'MẬT KHẨU',
                          errorText: _passwordInvalid ? "Mật khẩu không hợp lệ" : null,
                          labelStyle: const TextStyle(
                            color: Color(0xff888888),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onToggleShowPass,
                        child: Text(
                          _showPassword ? "ẨN" : "HIỆN",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      TextField(
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword, // Dùng biến điều khiển hiển thị
                        decoration: InputDecoration(
                          labelText: 'XÁC NHẬN MẬT KHẨU',
                          errorText: _confirmPasswordInvalid ? "Mật khẩu không khớp" : null,
                          labelStyle: const TextStyle(
                            color: Color(0xff888888),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword; // Đổi trạng thái hiển thị
                          });
                        },
                        child: Text(
                          _showConfirmPassword ? "ẨN" : "HIỆN",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onPressed: onSignUpClicked,
                    child: const Text(
                      "ĐĂNG KÝ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onToggleShowPass() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
}