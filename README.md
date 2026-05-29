# EthioFund Mobile

EthioFund Mobile is a cross-platform Flutter application for crowdfunding projects in Ethiopia. It provides role-based user flows for donors, organizers, and administrators, including campaign discovery, donations, user profiles, comments/updates, and admin management.

This repository contains the Flutter client application. The backend services are powered by Supabase (PostgreSQL + Authentication + Storage + Realtime).

---

# Quick Start

## Prerequisites

* Flutter SDK (Stable Channel)
* Dart SDK
* Android Studio / VS Code
* Android Emulator or Physical Device
* Supabase Project

---

# Clone the Repository

```bash
git clone <repo-url>
cd ethiofundmobile
flutter pub get
```

---

# Environment Variables Setup

Create a `.env` file in the project root and add the following:

```env
SUPABASE_URL=PASTE_YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=PASTE_YOUR_SUPABASE_ANON_KEY_HERE
```

## *Security Note*

> The following Supabase credentials are shared only for project evaluation and testing purposes.
>
> This project uses only the Supabase anon public key (client-side key), not the service_role key.
>
> For security awareness and best practices, these credentials will be regenerated and replaced after grading and evaluation are completed.
> 
> Create a .env file in the project root and add:

```bash
SUPABASE_URL=https://ujpzjgsrhtoumhpuxywh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqcHpqZ3NyaHRvdW1ocHV4eXdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMTAyNjcsImV4cCI6MjA5NTU4NjI2N30.9uhWuWjfcV6SNAfHGqTbPlfin0RbRhWE0j23zIhLPZA
``` 

> **Important**
>
> This project uses only the Supabase **anon public key** for client-side access.
>
> The `service_role` key is NOT used or exposed in this mobile application for security reasons.

---


# Run the Application

Basic run (auto-selects a connected device):

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

## Run targets and platform tips

### Windows (desktop)

Ensure desktop support is enabled and required tooling installed:

```bash
flutter config --enable-windows-desktop
flutter doctor
flutter pub get
flutter run -d windows
```

If you see build errors, run `flutter doctor` and install any missing Visual Studio components (Desktop development with C++).

### Web — Chrome

Enable web support and run on Chrome:

```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

### Web — Edge

If Edge appears as a device, run directly; otherwise use the web-server and open in Edge manually:

```bash
flutter run -d edge
# or
flutter run -d web-server  # then open http://localhost:xxxx in Edge
```

Notes:
- Ensure you have a compatible Chrome or Edge installation on the machine used for testing.
- For web builds you may want to set `--web-renderer=html` or `--web-renderer=canvaskit` depending on performance and CanvasKit availability.

---

## Untrack generated / build files (recommended)

You should not commit generated build artifacts to the repository. I updated `.gitignore` to include common generated files. To remove already-tracked generated files from the repository (without deleting them locally), run the following from the project root:

```bash
git rm -r --cached build .dart_tool .flutter-plugins-dependencies .metadata 2> /dev/null
git add .gitignore
git commit -m "chore: ignore and untrack generated files"
git push
```

On Windows PowerShell you can run the same sequence (PowerShell redirects stderr with `2>$null`):

```powershell
git rm -r --cached build .dart_tool .flutter-plugins-dependencies .metadata 2>$null; git add .gitignore; git commit -m "chore: ignore and untrack generated files"; git push
```

This removes generated files from the git index while keeping them on your local disk.

---

# Run Tests

```bash
flutter test
```

---

# Features

* User Authentication
* Role-Based Access
* Campaign Creation
* Campaign Browsing
* Donation System
* Campaign Updates & Comments
* Withdrawal Requests
* Admin Dashboard
* Supabase Storage Integration

---

# Architecture Overview

* Flutter UI under `lib/`
* Riverpod for state management
* Supabase backend integration
* Services under `lib/services/`
* Models under `lib/models/`
* Environment configuration using `flutter_dotenv`

---

# Important Files

* `lib/main.dart`
* `lib/services/supabase_service.dart`
* `lib/services/auth_service.dart`
* `lib/services/admin_service.dart`
* `supabase/schema.sql`

---

# Folder Structure

```text
lib/
├── app.dart
├── main.dart
├── core/
├── services/
├── models/
├── features/
├── providers/
└── shared/

supabase/
assets/
android/
ios/
web/
windows/
linux/
macos/
```

---

# Supabase Integration

This app uses Supabase for:

* Authentication
* PostgreSQL Database
* File Storage
* Realtime Features

Initialization example:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

---

# Security Notes

* Only the Supabase anon key is used.
* The `service_role` key is never exposed to the client.
* Row Level Security (RLS) should be enabled in Supabase.

---

# Troubleshooting

## Missing Environment Variables

Ensure `.env` exists in the project root 

## Authentication Errors

* Verify Supabase Auth settings
* Check project URL and anon key
* Confirm email/password authentication is enabled

## Database Permission Errors

Verify Row Level Security (RLS) policies in Supabase.

---

# Technologies Used

* Flutter
* Dart
* Riverpod
* Supabase Authentication
* Supabase Database
* Supabase Storage

---

# Contributors

 * 1. Ashenafi Bancha
 * 2. Elham Jemal
 * 3. Feruza Hassen
 * 4. Ihsan Jemal
