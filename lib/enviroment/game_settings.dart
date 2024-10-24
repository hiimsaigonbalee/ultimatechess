import 'package:flutter/material.dart';
import 'weather.dart';
import 'terrain.dart';

class GameSettings extends StatefulWidget {
  const GameSettings({Key? key, required this.onSettingsChanged}) : super(key: key);

  final Function(Weather weather, Terrain terrain) onSettingsChanged;

  @override
  State<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
  WeatherType selectedWeather = WeatherType.sunny;
  TerrainType selectedTerrain = TerrainType.grass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Settings')),
      body: Column(
        children: [
          // Chọn thời tiết
          DropdownButton<WeatherType>(
            value: selectedWeather,
            items: WeatherType.values.map((WeatherType weather) {
              return DropdownMenuItem<WeatherType>(
                value: weather,
                child: Text(weather.name),
              );
            }).toList(),
            onChanged: (newWeather) {
              setState(() {
                selectedWeather = newWeather!;
              });
            },
          ),
          // Chọn sàn đấu
          DropdownButton<TerrainType>(
            value: selectedTerrain,
            items: TerrainType.values.map((TerrainType terrain) {
              return DropdownMenuItem<TerrainType>(
                value: terrain,
                child: Text(terrain.name),
              );
            }).toList(),
            onChanged: (newTerrain) {
              setState(() {
                selectedTerrain = newTerrain!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSettingsChanged(Weather(selectedWeather), Terrain(selectedTerrain));
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}
