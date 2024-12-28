import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailInvalid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void onSendResetLink() async {
    setState(() {
      _emailInvalid = !_emailController.text.contains("@");
    });

    if (!_emailInvalid) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi email khôi phục mật khẩu.')),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Không tìm thấy tài khoản với email này.';
            break;
          case 'invalid-email':
            errorMessage = 'Email không hợp lệ.';
            break;
          default:
            errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 150,
                    width: 150,
                    child: Lottie.asset(
                      'assets/animations/chess.json', // Đường dẫn tới tệp Lottie
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Text(
                    'QUÊN MẬT KHẨU',
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
                    onPressed: onSendResetLink,
                    child: const Text(
                      "GỬI EMAIL KHÔI PHỤC",
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
}
