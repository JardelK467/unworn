# UNWORN

### Your. Garment. Reimagined.

Unworn is a mobile app that lets you photograph a garment you own and uses AI to reimagine it into fresh, wearable concepts. It analyses the fabric, colour, cut, and silhouette of the original piece, then generates three styled variations complete with AI-produced editorial imagery — giving old clothes a second creative life.

## Tech Stack

- Flutter
- Gemini AI (text analysis + image generation)
- Clean Architecture
- BLoC / Cubit
- go_router
- get_it

## Running the app

```
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

## Building the APK

```
flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
```

## Notes

- API key is never hardcoded in source
- Built as a technical demo for Loom
