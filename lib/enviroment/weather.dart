import '../components/piece.dart';

enum WeatherType { sunny, rainy, windy }

class Weather {
  final WeatherType type;
  Weather(this.type);

  int getMovementModifier(ChessPiece piece) {
    switch (type) {
      case WeatherType.sunny:
        return 0;
      case WeatherType.rainy:
        return piece.type == ChessPieceType.knight ? -1 : 0;
      case WeatherType.windy:
        return piece.type == ChessPieceType.bishop ? 1 : 0;
      default:
        return 0;
    }
  }
}
