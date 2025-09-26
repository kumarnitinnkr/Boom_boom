// lib/bloc/bubble_game_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/data/facts.dart';
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

// States
class BubbleGameState {
  final int score;
  final List<Bubble> bubbles;
  final String? currentFact;

  BubbleGameState({
    required this.score,
    required this.bubbles,
    this.currentFact,
  });

  BubbleGameState copyWith({
    int? score,
    List<Bubble>? bubbles,
    String? currentFact,
  }) {
    return BubbleGameState(
      score: score ?? this.score,
      bubbles: bubbles ?? this.bubbles,
      currentFact: currentFact ?? this.currentFact,
    );
  }
}

class BubbleGameBloc extends Bloc<BubbleGameEvent, BubbleGameState> {
  final Random _random = Random();
  final List<Color> bubbleColors = [Colors.blue, Colors.green, Colors.red, Colors.purple];

  BubbleGameBloc() : super(BubbleGameState(score: 0, bubbles: [])) {
    on<BubbleSpawned>(_onBubbleSpawned);
    on<BubblePopped>(_onBubblePopped);
  }

  void _onBubbleSpawned(BubbleSpawned event, Emitter<BubbleGameState> emit) {
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
    final poppedBubble = state.bubbles.firstWhere((bubble) => bubble.id == event.id);
    final newBubbles = state.bubbles.where((bubble) => bubble.id != event.id).toList();
    final newScore = state.score + 10;
    final newFact = facts[_random.nextInt(facts.length)].fact;

    emit(state.copyWith(
      score: newScore,
      bubbles: newBubbles,
      currentFact: newFact,
    ));
  }
}