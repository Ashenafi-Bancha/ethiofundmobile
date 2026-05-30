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

Create a local `.env` file in the project root. The app loads this file from [lib/main.dart](lib/main.dart), so it must exist before running Flutter.

On Windows PowerShell, copy the template first:

```powershell
Copy-Item .env.example .env
```

On macOS/Linux:

```bash
cp .env.example .env
```

Then fill in your Supabase values:

```env
SUPABASE_URL=PASTE_YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=PASTE_YOUR_SUPABASE_ANON_KEY_HERE
```

## *Security Note*

> Only the Supabase anon public key is used in the Flutter client.
>
> Do not commit `.env` to GitHub. The file is ignored by `.gitignore`, and the repository includes `.env.example` for setup.
>
> The `service_role` key is never used or exposed in the mobile app.

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

### App icon and logo for Desktop & Web

- This project already includes the EthioFund logo at `assets/images/ethiofund_logo.png` and the mobile launcher is managed by `flutter_launcher_icons`.
- For web (Chrome/Edge) the app uses the same logo as the favicon, PWA icon, and initial loading splash. These are configured in `web/index.html` and `web/manifest.json` to reference `assets/images/ethiofund_logo.png` so the branding matches mobile.
- For Windows the application binary uses `windows/runner/resources/app_icon.ico` for the taskbar and executable icon. To make the Windows icon match the EthioFund logo you should:

  1. Create an ICO file from your PNG (multiple sizes recommended: 16, 32, 48, 256). Example using ImageMagick:

```bash
magick convert assets/images/ethiofund_logo.png -resize 256x256 favicon-256.png
magick convert favicon-256.png -define icon:auto-resize=64,48,32,16 windows/runner/resources/app_icon.ico
```

  2. Replace the existing `windows/runner/resources/app_icon.ico` with the generated file.
  3. Rebuild the Windows app: `flutter build windows` (or `flutter run -d windows` for debug).

Notes:
- If you don't have ImageMagick installed, there are online converters or GUI tools to generate `.ico` from PNG.
- The project uses `MaterialApp.title = 'EthioFund'` so desktop window title and web tab title will show the friendly name.
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

Ensure `.env` exists in the project root and contains `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

If you are starting from the template, copy `.env.example` to `.env` first and then fill in the real values.

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
