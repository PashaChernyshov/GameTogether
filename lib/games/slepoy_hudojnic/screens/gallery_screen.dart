import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/game_service.dart';
import '../widgets/animated_background.dart';
import 'drawing_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? selectedPlayer;

  @override
  Widget build(BuildContext context) {
    final filteredGallery = selectedPlayer == null
        ? gameService.gallery
        : gameService.gallery
            .where((entry) => entry.player.name == selectedPlayer)
            .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Галерея рисунков',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'PixelFont',
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.black87,
                    value: selectedPlayer,
                    isExpanded: true,
                    hint: const Text(
                      'Фильтр по игроку',
                      style: TextStyle(
                          color: Colors.white70, fontFamily: 'PixelFont'),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'PixelFont'),
                    items: [
                      ...gameService.players
                          .map((p) => DropdownMenuItem<String>(
                                value: p.name,
                                child: Text(p.name),
                              )),
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Показать всех'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedPlayer = value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredGallery.length,
                      itemBuilder: (context, index) {
                        final entry = filteredGallery[index];

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          columnCount: crossAxisCount,
                          duration: const Duration(milliseconds: 500),
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFB388FF),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: CustomPaint(
                                        painter: DrawingPainter(
                                            points: entry.points),
                                        child: Container(),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Художник: ${entry.player.name}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: entry.player.color,
                                              fontFamily: 'PixelFont',
                                            ),
                                          ),
                                          Text(
                                            _randomComment(index),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                              fontFamily: 'PixelFont',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _randomComment(int index) {
    const comments = [
      'Вот это шедевр!',
      'А что это вообще?',
      'Оно живое?!',
      'Глубокий смысл...',
      'Повесить бы в музей!',
    ];
    return comments[index % comments.length];
  }
}
