// lib/data/facts.dart
class EnvironmentalFact {
  final String fact;
  EnvironmentalFact(this.fact);
}

// Make sure this list is correctly spelled and not defined inside a class
final List<EnvironmentalFact> facts = [
  EnvironmentalFact('Recycling one plastic bottle saves enough energy to power a 60W lightbulb for 6 hours.'),
  // ... more facts ...
];