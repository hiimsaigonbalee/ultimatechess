import 'dart:math';
import '../components/piece.dart';

class ChessAI {
  final bool isWhite;
  final Function calculateValidMoves;

  ChessAI({required this.isWhite, required this.calculateValidMoves});

  List<int> makeRandomMove(List<List<ChessPiece?>> board) {
    List<List<int>> allValidMoves = [];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhite) {
          var piece = board[i][j];
          var validMoves = calculateValidMoves(i, j, piece, false);
          for (var move in validMoves) {
            allValidMoves.add([i, j, move[0], move[1]]);
          }
        }
      }
    }

    if (allValidMoves.isNotEmpty) {
      final random = Random();
      return allValidMoves[random.nextInt(allValidMoves.length)];
    }

    return [];
  }
}