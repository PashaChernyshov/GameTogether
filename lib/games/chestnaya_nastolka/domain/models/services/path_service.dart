import 'dart:math';
import 'package:flutter/material.dart';

class PathService {
  final int gridWidth;
  final int gridHeight;
  final int minLength;

  PathService({
    required this.gridWidth,
    required this.gridHeight,
    required this.minLength,
  });

  List<Offset> generateSnakePath() {
    final directions = <Offset>[
      const Offset(-1, 0),
      const Offset(1, 0),
      const Offset(0, -1),
      const Offset(0, 1),
    ];

    final rand = Random();
    List<Offset> bestPath = [];
    int attempts = 0;

    while (bestPath.length < minLength && attempts < 1000) {
      attempts++;
      final path = <Offset>[
        Offset(rand.nextInt(gridWidth).toDouble(),
            rand.nextInt(gridHeight).toDouble())
      ];
      final visited = <Offset>{path.first};

      while (path.length < minLength) {
        final current = path.last;
        final shuffled = [...directions]..shuffle(rand);
        bool moved = false;

        for (final dir in shuffled) {
          final next = current + dir;

          if (next.dx >= 0 &&
              next.dx < gridWidth &&
              next.dy >= 0 &&
              next.dy < gridHeight &&
              !visited.contains(next)) {
            final isSafe = path.every((pos) {
              if (pos == path.last) return true;
              final dx = (pos.dx - next.dx).abs();
              final dy = (pos.dy - next.dy).abs();
              return dx + dy != 1;
            });

            if (isSafe) {
              path.add(next);
              visited.add(next);
              moved = true;
              break;
            }
          }
        }

        if (!moved) break;
      }

      if (path.length > bestPath.length) {
        bestPath = path;
      }
    }

    return bestPath;
  }
}
