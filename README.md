# EthioFund Mobile

EthioFund is a Flutter crowdfunding app for Ethiopian campaigns, donors, organizers, and admins.

See [ETHIOFUND_FLUTTER_GUIDE.md](ETHIOFUND_FLUTTER_GUIDE.md) for the app structure, file map, and how the screens and services fit together.

## What is implemented

- Onboarding with first-run tracking
- Auth screens with role-based registration
- Campaign browse and details
- Donation checkout handoff with WebView return handling
- Comments and organizer updates
- Withdrawal requests and history
- Profile editing and sign out
- Admin dashboard, users, campaigns, withdrawals, and reports

## Requirements

- Flutter SDK installed
- Android emulator, iOS simulator, or desktop platform enabled
- Backend API available at the base URL configured in `lib/core/constants/api_constants.dart`

## Run

```bash
flutter pub get
flutter run
```

To run on Android emulator:

```bash
flutter devices
flutter run -d <device_id>
```

## Test

```bash
flutter test
```

## Notes

- The app expects the backend routes defined in the API constants file.
- If you need to change the backend host for a physical device, update the base URL to your machine address.