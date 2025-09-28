// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Flag to track background music state (optional, but good practice)
  bool _isMusicPlaying = false;

  Future<void> init() async {
    // CRUCIAL FIX: Set the _sfxPlayer to low latency mode globally.
    // This allows the player to be ready instantly when playPopSound() is called.
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);

    // Set release mode to keep resources light
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playBackgroundMusic() async {
    if (_isMusicPlaying) return; // Prevent double-playing

    await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Ensure music loops

    // Play the music from assets
    await _musicPlayer.play(AssetSource('audio/bg_music.mp3'));

    _isMusicPlaying = true;
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> playPopSound() async {
    // To ensure simultaneous playback, we rely on the player already being
    // in low latency mode from init().
    // We use seek to 0 and resume if it was already playing a quick sound,
    // or just play the sound instantly.

    // Note: On some platforms, using AudioCache or creating a new player
    // instance per pop is even faster, but using lowLatency mode on one player is standard.
    await _sfxPlayer.play(
      AssetSource('audio/pop_sound.mp3'),
      // Do not specify mode here; it should be configured in init()
    );
  }
}