# HireMe 🛠️

A modern on-demand service platform connecting customers with skilled blue-collar workers and service professionals (carpenters, electricians, plumbers, cleaners, and more).

---

## 🚀 Features

- **Role-Based Access**: Dedicated onboarding & interfaces for both **Customers** and **Workers**.
- **Real-Time Job Requests**: Instant job postings, status tracking (pending, accepted, in progress, completed).
- **Location Services**: Proximity calculation and geolocation support.
- **Firebase Authentication**: Email/Password and phone authentication.
- **Cloud Firestore**: Real-time reactive data streams.
- **Modern UI**: Polished Material 3 design with responsive layouts and Plus Jakarta Sans typography.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable, Dart 3.x)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Backend / BaaS**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore, Storage, Cloud Messaging)

---

## 📋 Setup & Installation

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.3.0`)
- [Android Studio](https://developer.android.com/studio) with Android SDK and Command-line Tools

### 2. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/hire_me.git
cd hire_me
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Firebase
This project relies on Firebase for authentication and database services.

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password) and **Cloud Firestore**.
3. Configure the Flutter app with your Firebase credentials:
   ```bash
   # Install the FlutterFire CLI if you haven't already
   dart pub global activate flutterfire_cli

   # Configure your Firebase project
   flutterfire configure
   ```
   *Alternatively, copy `android/app/google-services.json.example` to `android/app/google-services.json` and insert your project credentials.*

### 5. Run the Application
Start your Android Emulator or connect a physical device, then run:
```bash
flutter run
```

---

## 🔒 Security & Contribution Notes

- Sensitive credentials (`google-services.json`, `firebase_options.dart`, `.env`) are excluded via `.gitignore` to prevent leaking live project credentials.
- Security rules are defined in `firestore.rules`.
