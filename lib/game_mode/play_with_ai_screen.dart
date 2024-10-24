import 'package:flutter/material.dart';
import '../game_board.dart'; // Giả sử bạn đã có màn hình game board

class PlayWithAiScreen extends StatefulWidget {
  @override
  _PlayWithAiScreenState createState() => _PlayWithAiScreenState();
}

class _PlayWithAiScreenState extends State<PlayWithAiScreen> {
  // Thêm biến để xác định lượt chơi (người hay AI)
  bool isPlayerTurn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: GameBoard( // Gọi lại màn hình bàn cờ chung
        onMove: (move) {
          if (isPlayerTurn) {
            setState(() {
              isPlayerTurn = false;
            });
            // Gọi hàm AI thực hiện nước đi
            Future.delayed(Duration(seconds: 1), () {
              setState(() {
                // Logic cho AI move ở đây
                isPlayerTurn = true; // Sau khi AI đi, trả lại lượt cho người chơi
              });
            });
          }
        },
      ),
    );
  }
}
