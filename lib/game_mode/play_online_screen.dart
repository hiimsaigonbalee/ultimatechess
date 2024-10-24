import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../game_board.dart'; // Giả sử bạn đã có màn hình game board

class PlayOnlineScreen extends StatefulWidget {
  final String roomId; // Thêm roomId làm tham số

  PlayOnlineScreen({required this.roomId,});

  @override
  _PlayOnlineScreenState createState() => _PlayOnlineScreenState();
}

class _PlayOnlineScreenState extends State<PlayOnlineScreen> {
  late DatabaseReference databaseRef;
  String latestMove = " ";
  bool isPlayerTurn = true; // Biến để quản lý lượt chơi
  bool isMusicOn = true; // Trạng thái nhạc

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() {
    databaseRef = FirebaseDatabase.instance.ref("games/${widget.roomId}"); // Dùng roomId từ widget

    // Lắng nghe trạng thái ban đầu từ Firebase
    databaseRef.child("turn").get().then((snapshot) {
      if (snapshot.exists) {
        String turn = snapshot.value.toString();
        setState(() {
          isPlayerTurn = (turn == "player1");
        });
      } else {
        print("Turn information is not available.");
      }
    }).catchError((error) {
      print("Failed to fetch turn data: $error");
    });

    listenToMoves(); // Lắng nghe nước đi từ Firebase
  }

  // Lắng nghe nước đi từ đối thủ
  void listenToMoves() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        updateGameState(data);
      } else {
        print("No data received.");
      }
    }, onError: (error) {
      print("Failed to listen to moves: $error");
    });
  }

  void joinRoom(String roomId, String playerName) {
    databaseRef = FirebaseDatabase.instance.ref("games/$roomId");

    databaseRef.child("player1").get().then((snapshot) {
      if (snapshot.exists && snapshot.value.toString() != "waiting") {
        // Nếu đã có player1, kiểm tra player2
        databaseRef.child("player2").get().then((snapshot) {
          if (snapshot.exists && snapshot.value.toString() != "waiting") {
            print("Room is full. Please choose another room.");
          } else {
            // Nếu chưa có player2, tham gia vào
            databaseRef.update({
              "player2": playerName,
              "turn": "player1" // Đặt lượt cho player1
            }).then((_) {
              print("Joined as player2!");
            });
          }
        });
      } else {
        // Nếu chưa có player1, tham gia vào với tư cách là player1
        databaseRef.update({
          "player1": playerName,
          "turn": "player1" // Đặt lượt cho player1
        }).then((_) {
          print("Joined as player1!");
        });
      }
    });
  }
  void leaveRoom(String roomId, String playerName) {
    databaseRef.child("player1").get().then((snapshot) {
      if (snapshot.exists && snapshot.value.toString() == playerName) {
        // Nếu player1 thoát
        databaseRef.update({
          "player1": "waiting", // Đặt lại trạng thái
          "turn": "player1" // Đặt lượt cho player1
        });
      } else {
        // Nếu player2 thoát
        databaseRef.update({
          "player2": "waiting" // Đặt lại trạng thái
        });
      }
    });
  }
  void checkRoomStatus(String roomId) {
    databaseRef = FirebaseDatabase.instance.ref("games/$roomId");

    databaseRef.get().then((snapshot) {
      if (snapshot.exists) {
        String player1Status = snapshot.child("player1").value.toString();
        String player2Status = snapshot.child("player2").value.toString();
        String currentTurn = snapshot.child("turn").value.toString();

        if (player1Status == "waiting" && player2Status == "waiting") {
          print("Room is empty, you can create a new game.");
        } else {
          // Thiết lập lượt chơi cho người chơi hiện tại
          setState(() {
            isPlayerTurn = (currentTurn == "player1");
          });
        }
      } else {
        print("Room does not exist.");
      }
    }).catchError((error) {
      print("Error getting room status: $error");
    });
  }

  void updateGameState(Map data) {
    if (data.containsKey("latestMove")) {
      setState(() {
        latestMove = data["latestMove"];
        isPlayerTurn = (data["turn"] == "player1"); // Cập nhật lượt chơi dựa trên dữ liệu từ Firebase
        // Cập nhật trạng thái bàn cờ nếu cần
        // updateGameBoard(latestMove);
      });
    }
  }

  // Gửi nước đi lên Firebase và chuyển lượt
  void sendMove(String move) {
    if (!isPlayerTurn) {
      print("Không phải lượt của bạn.");
      return; // Không gửi nước đi nếu không phải lượt của người chơi
    }

    // Fetch current turn from Firebase to ensure real-time accuracy
    databaseRef.child("turn").get().then((snapshot) {
      if (snapshot.exists) {
        String currentTurn = snapshot.value.toString();

        // Kiểm tra nếu đúng lượt của người chơi, nếu không thì return
        if ((currentTurn == "player1" && !isPlayerTurn) || (currentTurn == "player2" && isPlayerTurn)) {
          print("It's not your turn yet.");
          return;
        }

        // Nếu tất cả đều ổn, cập nhật nước đi và chuyển lượt
        String nextTurn = (currentTurn == "player1") ? "player2" : "player1"; // Xác định người chơi tiếp theo

        // Cập nhật lượt chơi và nước đi mới lên Firebase
        databaseRef.update({
          "latestMove": move,
          "turn": nextTurn,
        }).then((_) {
          print("Move sent successfully!");
          setState(() {
            isPlayerTurn = false; // Đổi lượt sau khi gửi
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nước đi đã được gửi thành công!")),
          );
        }).catchError((error) {
          print("Failed to send move: $error");
        });
      } else {
        print("Could not determine current turn.");
      }
    }).catchError((error) {
      print("Error getting current turn: $error");
    });
  }


  // Hàm mở Bottom Sheet hiển thị các tùy chọn
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tự điều chỉnh chiều cao theo nội dung
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.music_note),
                title: Text('Nhạc nền'),
                trailing: Switch(
                  value: isMusicOn,
                  onChanged: (bool value) {
                    setState(() {
                      isMusicOn = value; // Cập nhật trạng thái nhạc
                      // Thực hiện logic bật/tắt nhạc tại đây
                    });
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Đầu hàng'),
                onTap: () {
                  // Xác nhận đầu hàng
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Xác nhận"),
                        content: Text("Bạn có chắc chắn muốn đầu hàng không?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              databaseRef.update({"winner": "player2"}); // Cập nhật người thắng
                              Navigator.pop(context); // Đóng dialog
                            },
                            child: Text("Có"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context), // Đóng dialog
                            child: Text("Không"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Thoát trận đấu'),
                onTap: () {
                  // Gọi hàm thoát phòng
                  Navigator.pop(context); // Đóng Bottom Sheet
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300], // Màu nền AppBar
        title: Text(
          'Room ID: ${widget.roomId}',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white, // Màu chữ
          ),
        ),
        centerTitle: true, // Đặt tiêu đề ở giữa
        elevation: 4, // Thêm shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Màu biểu tượng
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white), // Biểu tượng cài đặt
            onPressed: () {
              _showSettingsBottomSheet(context); // Mở màn hình cài đặt khi nhấn
            },
          ),
        ],
      ),
      body: GameBoard(
        onMove: (move) {
          sendMove(move); // Gửi nước đi lên Firebase
        },
      ),
    );
  }
}
