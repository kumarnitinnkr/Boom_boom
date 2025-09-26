// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/bloc/bubble_game_bloc.dart';
import 'package:boom_boom/services/audio_service.dart';
import 'dart:async';
import 'home_screen.dart';

// --- GLOBAL SERVICES AND HELPERS ---
final AudioService audioService = AudioService();

// Global function to return to the home screen
void _goHome(BuildContext context) {
  audioService.stopBackgroundMusic();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}
// ------------------------------------


// --- CORE APPLICATION LAUNCHER (Single main function) ---
void main() {
  audioService.init();
  runApp(const MainAppWrapper());
}

class MainAppWrapper extends StatelessWidget {
  const MainAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubble Pop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- BUBBLE GAME SCREEN (This is the actual game UI) ---

class BubbleGameScreen extends StatefulWidget {
  const BubbleGameScreen({super.key});

  @override
  State<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends State<BubbleGameScreen> {
  // Renaming to be consistent with the comprehensive approach
  late Timer _spawnTimer;
  late Timer _collisionTimer;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BubbleGameBloc>();
    audioService.playBackgroundMusic();

    // 1. Spawning Timer
    _spawnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!bloc.state.isGameOver) {
        context.read<BubbleGameBloc>().add(BubbleSpawned());
      } else {
        _spawnTimer.cancel();
      }
    });

    // 2. Collision Timer
    _collisionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!bloc.state.isGameOver) {
        context.read<BubbleGameBloc>().add(CheckCollisions());
      } else {
        _collisionTimer.cancel();
        audioService.stopBackgroundMusic();
      }
    });
  }

  @override
  void dispose() {
    _spawnTimer.cancel();
    _collisionTimer.cancel();
    super.dispose();
  }

  // === NEW: Helper method to restart the game state ===
  void _startNewGame(BuildContext context) {
    // This stops any lingering music and launches a fresh state.
    audioService.stopBackgroundMusic();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // Crucial: Use BlocProvider(create: ...) to get a completely new game instance
        builder: (context) => BlocProvider(
          create: (context) => BubbleGameBloc(),
          child: const BubbleGameScreen(),
        ),
      ),
    );
  }
  // ==================================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // === AppBar Implementation ===
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 4,
        automaticallyImplyLeading: false,

        // 1. LEFT SIDE: Score Display
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Center(
            child: BlocBuilder<BubbleGameBloc, BubbleGameState>(
                buildWhen: (previous, current) => previous.score != current.score,
                builder: (context, state) {
                  // Hide score display if the game is over
                  if (state.isGameOver) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: Text(
                      'Score: ${state.score}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  );
                }
            ),
          ),
        ),

        // 2. MIDDLE: Title
        title: const Text(
          'Bubble Boom! 🫧',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        // 3. RIGHT SIDE: Exit Button
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
            iconSize: 30,
            onPressed: () => _goHome(context), // Calling the global function
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BlocBuilder<BubbleGameBloc, BubbleGameState>(
        builder: (context, state) {

          // === GAME OVER UI: UPDATED BUTTONS ===
          if (state.isGameOver) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red, width: 6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '💥GAME OVER!💥',
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Final Score: ${state.score}',
                      style: const TextStyle(fontSize: 28, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),
                    // 1. PLAY AGAIN Button (New functionality)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh), // Changed icon to refresh
                      label: const Text('PLAY AGAIN'), // Changed text
                      onPressed: () => _startNewGame(context), // Calls the new helper function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 2. Back to Home TextButton
                    TextButton(
                      onPressed: () => _goHome(context),
                      child: const Text('Back to Home', style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          }
          // ==========================

          // === NORMAL GAME PLAY UI remains the same ===
          return Stack(
            children: [
              // Bubbles
              ...state.bubbles.map((bubble) {
                return Positioned(
                  left: bubble.position.dx,
                  top: bubble.position.dy,
                  child: GestureDetector(
                    onTap: () {
                      context.read<BubbleGameBloc>().add(BubblePopped(bubble.id));
                      audioService.playPopSound();
                    },
                    child: Container(
                      width: bubble.size,
                      height: bubble.size,
                      decoration: BoxDecoration(
                        color: bubble.color.withAlpha((255 * 0.7).round()),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: bubble.color.withAlpha((255 * 0.5).round()),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Environmental Fact Display
              if (state.currentFact != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          state.currentFact!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}