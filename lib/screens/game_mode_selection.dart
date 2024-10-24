import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ultimatechess/game_mode/play_with_ai_screen.dart';
import 'package:ultimatechess/game_mode/room_selection_screen.dart';
import 'package:ultimatechess/screens/settings_screen.dart';
import 'package:ultimatechess/screens/profile_screen.dart';
import 'package:ultimatechess/screens/login_page.dart'; // Nhập LoginPage
import 'package:lottie/lottie.dart';

class GameModeSelection extends StatelessWidget {
  const GameModeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[300],
      ),
      backgroundColor: Colors.blue[300],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hoạt ảnh logo
                Container(
                  height: 250, // Chiều cao mong muốn
                  width: 150,  // Chiều rộng mong muốn
                  child: Lottie.asset(
                    'assets/animations/chess_logo.json',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 30), // Thêm khoảng cách

                // Nút "Chơi với AI"
                InkWell(
                  onTap: () {
                    _navigateWithSlideTransition(context, PlayWithAiScreen());
                  },
                  splashColor: Colors.blue.withAlpha(30),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.computer, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'Chơi với máy',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Nút "Chơi Online"
                InkWell(
                  onTap: () {
                    _navigateWithSlideTransition(context, RoomSelectionScreen());
                  },
                  splashColor: Colors.green.withAlpha(30),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'Chơi Online',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Nút "Sign Out"
                InkWell(
                  onTap: () {
                    _logout(context);
                  },
                  splashColor: Colors.red.withAlpha(30),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.blue[300]!,
        animationCurve: Curves.linear,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.settings, size: 30),
          Icon(Icons.info, size: 30),
          Icon(Icons.account_circle, size: 30),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateWithSlideTransition(context, ChessSettingsScreen());
              break;
            case 1:
              _showContactUsDialog(context);
              break;
            case 2:
              _navigateWithSlideTransition(context, ProfileScreen());
              break;
          }
        },
      ),
    );
  }


  // Hàm chuyển màn hình với hiệu ứng slide
  void _navigateWithSlideTransition(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(2.0, 0.0); // Từ phải sang trái
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Hàm hiển thị hộp thoại Contact Us
  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Liên hệ',
          style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho tiêu đề
        ),
        content: Text(
          'Email: lehuynhngocbac@gmail.com\nPhone: +84908009302',
          style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho nội dung
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho nút OK
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho tiêu đề
        ),
        content: Text(
          'Bạn có chắc là mình muốn đăng xuất?',
          style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho nội dung
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Huỷ',
              style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho nút Cancel
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng hộp thoại
              _navigateWithSlideTransition(context, LoginPage()); // Sử dụng hiệu ứng khi chuyển về trang Login
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.bold), // Đặt chữ đậm cho nút Sign Out
            ),
          ),
        ],
      ),
    );
  }
}
