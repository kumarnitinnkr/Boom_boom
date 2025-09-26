// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> init() async {
    // Set up SFX player for quick sounds
    _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playBackgroundMusic() async {
    await _musicPlayer.play(AssetSource('audio/bg_music.mp3'));
    _musicPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> playPopSound() async {
    // Ensure the SFX player is available and quickly plays the sound
    await _sfxPlayer.play(AssetSource('audio/pop_sound.mp3'), mode: PlayerMode.lowLatency);
  }
}// TODO Implement this library.