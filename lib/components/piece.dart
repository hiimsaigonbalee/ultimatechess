enum ChessPieceType {pawn, rook, knight, bishop, queen, king}

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  // Các thuộc tính bổ sung
  // int moveSpeed;
  // int defense;
  // int attackPower;
  // int stamina;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
    // this.moveSpeed = 1,
    // this.defense = 0,
    // this.attackPower = 1,
    // this.stamina = 10,
  });
}
