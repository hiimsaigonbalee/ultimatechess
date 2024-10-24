import '../components/piece.dart';

enum TerrainType { grass, stone, ice }

class Terrain {
  final TerrainType type;
  Terrain(this.type);

  int getMovementModifier(ChessPiece piece) {
    switch (type) {
      case TerrainType.grass:
        return 0;
      case TerrainType.stone:
        return piece.type == ChessPieceType.rook ? 1 : 0;
      case TerrainType.ice:
        return piece.type == ChessPieceType.pawn ? -1 : 0;
      default:
        return 0;
    }
  }
}
