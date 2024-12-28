import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Nhập thư viện Lottie
import 'package:liquid_swipe/liquid_swipe.dart'; // Nhập thư viện LiquidSwipe
import 'play_with_ai_screen.dart';

class AiModeSelectionScreen extends StatefulWidget {
  @override
  _AiModeSelectionScreenState createState() => _AiModeSelectionScreenState();
}

class _AiModeSelectionScreenState extends State<AiModeSelectionScreen> {
  bool isLoading = false; // Trạng thái loading

  void startLoadingAndNavigate() async {
    setState(() {
      isLoading = true; // Bắt đầu loading
    });

    await Future.delayed(Duration(seconds: 1, milliseconds: 200)); // Thời gian loading

    // Chuyển hướng đến màn hình chơi với AI
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayWithAiScreen(),
      ),
    ).then((_) {
      // Đặt lại trạng thái loading khi quay lại
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          setState(() {
            isLoading = false;
          });
        }
        return true; // Cho phép quay lại
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          iconTheme: IconThemeData(
            color: Colors.white, // Đổi màu nút "Back"
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Trở lại trang trước đó
            },
          ),
          title: Text(
            'Chọn độ khó',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            LiquidSwipe(
              pages: [
                GameModeCard(
                  title: 'KHỞI ĐẦU MỚI',
                  description: "Một chuyến phiêu lưu nhẹ nhàng, hoàn hảo cho những ai mới bắt đầu tìm hiểu về cờ vua.",
                  lottiePath: 'assets/animations/easy_mode.json',
                  backgroundColor: Colors.white,
                  onTap: startLoadingAndNavigate,
                ),
                GameModeCard(
                  title: 'THỬ THÁCH TĂNG DẦN',
                  description: "Một cấp độ đầy thử thách, nơi kỹ năng của bạn sẽ được rèn luyện và phát triển.",
                  lottiePath: 'assets/animations/medium_mode.json',
                  backgroundColor: Colors.lightBlue[200] ?? Colors.blue,
                  onTap: startLoadingAndNavigate,
                ),
                GameModeCard(
                  title: 'BẬC THẦY CỜ VUA',
                  description: "Đối đầu với những thử thách khó khăn nhất, chỉ dành cho những người chơi cờ vua dày dạn kinh nghiệm.",
                  lottiePath: 'assets/animations/hard_mode.json',
                  backgroundColor: Colors.orange[200] ?? Colors.orange,
                  onTap: startLoadingAndNavigate,
                ),
              ],
              fullTransitionValue: 600,
              waveType: WaveType.liquidReveal,
              enableLoop: true,
              positionSlideIcon: 0.5,
              slideIconWidget: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/loading.json', // Đường dẫn tới file Lottie
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final String lottiePath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const GameModeCard({
    Key? key,
    required this.title,
    required this.description,
    required this.lottiePath,
    required this.onTap,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Gọi hàm khi nhấn vào màn hình
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottiePath,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              repeat: true,
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}