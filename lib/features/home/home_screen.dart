import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_app/features/connection/connection_screen.dart';
import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openConnection(BuildContext context, String gameId) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => ConnectionScreen(gameId: gameId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _SideDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Игры',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / 200).floor().clamp(1, 4),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                GameCard(
                  title: 'Слепой художник',
                  imagePath: 'assets/images/slep.png',
                  onTap: () => _openConnection(context, "blind_artist"),
                  backgroundColor: Colors.white,
                ),
                GameCard(
                  title: 'Честная настолка',
                  imagePath: 'assets/images/nastolka.png',
                  onTap: () => _openConnection(context, "honest_game"),
                  backgroundColor: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(top: 60),
          children: const [
            ListTile(
              leading: Icon(Icons.settings, color: Colors.black),
              title: Text('Настройки', style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.black),
              title: Text('Категории', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
