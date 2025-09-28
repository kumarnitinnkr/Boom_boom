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
  final Offset popPosition; // <--- NEW: Carries the screen coordinate
  BubblePopped(this.id, this.popPosition); // <--- Updated constructor
}
class CheckCollisions extends BubbleGameEvent {}
class ClearPoppedFact extends BubbleGameEvent { // <--- NEW Event to clear animated facts
  final UniqueKey bubbleId;
  ClearPoppedFact(this.bubbleId);
}

// States
class BubbleGameState {
  final int score;
  final List<Bubble> bubbles;
  final String? currentFact;
  final bool isGameOver;
  final Map<UniqueKey, String> activePoppedFacts; // <--- NEW: Stores the fact text
  final Map<UniqueKey, Offset> activeFactPositions; // <--- NEW: Stores the pop position

  BubbleGameState({
    required this.score,
    required this.bubbles,
    this.currentFact,
    this.isGameOver = false,
    Map<UniqueKey, String>? activePoppedFacts,
    Map<UniqueKey, Offset>? activeFactPositions,
  }) : activePoppedFacts = activePoppedFacts ?? {},
        activeFactPositions = activeFactPositions ?? {};

  BubbleGameState copyWith({
    int? score,
    List<Bubble>? bubbles,
    String? currentFact,
    bool? isGameOver,
    Map<UniqueKey, String>? activePoppedFacts,
    Map<UniqueKey, Offset>? activeFactPositions,
  }) {
    return BubbleGameState(
      score: score ?? this.score,
      bubbles: bubbles ?? this.bubbles,
      currentFact: currentFact ?? this.currentFact,
      isGameOver: isGameOver ?? this.isGameOver,
      activePoppedFacts: activePoppedFacts ?? this.activePoppedFacts,
      activeFactPositions: activeFactPositions ?? this.activeFactPositions,
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
    on<ClearPoppedFact>(_onClearPoppedFact); // <--- NEW HANDLER
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
    final newScore = state.score + 1; // Score is 1

    String? poppedFact = facts[_random.nextInt(facts.length)].fact; // Select fact

    // === FIX: Store fact text AND position ===
    final updatedActiveFacts = Map<UniqueKey, String>.from(state.activePoppedFacts);
    final updatedFactPositions = Map<UniqueKey, Offset>.from(state.activeFactPositions);

    if (poppedFact != null) {
      updatedActiveFacts[event.id] = poppedFact;
      updatedFactPositions[event.id] = event.popPosition; // Store the exact pop position
    }
    // ======================================

    emit(state.copyWith(
      score: newScore,
      bubbles: newBubbles,
      currentFact: poppedFact, // Keep currentFact update for compatibility
      activePoppedFacts: updatedActiveFacts,
      activeFactPositions: updatedFactPositions,
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

  // === NEW HANDLER: To clear the fact after the animation is done ===
  void _onClearPoppedFact(ClearPoppedFact event, Emitter<BubbleGameState> emit) {
    final updatedActiveFacts = Map<UniqueKey, String>.from(state.activePoppedFacts);
    final updatedFactPositions = Map<UniqueKey, Offset>.from(state.activeFactPositions);

    updatedActiveFacts.remove(event.bubbleId); // Remove the fact text
    updatedFactPositions.remove(event.bubbleId); // Remove the position data

    emit(state.copyWith(
      activePoppedFacts: updatedActiveFacts,
      activeFactPositions: updatedFactPositions,
    ));
  }
}