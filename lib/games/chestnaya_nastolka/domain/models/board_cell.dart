import 'package:flutter/material.dart';

class BoardCell {
  final int index;
  final Offset position;
  final int? arrowTo;
  final bool isQuestion;

  BoardCell({
    required this.index,
    required this.position,
    this.arrowTo,
    this.isQuestion = false,
  });
}
