import 'dart:ui';
import '../models/player.dart';
import '../data/word_list.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/gallery_entry.dart';

final List<GalleryEntry> gallery = [];

class GameService {
  final List<Player> players = [];
  int currentPlayerIndex = 0;
  String currentWord = '';
  final List<GalleryEntry> gallery = [];

  final List<Color> availableColors = [
    const Color.fromARGB(255, 115, 255, 0),
    const Color.fromARGB(255, 255, 0, 72),
    const Color.fromARGB(255, 0, 234, 255),
    const Color.fromARGB(255, 255, 230, 0),
    const Color.fromARGB(255, 217, 0, 255),
    const Color.fromARGB(255, 85, 0, 255),
    const Color.fromARGB(255, 0, 167, 75),
    const Color.fromARGB(255, 0, 170, 255),
    const Color.fromARGB(255, 255, 157, 0),
    const Color.fromARGB(255, 255, 81, 0),
  ];
  int _colorIndex = 0;

  void addPlayer(String name) {
    final color = availableColors[_colorIndex % availableColors.length];
    _colorIndex++;
    players.add(Player(name, color));
  }

  Player get currentPlayer => players[currentPlayerIndex];

  void nextTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void generateWord() {
    final rand = Random();
    currentWord = wordList[rand.nextInt(wordList.length)];
  }

  void addPointTo(Player player, {int delta = 1}) {
    player.score += delta;
  }

  bool get isGameOver => players.any((p) => p.score >= 10);

  Player get winner =>
      players.firstWhere((p) => p.score >= 10, orElse: () => players.first);
}

final gameService = GameService();
