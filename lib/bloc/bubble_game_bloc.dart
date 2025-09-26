// lib/bloc/bubble_game_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/data/facts.dart'; // Ensure this path is correct
import 'package:boom_boom/models/bubble.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Events
abstract class BubbleGameEvent {}
class BubbleSpawned extends BubbleGameEvent {}
class BubblePopped extends BubbleGameEvent {
  final UniqueKey id;
  BubblePopped(this.id);
}
class CheckCollisions extends BubbleGameEvent {}

// States
class BubbleGameState {
  final int score;
  final List<Bubble> bubbles;
  final String? currentFact;
  final bool isGameOver;

  BubbleGameState({
    required this.score,
    required this.bubbles,
    this.currentFact,
    this.isGameOver = false,
  });

  BubbleGameState copyWith({
    int? score,
    List<Bubble>? bubbles,
    String? currentFact,
    bool? isGameOver,
  }) {
    return BubbleGameState(
      score: score ?? this.score,
      bubbles: bubbles ?? this.bubbles,
      currentFact: currentFact ?? this.currentFact,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class BubbleGameBloc extends Bloc<BubbleGameEvent, BubbleGameState> {
  final Random _random = Random();
  final List<Color> bubbleColors = [Colors.blue, Colors.green, Colors.red, Colors.purple];

  BubbleGameBloc() : super(BubbleGameState(score: 0, bubbles: [], isGameOver: false)) {
    on<BubbleSpawned>(_onBubbleSpawned);
    on<BubblePopped>(_onBubblePopped);
    on<CheckCollisions>(_onCheckCollisions);
  }

  void _onBubbleSpawned(BubbleSpawned event, Emitter<BubbleGameState> emit) {
    if (state.isGameOver) return;

    final newBubble = Bubble(
      id: UniqueKey(),
      position: Offset(
        _random.nextDouble() * 300,
        _random.nextDouble() * 500,
      ),
      size: _random.nextDouble() * 30 + 20,
      color: bubbleColors[_random.nextInt(bubbleColors.length)],
    );
    emit(state.copyWith(bubbles: List.from(state.bubbles)..add(newBubble)));
  }

  void _onBubblePopped(BubblePopped event, Emitter<BubbleGameState> emit) {
    if (state.isGameOver) return;

    final newBubbles = state.bubbles.where((bubble) => bubble.id != event.id).toList();
    final newScore = state.score + 10;

    // === FIX: Safely access 'facts' list ===
    String? newFact;
    if (facts.isNotEmpty) {
      newFact = facts[_random.nextInt(facts.length)].fact;
    } else {
      newFact = "Did you know: The environment is important! Add some facts to your list!";
    }
    // ======================================

    emit(state.copyWith(
      score: newScore,
      bubbles: newBubbles,
      currentFact: newFact,
    ));
  }

  void _onCheckCollisions(CheckCollisions event, Emitter<BubbleGameState> emit) {
    if (state.isGameOver) return;

    final bubbles = state.bubbles;
    if (bubbles.length < 2) {
      return;
    }

    for (int i = 0; i < bubbles.length; i++) {
      for (int j = i + 1; j < bubbles.length; j++) {
        if (bubbles[i].overlaps(bubbles[j])) {
          emit(state.copyWith(isGameOver: true));
          return;
        }
      }
    }
  }
}