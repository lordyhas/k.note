# Setup

## Requirements

- Flutter SDK (`>=3.1.4 <4.0.0` from `pubspec.yaml`).
- Compatible Dart SDK (via Flutter).
- A configured Firebase project.

## Install dependencies

```bash
flutter pub get
```

## Platform-specific setup

### Android

- Provide `android/app/google-services.json` locally (gitignored).
- Confirm package/application ID alignment with your Firebase app.

### iOS

- `ios/Runner/GoogleService-Info.plist` is present in the repository.
- On macOS, install CocoaPods if required, then:

```bash
cd ios && pod install && cd ..
```

### Web

- Firebase web options are present in `lib/firebase_options.dart`.
- Run with:

```bash
flutter run -d chrome
```

## First run

```bash
flutter run
```

The app initializes Firebase in `main.dart`, creates auth/bloc dependencies, and starts routing via `go_router`.

## Environments / flavors

No Flutter flavor configuration was found in this repository (à confirmer if managed outside this repo).
