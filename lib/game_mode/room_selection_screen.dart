import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ultimatechess/game_mode/play_online_screen.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class RoomSelectionScreen extends StatefulWidget {
  @override
  _RoomSelectionScreenState createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final TextEditingController roomIdController = TextEditingController();
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("games");
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  void fetchRooms() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          rooms = [];
          data.forEach((key, value) {
            rooms.add({
              'roomId': key,
              'image': value['image'] ?? "assets/animations/room.json",
              'players': value['players'],
              'playerCount': (value['players']['player1'] != 'waiting'
                  ? 1
                  : 0) +
                  (value['players']['player2'] != 'waiting' ? 1 : 0),
            });
          });
        });
      }
    });
  }

  String generateRoomId() {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
      6,
          (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Đợi tí..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void createRoom() {
    showLoadingDialog(context);
    String roomId = generateRoomId();
    databaseRef.child(roomId).set({
      "players": {
        "player1": "waiting",
        "player2": "waiting"
      },
      "image": "assets/animations/room.json",
      "currentBoardState": [],
      "latestMove": null,
      "turn": "player1",
    }).then((_) {
      hideLoadingDialog(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayOnlineScreen(roomId: roomId),
        ),
      );
    }).catchError((error) {
      hideLoadingDialog(context);
      _showDialog("Không tìm thấy phòng: $error");
    });
  }

  void joinRoom(String roomId) {
    showLoadingDialog(context);
    databaseRef.child(roomId).get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        if (data["players"]["player1"] == "waiting") {
          databaseRef.child(roomId).update({
            "players/player1": "joined",
          });
        } else if (data["players"]["player2"] == "waiting") {
          databaseRef.child(roomId).update({
            "players/player2": "joined",
          });
        } else {
          hideLoadingDialog(context);
          _showDialog("Phòng đã đầy.");
          return;
        }

        hideLoadingDialog(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayOnlineScreen(roomId: roomId),
          ),
        );
      } else {
        hideLoadingDialog(context);
        _showDialog("Room does not exist.");
      }
    }).catchError((error) {
      hideLoadingDialog(context);
      _showDialog("Failed to join room: $error");
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Trả về true để cho phép quay lại mà không cần xác nhận
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CHỌN PHÒNG',
            style: TextStyle(
              fontFamily: 'Dancing Script',
              fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.blue[200],
          iconTheme: IconThemeData(
            color: Colors.white, // Đổi màu nút "Back"
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 50,
                    mainAxisSpacing: 50,
                    childAspectRatio: 1, // Đảm bảo tỷ lệ cố định giữa chiều cao và chiều rộng
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return GestureDetector(
                      onTap: () {
                        joinRoom(room['roomId']);
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các nội dung
                          children: [
                            SizedBox(
                              height: 100, // Đặt chiều cao cố định cho hình ảnh
                              width: double.infinity,
                              child: Lottie.asset(
                                room['image'],
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Room: ${room['roomId']}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${room['playerCount']}/2 người chơi",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: createRoom,
                icon: Icon(Icons.add_circle, size: 20, color: Colors.white),
                label: Text(
                  'Tạo phòng mới',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: roomIdController,
                decoration: InputDecoration(
                  labelText: 'Nhâp ID phòng',
                  labelStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.vpn_key, color: Colors.blue[200]),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  String roomId = roomIdController.text.trim();
                  if (roomId.isNotEmpty) {
                    joinRoom(roomId);
                  } else {
                    _showDialog("Vui lòng nhập ID phòng hợp lệ.");
                  }
                },
                icon: Icon(Icons.login, size: 20, color: Colors.white),
                label: Text(
                  'Vào phòng',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}