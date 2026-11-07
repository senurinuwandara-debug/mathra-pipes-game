# Mathra Pipes Game

Connect the pipes… clear the level! Flutter (Android) puzzle game by **Denuwan Akash**.

Based on the open-source *Pipes* game by sidhant947 (GPL-3.0, see `LICENSE`).

## Features
- 3D buttons everywhere, 3D tilt About page
- Playlist: paste a YouTube link, the audio is downloaded and added automatically; mini player inside the game
- Local 3D leaderboard (names + scores of everyone who plays on the device)
- Emoji rain effect button in game; slow / fast speed + emoji pack in Settings

## Build
```
flutter pub get
flutter build apk --release
```
Without `android/key.properties` the release APK is signed with the debug key.
