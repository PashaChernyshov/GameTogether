import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../widgets/maze_board.dart';

class MazeBoardScreen extends StatefulWidget {
  const MazeBoardScreen({super.key});

  @override
  State<MazeBoardScreen> createState() => _MazeBoardScreenState();
}

class _MazeBoardScreenState extends State<MazeBoardScreen>
    with TickerProviderStateMixin {
  static const int gridWidth = 20;
  static const int gridHeight = 10;
  static const double margin = 2;
  static const int minLength = 100;

  double cellSize = 60;
  double zoom = 1.0;
  double rotateX = -pi / 20;
  double rotateY = -pi / 20;
  Offset cameraOffset = Offset.zero;
  Size boardAreaSize = Size.zero;

  late List<Offset> path;
  List<Player> players = [];

  bool initialized = false;

  late AnimationController wobbleController;
  late Animation<double> wobbleAnimX;
  late Animation<double> wobbleAnimY;

  late AnimationController zoomController;
  late Animation<double> zoomAnim;
  late Animation<Offset> cameraAnim;
  late Animation<double> rotateXAnim;
  late Animation<double> rotateYAnim;

  final double defaultRotateX = -pi / 20;
  final double defaultRotateY = -pi / 20;
  final double zoomedRotateX = 0;
  final double zoomedRotateY = 0;

  List<Offset> animatedPositions = [];

  @override
  void initState() {
    super.initState();
    path = _generateSnakePath();
    players = [
      Player(
          index: 0,
          position: path[0],
          color: Colors.deepPurple,
          name: 'Игрок 1'),
      Player(index: 0, position: path[0], color: Colors.teal, name: 'Игрок 2'),
    ];
    animatedPositions = [path[0], path[0]];

    wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    wobbleAnimX = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: wobbleController, curve: Curves.easeInOut),
    );
    wobbleAnimY = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: wobbleController, curve: Curves.easeInOut),
    );

    zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  List<Offset> _generateSnakePath() {
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

  void _initializeCamera(Size areaSize) {
    boardAreaSize = areaSize;
    final fullWidth = areaSize.width;
    final fullHeight = areaSize.height;
    final maxCellWidth = fullWidth / gridWidth;
    final maxCellHeight = fullHeight / gridHeight;
    cellSize = min(maxCellWidth, maxCellHeight) - margin * 2;

    final bounds = _getPathBounds();
    final fieldCenter = Offset(
        (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2);
    const matrixAlignmentOffset = Offset(0, -0.5);
    final adjusted =
        fieldCenter + Offset(0, fieldCenter.dy * matrixAlignmentOffset.dy);
    cameraOffset = Offset(areaSize.width / 2, areaSize.height / 2) - adjusted;
  }

  Rect _getPathBounds() {
    final xs = path.map((e) => e.dx).toList();
    final ys = path.map((e) => e.dy).toList();
    final full = cellSize + margin * 2;
    return Rect.fromLTRB(xs.reduce(min) * full, ys.reduce(min) * full,
        (xs.reduce(max) + 1) * full, (ys.reduce(max) + 1) * full);
  }

  void _resetGame() {
    setState(() {
      path = _generateSnakePath();
      players = players
          .map((p) =>
              Player(index: 0, position: path[0], color: p.color, name: p.name))
          .toList();
      animatedPositions = [path[0], path[0]];
      zoom = 1.0;
      rotateX = defaultRotateX;
      rotateY = defaultRotateY;
      cameraOffset = Offset.zero;
      initialized = false;
    });
  }

  Future<void> _rollDice(int playerIndex) async {
    final player = players[playerIndex];
    final steps = Random().nextInt(6) + 1;
    final newIndex = (player.index + steps).clamp(0, path.length - 1);

    await _zoomTo(player.position);

    for (int i = player.index + 1; i <= newIndex; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      setState(() {
        players[playerIndex] = Player(
          index: i,
          position: path[i],
          color: player.color,
          name: player.name,
        );
        animatedPositions[playerIndex] = path[i];
      });
    }

    await _zoomTo(path[newIndex]);
  }

  Future<void> _zoomTo(Offset pos) async {
    final fullCell = cellSize + margin * 2;
    final Offset screenCenter =
        Offset(boardAreaSize.width / 2, boardAreaSize.height / 2);
    final playerCenter = Offset(
        pos.dx * fullCell + fullCell / 2, pos.dy * fullCell + fullCell / 2);
    const matrixAlignmentOffset = Offset(0, -0.5);
    final actualCenter =
        playerCenter + Offset(0, playerCenter.dy * matrixAlignmentOffset.dy);
    final targetCameraOffset = screenCenter - actualCenter * 2.0;

    zoomAnim = Tween<double>(begin: zoom, end: 2.0).animate(
        CurvedAnimation(parent: zoomController, curve: Curves.easeOutCubic));
    cameraAnim = Tween<Offset>(begin: cameraOffset, end: targetCameraOffset)
        .animate(CurvedAnimation(
            parent: zoomController, curve: Curves.easeOutCubic));
    rotateXAnim = Tween<double>(
            begin: rotateX, end: 2.0 > 1.1 ? zoomedRotateX : defaultRotateX)
        .animate(CurvedAnimation(
            parent: zoomController, curve: Curves.easeOutCubic));
    rotateYAnim = Tween<double>(
            begin: rotateY, end: 2.0 > 1.1 ? zoomedRotateY : defaultRotateY)
        .animate(CurvedAnimation(
            parent: zoomController, curve: Curves.easeOutCubic));

    zoomController.reset();
    zoomController.addListener(() {
      setState(() {
        zoom = zoomAnim.value;
        cameraOffset = cameraAnim.value;
        rotateX = rotateXAnim.value;
        rotateY = rotateYAnim.value;
      });
    });

    await zoomController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
      if (!initialized) {
        _initializeCamera(areaSize);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => initialized = true);
        });
      }

      return MazeBoard(
        boardAreaSize: areaSize,
        path: path,
        players: players,
        playerPositions: animatedPositions,
        zoom: zoom,
        rotateX: rotateX,
        rotateY: rotateY,
        wobbleAnimX: wobbleAnimX,
        wobbleAnimY: wobbleAnimY,
        cameraOffset: cameraOffset,
        cellSize: cellSize,
        margin: margin,
        initialized: initialized,
        onInitialized: (_) {},
        onReset: _resetGame,
        onRollP1: () => _rollDice(0),
        onRollP2: () => _rollDice(1),
      );
    });
  }
}
