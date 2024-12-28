import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../components/piece.dart';
import '../enviroment/weather.dart';
import '../game_board.dart';


class PlayOnlineScreen extends StatefulWidget {
  final String roomId;
  final String initialWeather;
  const PlayOnlineScreen({Key? key, required this.roomId, this.initialWeather = 'sunny'}) : super(key: key);

  @override
  _PlayOnlineScreenState createState() => _PlayOnlineScreenState();
}

class _PlayOnlineScreenState extends State<PlayOnlineScreen> {
  late IO.Socket socket;
  String? playerColor;
  bool isPlayerTurn = false;
  bool isRoomReady = false;
  List<List<ChessPiece?>> board = List.generate(8, (_) => List.filled(8, null));
  WeatherType currentWeather = WeatherType.sunny;


  @override
  void initState() {
    super.initState();
    connectToServer();
    currentWeather = _parseWeatherFromString(widget.initialWeather);
  }

  void connectToServer() {
    socket = IO.io(
      'http://192.168.1.5:3000', // Thay YOUR_COMPUTER_IP bằng IP thật của máy tính
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionAttempts(5) // Thêm số lần thử kết nối lại
          .setReconnectionDelay(1000) // Delay giữa các lần thử kết nối
          .build(),
    );

    setupSocketListeners();
  }

  void setupSocketListeners() {
    socket.onConnect((_) {
      print('Connected to server with ID: ${socket.id}');
      print('Trying to join room: ${widget.roomId}');
      socket.emit("join-room", {'roomId': widget.roomId});
    });

    socket.on("error", (data) {
      print('Socket error: $data');
      showError(data.toString());
    });

    socket.on("room-status", (data) {
      setState(() {
        isRoomReady = data['players']?.length == 2; // Kiểm tra nếu phòng đủ 2 người chơi

        final players = data['players'] as List;
        playerColor = players.firstWhere(
                (p) => p['id'] == socket.id,
            orElse: () => null
        )?['color'];

        isPlayerTurn = data['currentTurn'] == socket.id; // Xác định lượt chơi
        board = parseBoardFromServer(data['board']); // Đồng bộ bàn cờ
        currentWeather = _parseWeatherFromString(data['weather']); // Đồng bộ thời tiết
      });

      // In log để kiểm tra trạng thái phòng
      print("ROOM STATUS: $data");
    });

    socket.on("game-update", (data) {
      setState(() {
        final moveData = data['move'];
        board[moveData['endRow']][moveData['endCol']] =
        board[moveData['startRow']][moveData['startCol']];
        board[moveData['startRow']][moveData['startCol']] = null;

        isPlayerTurn = moveData['currentTurn'] == socket.id;
        currentWeather = _parseWeatherFromString(data['weather']);
      });
    });

    socket.on("player-left", (message) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Game Ended"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  List<List<ChessPiece?>> parseBoardFromServer(List<dynamic> serverBoard) {
    return List.generate(8, (row) => List.generate(8, (col) {
      final pieceData = serverBoard[row][col];
      if (pieceData == null) return null;
      return ChessPiece(
        type: ChessPieceType.values.firstWhere(
                (e) => e.toString().split('.').last.toLowerCase() == pieceData['type']
        ),
        isWhite: pieceData['isWhite'],
        imagePath: "lib/images/${pieceData['type']}.png",
      );
    }));
  }

  WeatherType _parseWeatherFromString(String weatherStr) {
    return WeatherType.values.firstWhere(
          (w) => w.toString().split('.').last == weatherStr,
      orElse: () => WeatherType.sunny,
    );
  }

  bool canMovePiece(ChessPiece piece) {
    if (playerColor == null) return false;
    return (playerColor == 'white' && piece.isWhite) ||
        (playerColor == 'black' && !piece.isWhite);
  }

  void sendMove(int startRow, int startCol, int endRow, int endCol) {
    if (!isPlayerTurn) {
      showError("Not your turn!");
      return;
    }

    ChessPiece? piece = board[startRow][startCol];
    if (piece == null || !canMovePiece(piece)) {
      showError("Cannot move this piece!");
      return;
    }

    socket.emit("move", {
      "roomId": widget.roomId,
      "startRow": startRow,
      "startCol": startCol,
      "endRow": endRow,
      "endCol": endCol,
    });
}
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room: ${widget.roomId}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(playerColor?.toUpperCase() ?? "SPECTATOR"),
                Text(isPlayerTurn ? "YOUR TURN" : "WAITING"),
              ],
            ),
          ),
        ],
      ),
      body: isRoomReady
          ? GameBoard(
        board: board,
        isPlayerTurn: isPlayerTurn,
        onMove: sendMove,
        currentWeather: currentWeather,
        playerColor: playerColor,
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Waiting for opponent..."),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
}
