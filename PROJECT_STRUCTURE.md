# K.NOTE Project Structure Documentation

## Project Overview
**K.NOTE** is a Flutter-based note-taking application with Firebase backend integration, supporting both online and offline functionality. The app uses BLoC pattern for state management and includes features like authentication, text editing, and cloud synchronization.

## Project Metadata
- **Name**: knote
- **Version**: 0.2.3+2
- **Authors**: Hassan Kajila (lordyhas), Dan Kajila
- **Flutter SDK**: >=3.1.4 <4.0.0
- **Description**: A new K.NOTE project

## Architecture Pattern
- **State Management**: BLoC (Business Logic Component) pattern using `flutter_bloc`
- **Navigation**: GoRouter for declarative routing
- **Architecture**: Clean Architecture with Repository pattern
- **Database**: Firebase Firestore + Local storage (Hive)

## Core Dependencies

### State Management & Architecture
- `flutter_bloc: ^9.1.1` - BLoC pattern implementation
- `hydrated_bloc: ^10.1.1` - Persistent BLoC state
- `equatable: ^2.0.7` - Value equality

### Firebase & Backend
- `firebase_core: ^2.19.0` - Firebase initialization
- `firebase_auth: ^4.11.1` - Authentication
- `cloud_firestore: ^4.11.0` - Cloud database
- `google_sign_in: ^6.1.5` - Google authentication

### UI & Navigation
- `go_router: ^13.0.0` - Declarative routing
- `flutter_quill: ^11.4.2` - Rich text editor
- `curved_labeled_navigation_bar: ^2.0.2` - Custom navigation
- `google_fonts: ^5.0.0` - Typography

### Local Storage & Utilities
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Flutter Hive integration
- `permission_handler: ^11.0.1` - Device permissions
- `file_picker: ^10.3.2` - File selection

## Project Structure

### Root Directory
```
k.note/
├── android/          # Android-specific configuration
├── ios/             # iOS-specific configuration
├── assets/          # Static assets (images, fonts)
├── fonts/           # Custom fonts (WorkSans, Roboto)
├── lib/             # Main Dart source code
├── test/            # Test files
├── web/             # Web platform support
└── pubspec.yaml     # Dependencies and project configuration
```

### Core Source Code (`lib/`)

#### Main Entry Points
- `main.dart` - Application entry point, Firebase initialization, BLoC setup
- `routes.dart` - GoRouter configuration and route definitions
- `navigation_home_screen.dart` - Main navigation shell
- `splash_page.dart` - Loading screen
- `log_page.dart` - Logging/error page

#### Data Layer (`lib/data/`)
```
data/
├── app_bloc/                    # BLoC implementations
│   ├── authentication/          # Authentication state management
│   ├── login_bloc/             # Login flow logic
│   ├── signup_bloc/            # Signup flow logic
│   └── navigation_controller_cubit.dart
├── app_bloc.dart               # Main BLoC exports and observer
├── app_database.dart           # Database interface
├── authentication_repository.dart # Auth repository implementation
├── database/                   # Database implementations
│   ├── database_manager.dart   # Local database manager (ObjectBox)
│   ├── database_model.dart     # Database model definitions
│   ├── firebase_manager.dart   # Firebase operations
│   └── model/                  # Data models
├── theme_and_language_cubit.dart # UI theme and language state
└── values/                     # App constants and styles
    ├── dimens.dart             # Dimension constants
    ├── strings.dart            # String constants
    └── styles.dart             # Style definitions
```

#### UI Layer (`lib/src/`)
```
src/
├── backgound_ui.dart           # Background UI components
├── pages/                      # Main application pages
│   ├── pages/                  # Core feature pages
│   │   ├── home_screen.dart    # Main home screen
│   │   ├── archived_note_screen.dart
│   │   ├── feedback_screen.dart
│   │   ├── help_screen.dart
│   │   ├── invite_friend_screen.dart
│   │   ├── offline_note_screen.dart
│   │   └── calendar_screen.dart
│   ├── login/                  # Authentication pages
│   ├── custom_drawer/          # Navigation drawer
│   ├── new_text_editor_page.dart # Modern text editor
│   ├── old_text_editor_page.dart # Legacy text editor
│   ├── setting_page.dart       # Settings and profile
│   ├── about_page.dart         # About page
│   ├── trash_can.dart          # Deleted notes
│   └── screens.dart            # Page exports
└── widgets/                    # Reusable UI components
    ├── button_circular_progress_widget.dart
    ├── coming_soon.dart
    └── note_card.dart
```

## Key Features & Screens

### Authentication Flow
- Login/Signup with email and Google authentication
- Firebase Auth integration
- Protected routes with authentication guards

### Main Features
- **Home Screen**: Main dashboard with note list
- **Text Editor**: Rich text editing with Flutter Quill
- **Note Management**: Create, edit, archive, delete notes
- **Cloud Sync**: Firebase Firestore synchronization
- **Offline Support**: Local storage with Hive
- **Settings**: User profile and app preferences

### Navigation Structure
```
/                           → LogPage (Entry)
/login                      → LoginPage
/signup                     → Redirect based on auth status
/r/home                     → Redirect to home
/home                       → HomeScreen (Protected)
├── /about                 → AboutPage
├── /invite-friend         → InviteFriend
├── /help                  → HelpScreen
├── /feedback              → FeedbackScreen
├── /archived              → ArchivedScreen
├── /offline               → OfflineScreen
├── /text-editor           → TextEditor
└── /old-text-editor       → OldTextEditor
/settings                   → SettingProfileScreen (Protected)
├── /product-table         → Product table
└── /note-trash            → NoteTrash
```

## State Management Architecture

### BLoC Structure
- **AuthenticationBloc**: Manages user authentication state
- **LoginCubit**: Handles login form state
- **SignUpCubit**: Manages signup process
- **LanguageBloc**: App language preferences
- **StyleCubit**: UI theme and styling

### Repository Pattern
- **AuthRepository**: Authentication operations
- **FirebaseManager**: Cloud database operations
- **DatabaseManager**: Local database operations

## Database Architecture

### Cloud Database (Firebase)
- **Collection Structure**: `K_NOTE/general_data/USERS/{userId}/notes`
- **Note Model**: Includes fields for content, metadata, sync status
- **User Management**: Firebase Auth + Firestore user profiles

### Local Database (Hive)
- **ObjectBox Integration**: Local note storage
- **Offline Support**: Notes cached locally for offline access
- **Sync Management**: Conflict resolution and sync status tracking

## Asset Management

### Images
- **UI Elements**: Icons, logos, profile images
- **Backgrounds**: Multiple background options for customization
- **Feedback**: Help, support, and feedback-related images

### Fonts
- **WorkSans**: Primary font family (Regular, Medium, SemiBold, Bold)
- **Roboto**: Secondary font family (Regular, Medium, Bold)

## Platform Support
- **Android**: Full native support with custom configurations
- **iOS**: Full native support with iOS-specific assets
- **Web**: Progressive web app support
- **Cross-platform**: Shared business logic with platform-specific UI

## Development Workflow
1. **State Changes**: Use BLoC pattern for all state management
2. **Navigation**: Declarative routing with GoRouter
3. **Data Persistence**: Firebase for cloud, Hive for local
4. **UI Components**: Reusable widgets in `src/widgets/`
5. **Testing**: Widget tests in `test/` directory

## Key Implementation Notes
- Uses `flutter_bloc` for state management
- Implements repository pattern for data access
- Supports both online and offline modes
- Multi-language support (English, French)
- Dark theme by default with customization options
- Firebase integration for cloud synchronization
- Local storage for offline functionality
