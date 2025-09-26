// lib/models/bubble.dart
import 'package:flutter/material.dart';

class Bubble {
  final UniqueKey id;
  Offset position;
  double size;
  final Color color;

  Bubble({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
  });

  // === FIX: Added the missing 'overlaps' method for collision detection ===
  bool overlaps(Bubble other) {
    // Calculate distance squared between the center points of the two bubbles
    final dx = position.dx - other.position.dx;
    final dy = position.dy - other.position.dy;
    final distanceSquared = (dx * dx + dy * dy);

    // Calculate the sum of the radii squared
    final radius1 = size / 2;
    final radius2 = other.size / 2;
    final minDistanceSquared = (radius1 + radius2) * (radius1 + radius2);

    // If the distance squared is less than the sum of the radii squared, they overlap.
    return distanceSquared < minDistanceSquared;
  }
}