// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/bloc/bubble_game_bloc.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubble Pop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => BubbleGameBloc(),
        child: const BubbleGameScreen(),
      ),
    );
  }
}

class BubbleGameScreen extends StatefulWidget {
  const BubbleGameScreen({super.key});

  @override
  State<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends State<BubbleGameScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      context.read<BubbleGameBloc>().add(BubbleSpawned());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Pop! 🫧'),
      ),
      body: BlocBuilder<BubbleGameBloc, BubbleGameState>(
        builder: (context, state) {
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
                    },
                    child: Container(
                      width: bubble.size,
                      height: bubble.size,
                      decoration: BoxDecoration(
                        color: bubble.color.withOpacity(0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: bubble.color.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Scoreboard
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'Score: ${state.score}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

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