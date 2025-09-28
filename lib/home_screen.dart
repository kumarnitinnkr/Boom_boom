// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/bloc/bubble_game_bloc.dart';
import 'package:boom_boom/main.dart';
import 'package:boom_boom/services/audio_service.dart'; // Import service
// Note: Unused import 'package:flutter/services.dart' should be removed if still present

// Global AudioService instance
final AudioService audioService = AudioService();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper method to navigate and start a new game
  void _startGame(BuildContext context) {
    audioService.stopBackgroundMusic(); // Stop home music
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => BubbleGameBloc(), // Creates a brand new Bloc instance
          child: const BubbleGameScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    audioService.init();
    audioService.playBackgroundMusic();

    return Scaffold(
      // Removed backgroundColor: Colors.tealAccent as the body covers it.
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/home_screen_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === UPDATED: 3D Text Title Implementation using Stack ===
              Stack(
                alignment: Alignment.center,
                children: [
                  // Bottom/Shadow Layer (Darker, slightly offset for depth)
                  Text(
                    'BUBBLE BOOM',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[900], // Dark color for shadow/depth
                    ),
                  ),
                  // Top/Main Layer (Lighter, positioned slightly up and left)
                  Positioned(
                    top: 2.0, // Vertical offset
                    left: 2.0, // Horizontal offset
                    child: Text(
                      'BUBBLE BOOM!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.lightBlue[300], // Lighter color for main surface
                        shadows: [
                          Shadow( // Soft white glow for a "bubbly" feel
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ===========================================
              const SizedBox(height: 80),

              // 1. PLAY BUTTON
              _CustomButton(
                text: 'Play Game',
                onPressed: () => _startGame(context),
                buttonColor: Colors.lightGreen,
              ),
              const SizedBox(height: 20),

              // 2. LEADERBOARD
              _CustomButton(
                text: 'Leaderboard',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing High Scores...')),
                  );
                },
                buttonColor: Colors.amber,
              ),
              const SizedBox(height: 20),

              // 3. RESTART GAME (Former Exit button)
              _CustomButton(
                text: 'Restart Game', // Changed to Restart functionality
                onPressed: () => _startGame(context), // Starts a new game state
                buttonColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// The _CustomButton class definition remains here
// ====================================================================
class _CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor; // New property for custom color

  const _CustomButton({
    required this.text,
    required this.onPressed,
    required this.buttonColor, // Must be passed in
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        minimumSize: const Size(280, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}