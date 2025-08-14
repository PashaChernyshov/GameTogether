# Game Together

> 🇷🇺 Русская версия ниже • English version below

## 🇬🇧 Description

A multiplayer party game where the **host** runs the game on a PC/desktop and **players** join from their smartphones **via QR code** in a browser.  
No installs — just scan and play.

> **Status:** in active development. Connection is currently verified only on Android. iOS and other platforms are in progress. More games will be added over time.

### 🔹 How It Works
1. Host runs the game on a PC.
2. A QR code with the join address is shown on the host screen.
3. Players scan the code with their phone and join the lobby.
4. Player names are auto-generated as `Player {timestamp}`.
5. Host screen shows the number of connected players in real time.

### 🔹 Current Logic
- Connected players are stored in `_connectedPlayers`.
- Synchronization via WebSocket.
- Game screens are simple for now, but the system is modular for adding mini-games.

### 🔹 Running
**Host (PC):**
```bash
flutter run -d windows   # or macos/linux
```

**Player (phone):**
- Must be on the same network as the host.
- Scans the QR code from the host screen.
- Opens the link in a browser.

### 🔹 Plans
- iOS support.
- Set of mini-games (quizzes, drawing, reaction, etc.).
- Room codes.
- Improved connection stability.

### 📂 Main Files
```
lib/
 ├─ connection_controller.dart    # connection management
 ├─ player_game_screen.dart       # platform entry point
 ├─ player_game_screen_web.dart   # player screen (web)
```

---

## 🇷🇺 Описание

Мультиплеер для компаний, где **хост** запускает игру на ПК/десктопе, а **игроки** подключаются со смартфонов **по QR-коду** через браузер.  
Никаких установок — просто сканируй и играй.

> **Статус:** активная разработка. Подключение проверено только на Android. Поддержка iOS и других платформ — в процессе. Игры будут добавляться постепенно.

### 🔹 Как это работает
1. Хост запускает игру на ПК.
2. На экране показывается QR-код с адресом подключения.
3. Игроки сканируют код смартфоном и попадают в лобби.
4. Имя игрока создаётся автоматически — `Игрок {временная метка}`.
5. Количество подключённых отображается на экране хоста в реальном времени.

### 🔹 Текущая логика
- Список подключённых игроков хранится в `_connectedPlayers`.
- Синхронизация — через WebSocket.
- Игровые экраны пока простые, но система модульная: можно добавлять мини-игры.

### 🔹 Запуск
**Хост (ПК):**
```bash
flutter run -d windows   # или macos/linux
```

**Игрок (телефон):**
- Находится в одной сети с хостом.
- Сканирует QR-код с экрана хоста.
- Открывает ссылку в браузере.

### 🔹 Планы
- Поддержка iOS.
- Набор мини-игр (викторины, рисовалки, реакция и т.д.).
- Коды комнат.
- Улучшение стабильности соединений.

### 📂 Основные файлы
```
lib/
 ├─ connection_controller.dart    # управление подключениями
 ├─ player_game_screen.dart       # выбор платформенной реализации
 ├─ player_game_screen_web.dart   # экран игрока (веб)
```
