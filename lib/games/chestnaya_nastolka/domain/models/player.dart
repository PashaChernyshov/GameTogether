import 'dart:ui';

class Player {
  int index;
  Offset position;
  final Color color;
  final String name;

  Player({
    required this.index,
    required this.position,
    required this.color,
    required this.name,
  });
}
