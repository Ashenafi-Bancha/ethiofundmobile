
# EthioFund Mobile

EthioFund Mobile is a cross-platform Flutter application for crowdfunding projects in Ethiopia. It provides role-based user flows for donors, organizers, and administrators, including campaign discovery, donations, user profiles, comments/updates, and admin management.

This repository contains the Flutter client application. The backend services are powered by Supabase (PostgreSQL + Authentication + Storage + Realtime) and Chapa for payments.

---

# 🚀 Demo Access Accounts (For Evaluators / Testers)

Please use the following pre-created accounts to test different roles in the system:

## 👤 Donor Account
- Email: **ashenafibanchabassa01@gmail.com**
- Password: **387300**

## 🧑‍💼 Organizer Account
- Email: **feruzhassen@gmail.com**
- Password: **123456**

## 🛡️ Admin Account
- Email: **admin@ethiofund.com**
- Password: **Admin1234**

> ⚠️ These accounts are provided for testing and evaluation purposes only.

---

# 📌 Quick Start

## Prerequisites

- Flutter SDK (Stable Channel)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device
- Supabase Project

---

# 📥 Clone the Repository

```bash
git clone https://github.com/Ashenafi-Bancha/ethiofundmobile
cd ethiofundmobile
flutter pub get
````

---

# ⚙️ Environment Variables Setup
> ⚠️ Evaluation Note:
> For evaluation and testing purposes only, the `.env` configuration values have been documented and shared in this README to simplify setup and allow reviewers to run the project without additional configuration steps. In a production environment, the `.env` file must never be committed or exposed publicly, and all sensitive keys must be securely managed using environment secrets or backend configuration.

```

---

# 🔐 Security Note

* Only Supabase **anon public key** is used in Flutter
* `service_role` key is NEVER exposed in the app
* `.env` is excluded from Git

---

# ▶️ Run the App

```bash
flutter run
```

---

## Platform Targets

### Android / Emulator

```bash
flutter devices
flutter run -d emulator
```

### Windows Desktop

```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

### Web (Chrome)

```bash
flutter run -d chrome
```

---

# 🏗️ Features

* User Authentication (Supabase Auth)
* Role-Based Access Control (Admin / Organizer / Donor)
* Campaign Creation & Management
* Campaign Browsing & Search
* Donation System (Chapa Payment Integration)
* Admin Dashboard
* Campaign Image Upload (Supabase Storage)
* Real-time Updates & Notifications

---

# 🧱 Architecture Overview

* Flutter (Frontend)
* Riverpod (State Management)
* Supabase (Backend-as-a-Service)
* PostgreSQL (Database)
* Supabase Storage (Images & Media)
* Supabase Edge Functions (Payment Webhooks)
* Chapa Payment Gateway

---

# 📂 Project Structure

```text
lib/
├── main.dart
├── app.dart
├── core/
├── features/
│   ├── auth/
│   ├── admin/
│   ├── campaigns/
│   ├── donations/
│   └── profile/
├── services/
├── models/
├── providers/
└── shared/

supabase/
assets/
android/
ios/
web/
windows/
```

---

# 🧾 Important Files

* lib/main.dart
* lib/services/supabase_service.dart
* lib/services/payment_service.dart
* supabase/functions/chapa-initiate-payment
* supabase/functions/chapa-webhook

Note: The client opens the Chapa checkout in an external browser and the
final payment confirmation is performed server-side (Supabase Edge Function
webhook). Do not rely on client return URLs for finalizing donations.
* supabase/migrations/

---

# ☁️ Supabase Integration

Used for:

* Authentication
* Database (PostgreSQL)
* File Storage
* Edge Functions

Initialization:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

---

# 🔒 Security Notes

* Only anon key used in client
* Service role key used only in Edge Functions
* Row Level Security (RLS) enabled
* Role-based access control enforced

---

# 🧪 Testing Roles

| Role      | Email                                                                     | Password  |
| --------- | ------------------------------------------------------------------------- | --------- |
| Donor     | [ashenafibanchabassa01@gmail.com](mailto:ashenafibanchabassa01@gmail.com) | 387300    |
| Organizer | [feruzhassen@gmail.com](mailto:feruzhassen@gmail.com)                     | 123456    |
| Admin     | [admin@ethiofund.com](mailto:admin@ethiofund.com)                         | Admin1234 |

---

# 🛠️ Troubleshooting

## Missing .env

Ensure `.env` exists in root directory.

## Auth Issues

Check Supabase Auth settings.

## Database Errors

Enable RLS policies properly.

---

# 📦 Technologies Used

* Flutter
* Dart
* Riverpod
* Supabase
* PostgreSQL
* Supabase Edge Functions
* Chapa Payment Gateway

---

# 👥 Contributors

| Name            |ID        |
| --------------- |----------|
| Ashenafi Bancha |  UGR/1796/15        |
| Elham Jemal     |  UGR/1757/14       |
| Feruza Hassen   |   UGR/6423/15        |
| Ihsan Jemal     |      UGR/9433/15      |

```

