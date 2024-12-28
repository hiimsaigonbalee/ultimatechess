import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ultimatechess/game_mode/play_online_screen.dart';

import '../enviroment/weather.dart';

class JoinOrCreateRoomScreen extends StatefulWidget {
  const JoinOrCreateRoomScreen({super.key});

  @override
  State<JoinOrCreateRoomScreen> createState() => _JoinOrCreateRoomScreenState();
}

class _JoinOrCreateRoomScreenState extends State<JoinOrCreateRoomScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> filteredRooms = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String selectedWeather = "sunny";
  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io(
        'http://192.168.1.5:3000', // Địa chỉ server
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to server');
      // Yêu cầu danh sách phòng từ server
      socket.emit("get-rooms");
    });

    socket.on("rooms-list", (data) {
      setState(() {
        rooms = List<Map<String, dynamic>>.from(data);
        filteredRooms = rooms; // Hiển thị tất cả phòng ban đầu
      });
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
    socket.on("error", (data) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data.toString()))
      );
    });

    socket.on("room-full", (data) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phòng đã đầy!"))
      );
    });
  }

  void filterRooms(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRooms = rooms;
      } else {
        filteredRooms = rooms
            .where((room) => room['roomId']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void createRoom(String selectedWeather) async {
    setState(() {
      isLoading = true;
    });

    final roomId = generateRoomId();

    // Emit tạo phòng với thời tiết được chọn
    socket.emit("create-room", {
      "roomId": roomId,
      "weather": selectedWeather
    });

    // Đợi phản hồi từ server
    socket.once("room-created", (data) {
      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayOnlineScreen(
            roomId: roomId,
            initialWeather: selectedWeather,
          ),
        ),
      );
    });

    // Thêm timeout để tránh treo UI
    Future.delayed(Duration(seconds: 5), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Không thể tạo phòng. Vui lòng thử lại!"))
        );
      }
    });
  }

  String generateRoomId() {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random random = Random();
    return List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
  }
  void showWeatherSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedWeather = "sunny"; // Giá trị mặc định là "sunny"

        // Danh sách màu sắc tương ứng với các loại thời tiết
        final weatherColors = {
          "sunny": Colors.orangeAccent, // Màu cam nhạt cho trời nắng
          "rainy": Colors.blueAccent, // Màu xanh dương cho trời mưa
          "cloudy": Colors.grey, // Màu xám cho trời nhiều mây
          "stormy": Colors.deepPurple, // Màu tím đậm cho trời bão
          "snowy": Colors.lightBlueAccent, // Màu xanh nhạt cho tuyết
          "windy": Colors.greenAccent, // Màu xanh lá nhạt cho gió
          "foggy": Colors.teal, // Màu xanh teal cho sương mù
          "forest": Colors.green, // Màu xanh lá cây cho rừng
        };

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bo góc cho hộp thoại
          ),
          title: const Text(
            "Chọn hiệu ứng thời tiết",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 400, // Chiều cao tối đa của danh sách
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: WeatherType.values.length,
                  itemBuilder: (context, index) {
                    final weather = WeatherType.values[index];
                    final weatherName = weather.toString().split('.').last;

                    // Lấy icon và màu sắc tương ứng cho thời tiết
                    final weatherIcon = _getWeatherIcon(weatherName);
                    final weatherColor = weatherColors[weatherName] ?? Colors.black;

                    return ListTile(
                      leading: Icon(
                        weatherIcon,
                        color: selectedWeather == weatherName
                            ? weatherColor // Màu icon thay đổi theo thời tiết được chọn
                            : Colors.grey,
                        size: 30,
                      ),
                      title: Text(
                        weatherName[0].toUpperCase() + weatherName.substring(1),
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedWeather == weatherName
                              ? weatherColor // Màu chữ thay đổi theo thời tiết được chọn
                              : Colors.black,
                          fontWeight: selectedWeather == weatherName
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      tileColor: selectedWeather == weatherName
                          ? weatherColor.withOpacity(0.2) // Màu nền nhẹ theo thời tiết
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        setState(() {
                          selectedWeather = weatherName; // Cập nhật thời tiết được chọn
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
                createRoom(selectedWeather); // Gọi hàm tạo phòng với thời tiết đã chọn
              },
              child: const Text("Tạo phòng"),
            ),
          ],
        );
      },
    );
  }

// Hàm trả về icon tương ứng với thời tiết
  IconData _getWeatherIcon(String weatherName) {
    switch (weatherName) {
      case "sunny":
        return Icons.wb_sunny; // Biểu tượng nắng
      case "rainy":
        return Icons.umbrella; // Biểu tượng mưa
      case "cloudy":
        return Icons.cloud; // Biểu tượng mây
      case "stormy":
        return Icons.thunderstorm; // Biểu tượng bão
      case "snowy":
        return Icons.ac_unit; // Biểu tượng tuyết
      case "windy":
        return Icons.air; // Biểu tượng gió
      case "foggy":
        return Icons.foggy; // Biểu tượng sương mù
      case "forest":
        return Icons.nature; // Biểu tượng rừng
      default:
        return Icons.help; // Biểu tượng mặc định
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Phòng chơi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền chính
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade100, Colors.blue.shade300],
              ),
            ),
            child: Column(
              children: [
                // Thanh tìm kiếm mã phòng
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterRooms,
                    decoration: InputDecoration(
                      hintText: "Tìm mã phòng...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Danh sách phòng
                Expanded(
                  child: filteredRooms.isNotEmpty
                      ? ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: room['status'] == "Đang chờ"
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              room['status'] == "Đang chờ"
                                  ? Icons.people_outline
                                  : Icons.sports_esports,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            "Phòng: ${room['roomId']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${room['players']} người chơi • ${room['status']}",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    _getWeatherIcon(room['weather']), // Hàm lấy icon thời tiết
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    room['weather'].toString(), // Hiển thị thông tin thời tiết
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: room['status'] == "Đang chờ"
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayOnlineScreen(
                                    roomId: room['roomId'],
                                    initialWeather: selectedWeather,
                                  ),
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: room['status'] == "Đang chờ"
                                  ? Colors.blue.shade600
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text("Vào phòng"),
                          ),
                        ),
                      );
                    },
                  )
                      : const Center(
                    child: Text(
                      "Không có phòng nào được tìm thấy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator (nếu đang tạo phòng)
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

      // FloatingActionButton để tạo phòng
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showWeatherSelectionDialog(); // Hiển thị hộp thoại chọn thời tiết
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}