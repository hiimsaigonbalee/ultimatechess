// music_service.dart
import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('assets/sound/background.mp3'));
  }

  static void stop() {
    _audioPlayer.stop();
  }
}