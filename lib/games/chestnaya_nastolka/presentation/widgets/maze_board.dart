import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/models/player.dart';

class MazeBoard extends StatelessWidget {
  final Size boardAreaSize;
  final List<Offset> path;
  final List<Player> players;
  final List<Offset> playerPositions;
  final double zoom;
  final double rotateX;
  final double rotateY;
  final Animation<double> wobbleAnimX;
  final Animation<double> wobbleAnimY;
  final Offset cameraOffset;
  final double cellSize;
  final double margin;
  final bool initialized;
  final Function(Size) onInitialized;
  final VoidCallback onReset;
  final VoidCallback onRollP1;
  final VoidCallback onRollP2;

  const MazeBoard({
    super.key,
    required this.boardAreaSize,
    required this.path,
    required this.players,
    required this.playerPositions,
    required this.zoom,
    required this.rotateX,
    required this.rotateY,
    required this.wobbleAnimX,
    required this.wobbleAnimY,
    required this.cameraOffset,
    required this.cellSize,
    required this.margin,
    required this.initialized,
    required this.onInitialized,
    required this.onReset,
    required this.onRollP1,
    required this.onRollP2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth * 0.8;
        final screenHeight = constraints.maxHeight * 0.8;
        final fullWidth = screenWidth;
        final fullHeight = screenHeight;
        final maxCellWidth = fullWidth / 20;
        final maxCellHeight = fullHeight / 10;

        final effectiveCellSize = min(maxCellWidth, maxCellHeight) - margin * 2;
        final size = Size(fullWidth, fullHeight);

        if (!initialized) {
          onInitialized(size);
        }

        final fullCell = effectiveCellSize + margin * 2;
        final bottomOffset = MediaQuery.of(context).size.height * 0.20;

        return AnimatedBuilder(
          animation: wobbleAnimX,
          builder: (context, child) {
            final wobbleX = wobbleAnimX.value;
            final wobbleY = wobbleAnimY.value;

            return Scaffold(
              backgroundColor: Colors.purple.shade50,
              body: Stack(
                children: [
                  Positioned(
                    top: screenHeight * 0.0,
                    left: screenWidth * 0.1875,
                    right: screenWidth * 0.0125,
                    bottom: screenHeight * 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Center(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateX(rotateX + wobbleY)
                            ..rotateY(rotateY + wobbleX)
                            ..translate(
                              cameraOffset.dx,
                              cameraOffset.dy - bottomOffset,
                            )
                            ..scale(zoom),
                          child: Stack(
                            children: [
                              for (int i = 0; i < path.length; i++)
                                Positioned(
                                  left: path[i].dx * fullCell,
                                  top: path[i].dy * fullCell,
                                  child: Container(
                                    width: effectiveCellSize,
                                    height: effectiveCellSize,
                                    margin: EdgeInsets.all(margin),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: effectiveCellSize * 0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              for (int i = 0; i < players.length; i++)
                                _buildAnimatedPlayerToken(
                                  playerPositions[i],
                                  players[i].color,
                                  i,
                                  effectiveCellSize,
                                  fullCell,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: onRollP1,
                              icon: const Icon(Icons.casino),
                              label: const Text('Игрок 1'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: onRollP2,
                              icon: const Icon(Icons.casino),
                              label: const Text('Игрок 2'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: onReset,
                          child: const Text('Новая игра'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedPlayerToken(
    Offset position,
    Color color,
    int index,
    double size,
    double fullCell,
  ) {
    final dxShift = (index % 2 == 0 ? -1 : 1) * 6.0;
    final dyShift = (index ~/ 2) * 6.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: position.dx * fullCell + dxShift + fullCell / 10,
      top: position.dy * fullCell + dyShift + fullCell / 10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child:
            Icon(Icons.directions_walk, color: Colors.white, size: size * 0.35),
      ),
    );
  }
}
