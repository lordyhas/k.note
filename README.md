# K.Note

K.Note is a comprehensive note-taking and task management application built with Flutter. It helps you organize your thoughts, tasks, and ideas in a beautiful and efficient interface.

## Features

- **Rich Text Editing**: Create and edit notes with rich text formatting using the integrated Quill editor.
- **Task Management**: improved task management system to keep track of your to-dos.
- **Authentication**: Secure login and sign-up functionality powered by Firebase Authentication.
- **State Management**: Robust state management using `flutter_bloc` and `hydrated_bloc` for persistent state across sessions.
- **Data Persistence**: 
  - **Local Storage**: Uses Hive for fast, offline-capable local storage.
  - **Cloud Sync**: syncs data with Cloud Firestore (configured in dependencies).
- **Navigation**: Smooth navigation handled by `go_router`.
- **Custom Design**: A custom-designed drawer and user interface with animations and a polished look.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Navigation**: [go_router](https://pub.dev/packages/go_router)
- **Database**: 
  - [Cloud Firestore](https://firebase.google.com/docs/firestore)
  - [Hive](https://pub.dev/packages/hive)
- **Editor**: [flutter_quill](https://pub.dev/packages/flutter_quill)
- **Authentication**: [firebase_auth](https://pub.dev/packages/firebase_auth)

## Getting Started

To run this project locally, follows these steps:

1.  **Prerequisites**:
    - Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed on your machine.
    - An IDE like VS Code or Android Studio.

2.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd k.note
    ```

3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```

## Testing

To run the unit tests:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
