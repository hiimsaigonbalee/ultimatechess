import 'package:flutter/material.dart';
import 'package:ultimatechess/game_mode/play_online_screen.dart';
import '../enviroment/weather.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:ultimatechess/components/dead_piece.dart';
import 'package:ultimatechess/components/piece.dart';
import 'package:ultimatechess/components/square.dart';
import 'package:ultimatechess/helper/helper_methods.dart';
import 'package:audioplayers/audioplayers.dart';

import '../screens/guide.dart';

class PlayWithAiScreen extends StatefulWidget {
  @override
  _PlayWithAiScreenState createState() => _PlayWithAiScreenState();
}

class _PlayWithAiScreenState extends State<PlayWithAiScreen> {
  late List<List<ChessPiece?>> board;
  late AudioPlayer _audioPlayer;
  bool isMusicOn = true;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  //Danh sách các nước đi hợp lệ
  List<List<int>> validMoves = [];

  //Khu vụực các quân cờ khi chết
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  //Xác định lượt của người chơi (true là trắng)
  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  WeatherType currentWeather = WeatherType.sunny;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _setRandomWeather();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
  }
//Khởi tạo nhạc
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sound/background.mp3'));
  }

//Khởi tạo bàn cờ
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
    List.generate(8, (index) => List.generate(8, (index) => null));

    // Khởi tạo quân Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/images/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/images/pawn.png',
      );
    }

    // Khởi tạo quân Rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/rook.png',
    );

    // Khởi tạo quân Knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/knight.png',
    );

    // Khởi tạo quân Bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/bishop.png',
    );

    // Khởi tạo quân Queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/images/queen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/images/queen.png',
    );

    // Khởi tạo quân Kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/images/king.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/images/king.png',
    );

    board = newBoard;
  }

  //Xử lí khi quân cờ được chọn
  void pieceSelected(int row, int col) {
    setState(() {
      // Nếu chưa chọn quân cờ nào và ô hiện tại có quân cờ
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } // Nếu đã chọn một quân cờ khác nhưng quân cờ đó cùng màu
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } // Nếu nước đi là hợp lệ thì di chuyển quân cờ
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      } // Tính toán nước đi hợp lệ cho quân cờ đã chọn
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }


  //Nước đi hợp lệ của các quân cờ
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
      // Di chuyển thẳng
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Di chuyển 2 ô từ vị trí ban đầu
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Ăn chéo
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        if (currentWeather == WeatherType.rainy) {
          if (isInBoard(row + direction, col - 1) &&
              board[row + direction][col - 1] == null) {
            candidateMoves.add([row + direction, col - 1]);
          }
          if (isInBoard(row + direction, col + 1) &&
              board[row + direction][col + 1] == null) {
            candidateMoves.add([row + direction, col + 1]);
          }
        } else if (currentWeather == WeatherType.foggy) {
          // Chỉ di chuyển một ô trong sương mù
          if (isInBoard(row + direction, col) &&
              board[row + direction][col] == null) {
            candidateMoves = [[row + direction, col]];
          }
        } else if (currentWeather == WeatherType.forest) {
          // Trong rừng, tốt chỉ có thể di chuyển một ô về phía trước
          if (isInBoard(row + direction, col) &&
              board[row + direction][col] == null) {
            candidateMoves = [[row + direction, col]];
          }
        }
        break;

      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [2, -1], [2, 1], [1, -2], [1, 2],
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null ||
              board[newRow][newCol]!.isWhite != piece.isWhite)) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        if (currentWeather == WeatherType.windy) {
          var extraMoves = [
            [-3, 0], [3, 0], [0, -3], [0, 3],
          ];
          for (var move in extraMoves) {
            var newRow = row + move[0];
            var newCol = col + move[1];
            if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null ||
                board[newRow][newCol]!.isWhite != piece.isWhite)) {
              candidateMoves.add([newRow, newCol]);
            }
          }
        } else if (currentWeather == WeatherType.stormy) {
          // Giới hạn di chuyển của mã khi có bão
          candidateMoves = [];
        }
        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1, -1], [1, 1], [-1, 1], [1, -1]
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
            if (currentWeather == WeatherType.snowy && i >= 2) break;
            if (currentWeather == WeatherType.forest && i >= 2)
              break; // Giới hạn di chuyển tối đa 2 ô trong rừng
          }
        }
        break;

      case ChessPieceType.queen:
        var directions = [
          [-1, 0], [1, 0], [0, 1], [0, -1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
            if (currentWeather == WeatherType.snowy && i >= 2) break;
            if ((currentWeather == WeatherType.rainy ||
                currentWeather == WeatherType.forest) && i >= 2)
              break; // Giới hạn di chuyển tối đa 2 ô trong mưa và rừng
          }
        }
        break;

      case ChessPieceType.king:
        var directions = [
          [-1, 0], [1, 0], [0, 1], [0, -1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null ||
              board[newRow][newCol]!.isWhite != piece.isWhite)) {
            candidateMoves.add([newRow, newCol]);
          }

          if (currentWeather == WeatherType.windy) {
            var windyRow = row + 2 * direction[0];
            var windyCol = col + 2 * direction[1];
            if (isInBoard(windyRow, windyCol) &&
                (board[windyRow][windyCol] == null ||
                    board[windyRow][windyCol]!.isWhite != piece.isWhite)) {
              candidateMoves.add([windyRow, windyCol]);
            }
          } else if (currentWeather == WeatherType.foggy) {
            // Giới hạn di chuyển của vua trong sương mù
            candidateMoves = [];
          } else if (currentWeather == WeatherType.stormy) {
            if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null ||
                board[newRow][newCol]!.isWhite != piece.isWhite)) {
              candidateMoves.add([newRow, newCol]);
            }
          } else if (currentWeather == WeatherType.forest) {
            // Vua chỉ có thể di chuyển một ô trong rừng
            if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null ||
                board[newRow][newCol]!.isWhite != piece.isWhite)) {
              candidateMoves = [[newRow, newCol]];
            }
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }

  //Tính toán giá trị thật của các quân cờ
  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece,
      bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void onMove(ChessPiece piece, int startRow, int startCol, int endRow,
      int endCol) {
    // Xử lý khi một quân cờ được di chuyển
    print(
        "Quân ${piece.type} từ ($startRow, $startCol) tới ($endRow, $endCol)");
    // Bạn có thể thêm mã để cập nhật cơ sở dữ liệu hoặc trạng thái khác tại đây
  }

  void movePiece(int newRow, int newCol) {
    if (selectedPiece == null) return;

    // Kiểm tra bắt quân
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
      onMove(selectedPiece!, selectedRow, selectedCol, newRow, newCol);
    }

    // Cập nhật vị trí của vua nếu cần thiết
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Di chuyển quân cờ và xóa vị trí cũ
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Kiểm tra xem vua có bị chiếu không
    checkStatus = isKingInCheck(!isWhiteTurn);

    // Bỏ lựa chọn và cập nhật trạng thái
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Kiểm tra chiếu bí
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("CHECK MATE!!"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      );
    }

    // Đổi lượt
    isWhiteTurn = !isWhiteTurn;

    if (!isWhiteTurn) {
      _makeAIMove();
    }

  }

  //Chiếu
  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
    isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
        move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol,
      int endRow, int endCol) {
    ChessPiece? originalDestination = board[endRow][endCol];

    List<int> ?originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
      piece.isWhite ? whiteKingPosition : blackKingPosition;

      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestination;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  //Chiếu bí?
  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i, j, board[i][j], true);
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }
  void _makeAIMove() {
    List<List<int>> allValidMoves = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhiteTurn) {
          var moves = calculateRealValidMoves(i, j, board[i][j], true);
          for (var move in moves) {
            allValidMoves.add([i, j, move[0], move[1]]);
          }
        }
      }
    }
    if (allValidMoves.isNotEmpty) {
      final random = Random();
      var move = allValidMoves[random.nextInt(allValidMoves.length)];
      selectedPiece = board[move[0]][move[1]];
      selectedRow = move[0];
      selectedCol = move[1];
      movePiece(move[2], move[3]);
    }
  }

  //Chơi lại
  void resetGame() {
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    currentWeather = WeatherType.sunny;
    setState(() {});
  }

  void _setRandomWeather() {
    final random = Random();
    currentWeather =
    WeatherType.values[random.nextInt(WeatherType.values.length)];
  }
  void toggleMusic() {
    setState(() {
      if (isMusicOn) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.resume();
      }
      isMusicOn = !isMusicOn;
    });
  }

  void showSurrenderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bạn có chắc chắn muốn đầu hàng?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text('Đồng ý'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
// Hộp thoại xác nhận thoát trận
  void showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thoát trận"),
          content: Text("Bạn có chắc muốn thoát trận không?"),
          actions: [
            TextButton(
              child: Text("Không"),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text("Có"),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.pop(context); // Quay lại màn hình trước
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getWeatherBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.white),
        onSelected: (value) {
          switch (value) {
            case 'Tắt nhạc':
              toggleMusic();
              break;
            case 'Đầu hàng':
              showSurrenderDialog();
              break;
            case 'Thoát trận':
              showExitConfirmationDialog();
              break;
            case 'Hướng dẫn chơi':
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => GuideScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Trượt từ bên phải
                    const end = Offset.zero; // Dừng ở vị trí hiện tại
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
              break;
          }
        },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Tắt nhạc',
                  child: Row(
                    children: [
                      Icon(
                        isMusicOn ? Icons.music_note : Icons.music_off,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 10),
                      Text(
                        isMusicOn ? 'Tắt nhạc' : 'Bật nhạc',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Đầu hàng',
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Đầu hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Thoát trận',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        'Thoát trận',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Hướng dẫn chơi',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Hướng dẫn chơi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            offset: Offset(0, 55),
            elevation: 8,
            color: Colors.white, // Màu nền của menu
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GridView.builder(
                  itemCount: whitePiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: whitePiecesTaken[index].imagePath,
                    isWhite: true,
                  ),
                ),
              ),
              Text(
                checkStatus ? "CHIẾU!" : "",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _getWeatherBackgroundColor(),
                    ),
                    bottom: BorderSide(
                      color: _getWeatherBackgroundColor(),
                    ),
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int col = index % 8;

                      bool isSelected = selectedRow == row && selectedCol == col;

                      bool isValidMove = false;
                      for (var position in validMoves) {
                        if (position[0] == row && position[1] == col) {
                          isValidMove = true;
                        }
                      }

                      return Square(
                        isWhite: isWhite(index),
                        piece: board[row][col],
                        isSelected: isSelected,
                        isValidMove: isValidMove,
                        onTap: () => pieceSelected(row, col),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: blackPiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: blackPiecesTaken[index].imagePath,
                    isWhite: false,
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _buildWeatherDisplay(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    switch (currentWeather) {
      case WeatherType.sunny:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Lottie.asset('assets/animations/sunny.json', fit: BoxFit.contain),
          ],
        );
      case WeatherType.rainy:
        return Lottie.asset('assets/animations/rainy.json', fit: BoxFit.cover);
      case WeatherType.windy:
        return Lottie.asset('assets/animations/windy.json', fit: BoxFit.contain);
      case WeatherType.snowy:
        return Lottie.asset('assets/animations/snowy.json', fit: BoxFit.cover);
      case WeatherType.foggy:
        return Lottie.asset('assets/animations/foggy.json', fit: BoxFit.contain);
      case WeatherType.stormy:
        return Lottie.asset('assets/animations/stormy.json', fit: BoxFit.contain);
      case WeatherType.forest:
        return Lottie.asset('assets/animations/forest.json', fit: BoxFit.contain);
      default:
        return SizedBox.shrink();
    }
  }

  Color _getWeatherBackgroundColor() {
    switch (currentWeather) {
      case WeatherType.sunny:
        return Colors.orange[100]!;
      case WeatherType.rainy:
        return Colors.blue[100]!;
      case WeatherType.windy:
        return Colors.grey[200]!;
      case WeatherType.snowy:
        return Colors.white;
      case WeatherType.foggy:
        return Colors.grey[300]!;
      case WeatherType.stormy:
        return Colors.grey[400]!;
      case WeatherType.forest:
        return Colors.green[300]!;
      default:
        return Colors.blue[200]!;
    }
  }
}