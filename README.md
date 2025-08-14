# Multi Game App

> 🇷🇺 Русская версия ниже • English version below

## 🇬🇧 Description

A local multiplayer game platform where the **host** runs the game on a PC/desktop and **players** join from their smartphones **via QR code** in a browser.  
No installs — just scan and play.

> **Status:** in active development. Connection is currently verified on Android and desktop web. iOS support is in progress. New mini-games will be added gradually.

### 🔹 How It Works
1. Host runs the game on a PC (Windows desktop build).
2. The host starts a local HTTP/WebSocket server and displays a QR code with the join address (IP + port).
3. Players scan the QR code with their phone camera.
4. The link opens in the phone's browser, loading the web version of the game.
5. Player names are automatically generated as `Player {timestamp}`.
6. The host screen updates the number of connected players in real time.

### 🔹 Current Logic
- Connected players are stored in `_connectedPlayers` in `connection_controller.dart`.
- Real-time synchronization via WebSocket.
- Player screens are implemented for the web in `player_game_screen_web.dart`.
- Modular structure to easily add new mini-games.

### 🔹 Running
**Host (PC):**
```bash
flutter run -d windows
```

**Player (phone):**
- Must be on the same local network as the host.
- Scans the QR code displayed on the host screen.
- Opens the link in a browser.

**Build for Web:**
```bash
flutter build web
```
Output will be in `build/web/` — deploy to any static hosting or run locally.

### 🔹 Plans
- Full iOS browser support.
- Additional mini-games (quiz, drawing, reaction, etc.).
- Room code system.
- Improved connection stability and error handling.

### 📂 Main Files
```
lib/
 ├─ connection_controller.dart    # connection management
 ├─ player_game_screen.dart       # platform-specific entry point
 ├─ player_game_screen_web.dart   # player UI for web
```

---

## 🇷🇺 Описание

Локальная мультиплеерная платформа, где **хост** запускает игру на ПК/десктопе, а **игроки** подключаются со смартфонов **по QR-коду** через браузер.  
Никаких установок — просто сканируй и играй.

> **Статус:** активная разработка. Подключение проверено на Android и десктопном вебе. Поддержка iOS в процессе. Новые мини-игры будут добавляться постепенно.

### 🔹 Как это работает
1. Хост запускает игру на ПК (Windows desktop).
2. При старте поднимается локальный HTTP/WebSocket сервер и на экране показывается QR-код с адресом подключения (IP + порт).
3. Игроки сканируют QR-код камерой телефона.
4. Ссылка открывается в браузере телефона, загружая веб-версию игры.
5. Имя игрока создаётся автоматически в формате `Игрок {временная метка}`.
6. Количество подключённых отображается на экране хоста в реальном времени.

### 🔹 Текущая логика
- Список подключённых игроков хранится в `_connectedPlayers` (`connection_controller.dart`).
- Синхронизация в реальном времени через WebSocket.
- Экран игрока реализован для веба в `player_game_screen_web.dart`.
- Модульная архитектура — легко добавлять новые мини-игры.

### 🔹 Запуск
**Хост (ПК):**
```bash
flutter run -d windows
```

**Игрок (телефон):**
- Должен находиться в одной сети с хостом.
- Сканирует QR-код с экрана хоста.
- Открывает ссылку в браузере.

**Сборка для Web:**
```bash
flutter build web
```
Результат будет в `build/web/` — можно загрузить на хостинг или запустить локально.

### 🔹 Планы
- Полная поддержка браузеров на iOS.
- Дополнительные мини-игры (викторины, рисовалки, реакция и т.д.).
- Система кодов комнат.
- Улучшение стабильности соединений и обработки ошибок.

### 📂 Основные файлы
```
lib/
 ├─ connection_controller.dart    # управление подключениями
 ├─ player_game_screen.dart       # выбор платформенной реализации
 ├─ player_game_screen_web.dart   # интерфейс игрока для веба
```
