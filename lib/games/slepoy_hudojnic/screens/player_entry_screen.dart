import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'who_draws_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/shiny_button.dart';

class PlayerEntryScreen extends StatefulWidget {
  const PlayerEntryScreen({super.key});

  @override
  State<PlayerEntryScreen> createState() => _PlayerEntryScreenState();
}

class _PlayerEntryScreenState extends State<PlayerEntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _flashController;

  final List<String> tips = [
    'Нажмите кнопку, если лень придумывать имя',
    'Имя может быть любым — главное фантазия',
    'Можно играть даже одному — но скучно!',
    'Имя художника запомнят навсегда!',
    'Придумай имя, которое всех рассмешит',
    'Больше игроков — больше веселья',
    'Если имя не идёт в голову — нажмите кнопку',
    'Главное — не победа, а смешное имя',
  ];

  String currentTip = 'Добавьте хотя бы 2 игрока, чтобы начать';
  bool tipWasInitial = true;

  final List<String> allRandomNames = [
    'Котик',
    'Шлёпа',
    'Мяу',
    'Хомяк',
    'Тётя Люда',
    'Кефирыч',
    'ТурбоСуслик',
    'Зуб даю',
    'Мистер Носок',
    'Кирилл НЕ рисует',
    'Не Я Рисовал',
    'Великий Рисовальщик',
    'Батя в здании',
    'Блинчик на Печи',
    'Мама сказала можно',
    'Анонимусик',
    'Бесконтурный',
    'Хз кто это',
    'Палка-Палка-Огуречик',
    'Креветка',
    'Дед Кабачок',
    'Пузырь',
    'Большая Сарделя',
    'Тюлень',
    'Пельмень Паникер',
    'Игорь ака Бой с Тенью',
    'Шумный Смыв',
    'Сомнительный Юрий',
    'Загадка Дыры',
    'Wi-Fi Краб',
    'Омлет',
    'Носорог по Акции',
    'Мухомор не ел Петрович',
    'Гриб',
    'Вери Биг Бос',
    'Хрюндель',
    'КриптаЁжик',
    'Слоняра',
    'Баба Галя',
    'Феечка',
    'Лягушонок Юстас',
    'Печенька с Молоком',
    'Хомяк Борщит',
    'Шелудивый Паладин',
    'Усатый Интроверт',
    'Непризнанный Гусь',
    'Вениамин Прекрасный',
  ];

  List<String> availableNames = [];

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0; // изначально вспышка невидима

    availableNames = List.from(allRandomNames)..shuffle();
  }

  void _changeTip() {
    final pool = tips
        .where((tip) =>
            tip != currentTip &&
            (tipWasInitial
                ? tip != 'Добавьте хотя бы 2 игрока, чтобы начать'
                : true))
        .toList()
      ..shuffle();

    if (pool.isNotEmpty) {
      setState(() {
        currentTip = pool.first;
        tipWasInitial = false;
      });
    }
  }

  void _addPlayer({String? overrideName}) {
    final name = (overrideName ?? _controller.text).trim();
    if (name.isNotEmpty) {
      gameService.addPlayer(name);
      _listKey.currentState?.insertItem(gameService.players.length - 1);
      _controller.clear();
      _focusNode.requestFocus();
      _changeTip();

      if (gameService.players.length >= 2) {
        _flashController.forward(from: 0);
      }

      setState(() {});
    }
  }

  void _generateName() {
    if (availableNames.isEmpty) {
      availableNames = List.from(allRandomNames)..shuffle();
    }
    final name = availableNames.removeLast();
    _addPlayer(overrideName: name);
  }

  void _removePlayer(int index) {
    final removed = gameService.players.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(
            removed.name,
            style: TextStyle(color: removed.color),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(),
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              if (_flashController.value == 1.0) return const SizedBox.shrink();
              return IgnorePointer(
                child: Opacity(
                  opacity: (1 - _flashController.value).clamp(0.0, 0.5),
                  child: Container(color: Colors.white),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Введите имена игроков:',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'PixelFont',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentTip,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'PixelFont',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Введите имя',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.casino, color: Colors.white),
                      onPressed: _generateName,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addPlayer,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: gameService.players.length,
                    itemBuilder: (context, index, animation) {
                      final player = gameService.players[index];
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Card(
                          color: player.color.withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              player.name,
                              style: TextStyle(
                                color: player.color,
                                fontSize: 18,
                                fontFamily: 'PixelFont',
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => _removePlayer(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (gameService.players.length >= 2)
                  ShinyButton(
                    text: 'Начать игру',
                    width: buttonWidth,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WhoDrawsScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
