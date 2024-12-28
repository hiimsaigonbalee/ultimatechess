import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ultimatechess/screens/game_mode_selection.dart';
import 'package:ultimatechess/screens/sign_up.dart';
import 'package:ultimatechess/screens/forgot_password.dart';
import 'package:lottie/lottie.dart';
import 'game_mode_selection_guest.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _usernameError = "Tài khoản không hợp lệ";
  final String _passwordError = "Mật khẩu không hợp lệ";

  bool _usernameInvalid = false;
  bool _passwordInvalid = false;

  bool _showPassword = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 150,
                    width: 150,
                    child: Lottie.asset(
                      'assets/animations/chess.json',
                      fit: BoxFit.cover,
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: 'TÀI KHOẢN',
                          errorText: _usernameInvalid ? _usernameError : null,
                          labelStyle: const TextStyle(
                            color: Color(0xff888888),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          TextField(
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'MẬT KHẨU',
                              errorText: _passwordInvalid ? _passwordError : null,
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
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameModeSelectionGuest(),
                            ),
                          );
                        },
                        child: const Text(
                          "CHƠI CHẾ ĐỘ KHÁCH",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
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
                    onPressed: onSignInClicked,
                    child: const Text(
                      "ĐĂNG NHẬP",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "CHƯA CÓ? ",
                                style: TextStyle(
                                  color: Color(0xff888888),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: "ĐĂNG KÝ",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          "QUÊN MẬT KHẨU",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSignInClicked() async {
    setState(() {
      _usernameInvalid = _userController.text.isEmpty || !_userController.text.contains("@");
      _passwordInvalid = _passwordController.text.length < 6;
    });

    if (!_usernameInvalid && !_passwordInvalid) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userController.text.trim(),
          password: _passwordController.text,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => GameModeSelection()));
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Đăng nhập thất bại.';
        if (e.code == 'user-not-found') {
          errorMessage = 'Không tìm thấy tài khoản này.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Sai mật khẩu.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void onToggleShowPass() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
}