# GameTogether

Local multiplayer party game platform built with `Flutter`.

`GameTogether` is designed around a host-and-join flow: the host launches the game on desktop, a local server exposes a join link, and players connect from their phones by scanning a QR code in the browser. The project is structured as a platform for multiple mini-games rather than a single game.

## Core Idea

- host runs the experience on desktop
- players join instantly from mobile browsers
- connection happens over local network
- game sessions are synchronized in real time
- new mini-games can be added into the same platform

## Current Capabilities

- QR-based player onboarding
- local HTTP and WebSocket connection flow
- browser-based player entry point
- real-time player count and session state
- modular game selection from the home screen
- active mini-game implementations already present in the codebase

## Included Game Areas

- connection and lobby flow
- `slepoy_hudojnic` party drawing game
- `chestnaya_nastolka` board-game style module

## Tech Stack

- Flutter
- Dart
- Provider
- WebSocket
- Shelf
- qr_flutter
- audioplayers

## Architecture Overview

```text
lib/
  features/home/                game selection and host entry
  features/connection/          QR flow, network connection, lobby logic
  features/player/              mobile browser player interface
  games/slepoy_hudojnic/        drawing game module
  games/chestnaya_nastolka/     board game module
  core/                         shared configuration
```

## Run the Host

```bash
flutter pub get
flutter run -d windows
```

## Join as a Player

1. Connect the phone to the same local network as the host device.
2. Scan the QR code shown on the host screen.
3. Open the generated browser link.
4. Join the current session from the mobile web interface.

## Other Commands

```bash
flutter run -d chrome
flutter build web
flutter test
```

## Status

Active prototype platform with real networking flow and multiple game modules already started. Best suited for experimentation, local party sessions, and further product expansion.

## Roadmap Direction

- better connection resilience
- broader iOS browser support
- additional mini-games
- stronger room/session management
- more polished host controls and player feedback
