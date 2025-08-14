import 'package:flutter/material.dart';
import 'rules_screen.dart';

class PravilaScreen extends StatelessWidget {
  const PravilaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'ПРАВИЛА ИГРЫ',
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 20),
            const Text(
              'Каждый раунд один из игроков рисует вслепую заданное слово. Остальные игроки пытаются угадать, что он нарисовал. За правильный ответ даётся 1 балл. Игра продолжается, пока кто-то не наберёт 10 баллов. Побеждает тот, кто первым наберёт 10.',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RulesScreen()),
                  );
                },
                child: const Text(
                  'Назад',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
