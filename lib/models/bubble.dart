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

  // === FIX: Add the missing 'overlaps' method for collision detection ===
  bool overlaps(Bubble other) {
    // Calculate distance between bubble centers
    final dx = position.dx - other.position.dx;
    final dy = position.dy - other.position.dy;
    // Use distance squared for performance (avoids expensive square root)
    final distanceSquared = (dx * dx + dy * dy);

    // Calculate sum of radii
    final radius1 = size / 2;
    final radius2 = other.size / 2;
    final minDistanceSquared = (radius1 + radius2) * (radius1 + radius2);

    // If distance is less than the sum of radii, they overlap.
    return distanceSquared < minDistanceSquared;
  }
}