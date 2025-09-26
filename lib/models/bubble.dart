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
}

// lib/data/facts.dart
class EnvironmentalFact {
  final String fact;

  EnvironmentalFact(this.fact);
}

final List<EnvironmentalFact> facts = [
  EnvironmentalFact('Recycling one plastic bottle saves enough energy to power a 60W lightbulb for 6 hours.'),
  EnvironmentalFact('A single tree can absorb up to 48 pounds of carbon dioxide per year.'),
  EnvironmentalFact('Globally, we lose a forest area the size of Panama every year.'),
  EnvironmentalFact('Water pollution is a major threat, with 80% of wastewater flowing back into the ecosystem without being treated or reused.'),
];