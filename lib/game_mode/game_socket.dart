// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class GameSocket {
//   static final GameSocket _instance = GameSocket._internal();
//   late IO.Socket socket;
//
//   factory GameSocket() {
//     return _instance;
//   }
//
//   void listenToGameEvents({
//     required Function(Map<String, dynamic>) onGameCreated,
//     required Function(Map<String, dynamic>) onGameJoined,
//     required Function(Map<String, dynamic>) onMoveMade,
//     required Function(String) onWeatherChanged,
//     required Function(Map<String, dynamic>) onGameOver,
//   }) {
//     socket.on('gameCreated', onGameCreated);
//     socket.on('gameJoined', onGameJoined);
//     socket.on('moveMade', onMoveMade);
//     socket.on('weatherChanged', (data) => onWeatherChanged(data['weather']));
//     socket.on('gameOver', onGameOver);
//   }
//
//   void sendChatMessage(String gameId, String playerId, String message) {
//     socket.emit('sendMessage', {
//       'gameId': gameId,
//       'playerId': playerId,
//       'message': message
//     });
//   }
//
//   GameSocket._internal();
//
//   void initSocket() {
//     socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//
//     socket.connect();
//
//     // Xử lý các sự kiện kết nối
//     socket.onConnect((_) {
//       print('Connected to server');
//     });
//
//     socket.onDisconnect((_) {
//       print('Disconnected from server');
//     });
//
//     socket.onError((error) {
//       print('Error: $error');
//     });
//   }
//
//   void createGame(String playerId) {
//     socket.emit('createGame', {'playerId': playerId});
//   }
//
//   void joinGame(String gameId, String playerId) {
//     socket.emit('joinGame', {
//       'gameId': gameId,
//       'playerId': playerId,
//     });
//   }
//
//   void makeMove(String gameId, int fromRow, int fromCol, int toRow, int toCol) {
//     socket.emit('makeMove', {
//       'gameId': gameId,
//       'fromRow': fromRow,
//       'fromCol': fromCol,
//       'toRow': toRow,
//       'toCol': toCol,
//     });
//   }
//
//   void disconnect() {
//     socket.disconnect();
//   }
// }