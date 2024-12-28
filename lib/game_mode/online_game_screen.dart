// import 'package:flutter/material.dart';
// import '../game_board.dart';
// import 'game_socket.dart';
//
// class OnlineGameScreen extends StatefulWidget {
//   @override
//   _OnlineGameScreenState createState() => _OnlineGameScreenState();
// }
//
// // online_game_screen.dart
// class _OnlineGameScreenState extends State<OnlineGameScreen> {
//   late List<List<ChessPiece?>> board;
//   WeatherType currentWeather = WeatherType.sunny;
//   List<String> chatMessages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     setupGame();
//   }
//
//   void setupGame() {
//     gameSocket.listenToGameEvents(
//       onGameCreated: handleGameCreated,
//       onGameJoined: handleGameJoined,
//       onMoveMade: handleMoveMade,
//       onWeatherChanged: handleWeatherChanged,
//       onGameOver: handleGameOver,
//     );
//
//     // Listen to chat messages
//     gameSocket.socket.on('message', (data) {
//       setState(() {
//         chatMessages.add('${data['playerId']}: ${data['message']}');
//       });
//     });
//   }
//
//   void handleGameCreated(Map<String, dynamic> data) {
//     setState(() {
//       gameId = data['gameId'];
//       playerColor = data['color'];
//       board = convertBoardData(data['board']);
//     });
//   }
//
//   void handleGameJoined(Map<String, dynamic> data) {
//     setState(() {
//       gameId = data['gameId'];
//       playerColor = data['color'];
//       board = convertBoardData(data['board']);
//       isMyTurn = playerColor == 'white';
//     });
//   }
//
//   void handleMoveMade(Map<String, dynamic> data) {
//     setState(() {
//       // Update the board
//       updateBoard(data['from'], data['to'], data['piece']);
//       isMyTurn = !isMyTurn;
//
//       // Handle captured pieces
//       if (data['capturedPiece'] != null) {
//         handleCapturedPiece(data['capturedPiece']);
//       }
//     });
//   }
//
//   void handleWeatherChanged(String weather) {
//     setState(() {
//       currentWeather = WeatherType.values.firstWhere(
//             (e) => e.toString().split('.').last == weather,
//       );
//     });
//   }
//
//   void handleGameOver(Map<String, dynamic> data) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Game Over'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(data['winner'] == playerColor ? 'You Win!' : 'You Lose!'),
//             Text('Reason: ${data['reason']}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Return to Menu'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Online Chess'),
//         actions: [
//           if (gameId != null) Text('Room: $gameId'),
//           IconButton(
//             icon: Icon(Icons.chat),
//             onPressed: () => _showChatDialog(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Weather display
//           Container(
//             padding: EdgeInsets.all(8),
//             child: Text('Current Weather: ${currentWeather.toString().split('.').last}'),
//           ),
//
//           // Game board
//           Expanded(
//             child: GameBoard(
//               board: board,
//               isPlayerTurn: isMyTurn,
//               playerColor: playerColor,
//               currentWeather: currentWeather,
//               onMove: (fromRow, fromCol, toRow, toCol) {
//                 if (isMyTurn) {
//                   gameSocket.makeMove(
//                     gameId!,
//                     fromRow,
//                     fromCol,
//                     toRow,
//                     toCol,
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showChatDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => ChatDialog(
//         messages: chatMessages,
//         onSendMessage: (message) {
//           gameSocket.sendChatMessage(gameId!, playerColor!, message);
//         },
//       ),
//     );
//   }
// }