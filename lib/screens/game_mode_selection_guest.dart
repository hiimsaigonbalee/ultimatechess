import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ultimatechess/screens/settings_screen.dart';
import 'package:ultimatechess/screens/login_page.dart';
import 'package:lottie/lottie.dart';
import 'package:ultimatechess/screens/guide.dart';
import 'package:url_launcher/url_launcher.dart';
import '../game_mode/ai_mode_selection_screen.dart';

class GameModeSelectionGuest extends StatelessWidget {
  const GameModeSelectionGuest({super.key});

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
                  height: 250,
                  width: 150,
                  child: Lottie.asset(
                    'assets/animations/chess_logo.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),

                // Nút "Chơi với AI"
                _buildRoundedButton(
                  label: 'CHƠI VỚI MÁY',
                  color: Colors.white,
                  onTap: () {
                    _navigateWithSlideTransition(context, AiModeSelectionScreen());
                  },
                ),
                const SizedBox(height: 20),

                // Nút "Hướng dẫn chơi"
                _buildRoundedButton(
                  label: 'HƯỚNG DẫN CHƠI',
                  color: Colors.white,
                  onTap: () {
                    _navigateWithSlideTransition(context, GuideScreen());
                  },
                ),
                const SizedBox(height: 20),

                // Nút "Đăng xuất"
                _buildRoundedButton(
                  label: 'ĐĂNG XUẤT',
                  color: Colors.white,
                  onTap: () {
                    _logout(context);
                  },
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
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateWithSlideTransition(context, ChessSettingsScreen());
              break;
            case 1:
              _showContactUsDialog(context);
              break;
          }
        },
      ),
    );
  }

  // Hàm tạo nút bấm bo góc
  Widget _buildRoundedButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withAlpha(30),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40.0), // Bo góc của nút
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3), // Đổ bóng nhẹ
            ),
          ],
        ),
        child: Container(
          width: 100,
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F414E),
                ),
              ),
            ],
          ),
        ),
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
        title: const Text(
          'Liên hệ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kết nối với tôi qua các nền tảng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
                  onPressed: () async {
                    final Uri facebookUrl = Uri.parse('https://www.facebook.com/saigonbalee2003/');
                    try {
                      if (await canLaunchUrl(facebookUrl)) {
                        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Không thể mở URL $facebookUrl';
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.video_library, color: Colors.red, size: 40),
                  onPressed: () async {
                    final Uri youtubeUrl = Uri.parse('https://www.youtube.com/@embaletainam');
                    try {
                      if (await canLaunchUrl(youtubeUrl)) {
                        await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Không thể mở URL $youtubeUrl';
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email, color: Colors.orange, size: 40),
                  onPressed: () async {
                    final Uri emailUrl = Uri(
                      scheme: 'mailto',
                      path: 'lehuynhngocbac@gmail.com',
                      query: 'subject=Liên hệ từ ứng dụng&body=Xin chào!',
                    );
                    try {
                      if (await canLaunchUrl(emailUrl)) {
                        await launchUrl(emailUrl);
                      } else {
                        throw 'Không thể mở ứng dụng Email';
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm Đăng xuất
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có chắc là mình muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Huỷ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
