// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/bloc/bubble_game_bloc.dart';
import 'package:boom_boom/main.dart';
import 'package:boom_boom/services/audio_service.dart'; // Import service
// Unused import 'package:flutter/services.dart' is removed,
// as SystemNavigator.pop() is no longer needed on the home screen.

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
      backgroundColor: Colors.tealAccent,
      // Warning fix: Unnecessary instance of 'Container' removed
      // by placing the decoration directly on the Scaffold body.
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BUBBLE BOOM ',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                    shadows: [
                      Shadow(offset: Offset(2, 2), blurRadius: 4.0, color: Colors.black54),
                    ]
                ),
              ),
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
// FIX: The _CustomButton class definition MUST be placed here
//      in the same file where it is used.
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