import 'package:flutter/material.dart';
import '../game_board.dart';
import 'weather.dart';
import 'terrain.dart';
import 'game_settings.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Weather currentWeather = Weather(WeatherType.sunny);
  Terrain currentTerrain = Terrain(TerrainType.grass);

  void startGame(Weather weather, Terrain terrain) {
    setState(() {
      currentWeather = weather;
      currentTerrain = terrain;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameBoard(onMove: (piece, startRow, startCol, endRow, endCol) {}, currentWeather: currentWeather, currentTerrain: currentTerrain)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Game')),
      body: GameSettings(onSettingsChanged: startGame),
    );
  }
}
