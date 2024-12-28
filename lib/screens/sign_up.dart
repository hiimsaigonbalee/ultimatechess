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
  bool _isLoading = false; // Trạng thái tải

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void updateInvalidStates() {
    setState(() {
      _emailInvalid = !isValidEmail(_emailController.text);
      _passwordInvalid = _passwordController.text.length < 6;
      _confirmPasswordInvalid = _passwordController.text != _confirmPasswordController.text;
    });
  }

  void onSignUpClicked() async {
    updateInvalidStates();

    if (!_emailInvalid && !_passwordInvalid && !_confirmPasswordInvalid) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo tài khoản thành công!')),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Đã có lỗi xảy ra.';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email đã được sử dụng.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Mật khẩu quá yếu.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Trạng thái tải
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 150,
                    width: 150,
                    child: Lottie.asset('assets/animations/chess.json', fit: BoxFit.cover),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Text(
                    'ULTIMATE CHESS',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Permanent Marker',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
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
                          errorText: _passwordInvalid ? "Mật khẩu quá ngắn" : null,
                          labelStyle: const TextStyle(
                            color: Color(0xff888888),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
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
                        obscureText: !_showConfirmPassword,
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
                            _showConfirmPassword = !_showConfirmPassword;
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}