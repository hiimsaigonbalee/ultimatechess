import 'package:flutter/material.dart';
import 'package:ultimatechess/screens/game_mode_selection.dart';
import 'package:ultimatechess/screens/sign_up.dart';
import 'package:ultimatechess/screens/forgot_password.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Tạo các TextEditingController để quản lý dữ liệu đầu vào từ các ô nhập liệu
  final String _usernameError = "Tài khoản không hợp lệ";
  final String _passwordError = "Mật khẩu không hợp lệ";

  // Biến cờ để xác định tài khoản/mật khẩu có hợp lệ không
  bool _usernameInvalid = false;
  bool _passwordInvalid = false;

  bool _showPassword = false;  // Biến điều khiển việc hiển thị/ẩn mật khẩu

  // Hủy controller để giải phóng tài nguyên khi không còn cần dùng đến
  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea đảm bảo nội dung không bị tràn ra khỏi khu vực an toàn của màn hình
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
                // Phần Lottie animation
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
                                  color: Color(0xff888888), // Màu mặc định cho "NEW USER?"
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: "ĐĂNG KÝ",
                                style: TextStyle(
                                  color: Colors.blue, // Màu xanh cho "SIGN UP"
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

  // Hàm xử lý khi bấm nút "SIGN IN"
  void onSignInClicked() {
    setState(() {
      // Kiểm tra nếu tài khoản không chứa "@" hoặc có độ dài nhỏ hơn 6 ký tự thì không hợp lệ
      _usernameInvalid = _userController.text.length < 6 || !_userController.text.contains("@");
      // Kiểm tra nếu mật khẩu có độ dài nhỏ hơn 6 ký tự thì không hợp lệ
      _passwordInvalid = _passwordController.text.length < 6;
      // Nếu cả tài khoản và mật khẩu hợp lệ, chuyển hướng tới trang GameBoard
      if (!_usernameInvalid && !_passwordInvalid) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  GameModeSelection()));
      }
    });
  }

  // Hàm chuyển đổi trạng thái ẩn/hiện mật khẩu
  void onToggleShowPass() {
    setState(() {
      _showPassword = !_showPassword; // Thay đổi trạng thái hiển thị mật khẩu
    });
  }
}