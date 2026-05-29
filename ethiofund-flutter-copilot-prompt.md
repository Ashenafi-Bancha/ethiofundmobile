# 🤖 GitHub Copilot Prompt — EthioFund Flutter Mobile App
> Built from the actual EthioFund backend documentation (May 2026)
>
> **How to use:** Open Copilot Chat in VS Code (`Ctrl+Shift+I`).
> **ALWAYS paste the Project Context block first** at the start of every new session.
> Then paste each phase prompt in order, one at a time.

---

## 📋 PROJECT CONTEXT — Paste This First in Every Session

```
I am building the EthioFund Flutter mobile app. EthioFund is a crowdfunding platform
for Ethiopia. The backend (Node.js + Express + TypeScript + PostgreSQL) is already fully
built and running. I am now building a Flutter mobile app that consumes the backend REST API.

=== BACKEND ALREADY EXISTS — DO NOT REBUILD IT ===
The Flutter app is a REST API client only. All business logic lives in the backend.

--- BACKEND API BASE URL ---
Development: http://10.0.2.2:5000/api   (Android emulator)
Physical device: http://YOUR_LOCAL_IP:5000/api

--- AUTHENTICATION ---
- JWT-based. Token stored securely in flutter_secure_storage.
- Every protected request sends: Authorization: Bearer <token>
- Token payload contains: { userId, role, email }

--- USER ROLES ---
- guest: browse campaigns, view details, register/login
- donor: everything guest + donate, view own donation history, leave comments
- organizer: everything donor + create campaigns, post updates, request withdrawal
- admin: approve/reject campaigns, manage users, view reports, manage withdrawals

--- BACKEND MODULES (9 REST modules under /api/) ---
POST   /api/auth/register          → register (role: donor or organizer)
POST   /api/auth/login             → login, returns { token, user }
POST   /api/auth/logout            → logout (auth required)

GET    /api/campaigns              → all approved/active campaigns (public)
GET    /api/campaigns/:id          → single campaign detail (public)
POST   /api/campaigns              → create campaign (organizer only)
PUT    /api/campaigns/:id          → update campaign (organizer, own only)
POST   /api/campaigns/:id/updates  → post campaign update (organizer)
GET    /api/campaigns/:id/updates  → get campaign updates (public)
PATCH  /api/campaigns/:id/approve  → approve (admin)
PATCH  /api/campaigns/:id/reject   → reject (admin)
PATCH  /api/campaigns/:id/suspend  → suspend (admin)

GET    /api/donations/my           → my donation history (donor/organizer)
GET    /api/donations/campaign/:id → campaign donations (public)

POST   /api/payments/initialize    → start Chapa payment, returns { checkout_url }
GET    /api/payments/verify/:tx_ref → Chapa callback (backend handles this)

POST   /api/comments               → add comment (authenticated)
GET    /api/comments/campaign/:id  → get campaign comments (public)

POST   /api/withdrawals            → request withdrawal (organizer)
GET    /api/withdrawals/my         → my withdrawals (organizer)
GET    /api/withdrawals/pending    → pending withdrawals (admin)
PATCH  /api/withdrawals/:id/approve → approve withdrawal (admin)
PATCH  /api/withdrawals/:id/reject  → reject withdrawal (admin)

GET    /api/users/me               → my profile (authenticated)
PUT    /api/users/me               → update profile (authenticated)

GET    /api/admin/dashboard        → dashboard stats (admin)
GET    /api/admin/users            → all users (admin)
PATCH  /api/admin/users/:id/suspend  → suspend user (admin)
PATCH  /api/admin/users/:id/activate → activate user (admin)
GET    /api/admin/campaigns        → all campaigns any status (admin)

GET    /api/reports?type=campaign    → campaign report (admin)
GET    /api/reports?type=donation    → donation report (admin)
GET    /api/reports?type=user        → user report (admin)
GET    /api/reports?type=financial   → financial report (admin)

--- ALL API RESPONSES FOLLOW THIS FORMAT ---
Success: { "success": true, "data": { ... } }
Error:   { "success": false, "message": "..." }

--- PAYMENT FLOW (CHAPA) ---
1. App calls POST /api/payments/initialize with { campaign_id, amount, is_anonymous }
2. Backend returns { checkout_url } — a Chapa-hosted payment page URL
3. App opens the checkout_url in a WebView (flutter_inappwebview)
4. User pays on Chapa's page
5. Chapa redirects back to the app's return URL
6. App detects the return URL and closes WebView
7. App shows success/failure screen

--- CAMPAIGN CATEGORIES ---
medical | education | funeral | emergency | community

--- CAMPAIGN STATUSES ---
pending | approved | active | closed | rejected | suspended

--- FLUTTER TECH STACK FOR THIS PROJECT ---
- State management: flutter_riverpod (^2.x)
- Navigation: go_router (^13.x)
- HTTP client: dio (^5.x) with interceptors for JWT
- Secure storage: flutter_secure_storage (^9.x)
- WebView (Chapa payment): flutter_inappwebview (^6.x)
- Image picker: image_picker (^1.x)
- Local preferences: shared_preferences (^2.x)
- Date formatting: intl (^0.19.x)
- Form validation: Built-in Flutter + custom validators
- Icons: Material Icons (built-in)
- UI: Material Design 3 with custom EthioFund theme
- Linting: flutter_lints

--- ETHIOFUND COLOR SCHEME ---
Primary: #1B5E20 (deep green — Ethiopian flag inspired)
Secondary: #FDD835 (gold/yellow — Ethiopian flag)
Accent: #D32F2F (red — for urgent campaigns)
Background: #F5F5F5
Surface: #FFFFFF
Text primary: #212121
Text secondary: #757575
```

---

## 🗂️ PHASE 1 — Project Setup & Structure

### Prompt 1.1 — Create the Flutter project structure

```
Using the EthioFund Flutter project context above, generate the complete
folder structure for the Flutter app. The project name is `ethiofund_mobile`.

Create all necessary folders and placeholder files with this structure:

lib/
├── main.dart
├── app.dart                          ← MaterialApp + GoRouter setup
├── core/
│   ├── constants/
│   │   ├── api_constants.dart        ← base URLs, endpoint strings
│   │   ├── app_colors.dart           ← EthioFund color palette
│   │   └── app_strings.dart          ← all UI string constants
│   ├── theme/
│   │   └── app_theme.dart            ← MaterialTheme with EthioFund colors
│   ├── network/
│   │   ├── dio_client.dart           ← Dio singleton with JWT interceptor
│   │   └── api_exception.dart        ← custom exception for API errors
│   ├── storage/
│   │   └── secure_storage.dart       ← flutter_secure_storage wrapper
│   ├── router/
│   │   └── app_router.dart           ← GoRouter with role-based guards
│   └── utils/
│       ├── validators.dart           ← form validation helpers
│       └── formatters.dart           ← date, currency ETB formatters
├── models/
│   ├── user_model.dart
│   ├── campaign_model.dart
│   ├── donation_model.dart
│   ├── comment_model.dart
│   ├── withdrawal_model.dart
│   └── report_model.dart
├── providers/
│   ├── auth_provider.dart            ← Riverpod auth state
│   ├── campaign_provider.dart
│   ├── donation_provider.dart
│   ├── comment_provider.dart
│   └── withdrawal_provider.dart
├── services/
│   ├── auth_service.dart             ← calls /api/auth/*
│   ├── campaign_service.dart         ← calls /api/campaigns/*
│   ├── donation_service.dart         ← calls /api/donations/*
│   ├── payment_service.dart          ← calls /api/payments/*
│   ├── comment_service.dart          ← calls /api/comments/*
│   ├── withdrawal_service.dart       ← calls /api/withdrawals/*
│   ├── user_service.dart             ← calls /api/users/*
│   └── admin_service.dart            ← calls /api/admin/* and /api/reports/*
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart          ← campaign feed
│   │   └── widgets/
│   │       ├── campaign_card.dart
│   │       └── category_filter.dart
│   ├── campaign/
│   │   ├── campaign_detail_screen.dart
│   │   ├── create_campaign_screen.dart
│   │   ├── edit_campaign_screen.dart
│   │   ├── my_campaigns_screen.dart
│   │   └── widgets/
│   │       ├── campaign_progress_bar.dart
│   │       ├── campaign_update_card.dart
│   │       └── donation_list_item.dart
│   ├── donation/
│   │   ├── donate_screen.dart
│   │   ├── payment_webview_screen.dart
│   │   ├── payment_success_screen.dart
│   │   ├── payment_failed_screen.dart
│   │   └── my_donations_screen.dart
│   ├── comments/
│   │   └── widgets/
│   │       ├── comment_list.dart
│   │       └── add_comment_bar.dart
│   ├── withdrawal/
│   │   ├── request_withdrawal_screen.dart
│   │   └── my_withdrawals_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart
│       ├── admin_campaigns_screen.dart
│       ├── admin_users_screen.dart
│       ├── admin_withdrawals_screen.dart
│       └── admin_reports_screen.dart
└── shared/
    ├── widgets/
    │   ├── primary_button.dart
    │   ├── loading_widget.dart
    │   ├── error_widget.dart
    │   ├── empty_state_widget.dart
    │   ├── ethiofund_app_bar.dart
    │   └── avatar_widget.dart
    └── extensions/
        └── context_extensions.dart   ← theme/color shortcuts

Also generate `pubspec.yaml` with all required dependencies at correct versions:
- flutter_riverpod: ^2.5.1
- go_router: ^13.2.0
- dio: ^5.4.3
- flutter_secure_storage: ^9.0.0
- flutter_inappwebview: ^6.0.0
- image_picker: ^1.0.7
- shared_preferences: ^2.2.3
- intl: ^0.19.0
- flutter_lints: ^4.0.0
```

---

### Prompt 1.2 — pubspec.yaml, theme, and constants

```
Using the EthioFund Flutter project context, generate these files:

1. `lib/core/constants/api_constants.dart`
   - Class ApiConstants with static const String values:
   - baseUrl (Android emulator: 'http://10.0.2.2:5000/api')
   - All endpoint paths as constants, e.g.:
     static const String login = '/auth/login';
     static const String register = '/auth/register';
     static const String campaigns = '/campaigns';
     static const String payments = '/payments';
     static const String comments = '/comments';
     etc. for every endpoint in the project context

2. `lib/core/constants/app_colors.dart`
   - Class AppColors with static const Color values:
   - primary: Color(0xFF1B5E20)       deep green
   - secondary: Color(0xFFFDD835)     gold yellow
   - accent: Color(0xFFD32F2F)        urgent red
   - background: Color(0xFFF5F5F5)
   - surface: Color(0xFFFFFFFF)
   - textPrimary: Color(0xFF212121)
   - textSecondary: Color(0xFF757575)
   - success: Color(0xFF2E7D32)
   - warning: Color(0xFFF57C00)
   - error: Color(0xFFC62828)
   - pendingBadge: Color(0xFFF9A825)
   - approvedBadge: Color(0xFF1B5E20)
   - rejectedBadge: Color(0xFFB71C1C)

3. `lib/core/theme/app_theme.dart`
   - ThemeData using Material Design 3
   - ColorScheme.fromSeed(seedColor: AppColors.primary)
   - Custom AppBar theme: green background, white title text
   - Custom ElevatedButton theme: green, rounded corners (borderRadius 12)
   - Custom InputDecoration theme: outlined style, green focus border
   - Custom Card theme: white surface, elevation 2, rounded corners 12
   - Custom TextTheme: use Roboto font family

4. `lib/core/utils/formatters.dart`
   - formatEtb(double amount): returns 'ETB 1,200.00' format
   - formatDate(DateTime date): returns 'Jan 08, 2026'
   - formatRelativeTime(DateTime date): returns '2 hours ago', '3 days ago', etc.
   - formatProgress(double raised, double goal): returns '65%' string
   - truncateText(String text, int maxLength): truncates with '...'

5. `lib/core/utils/validators.dart`
   - validateEmail(String? value): returns error string or null
   - validatePassword(String? value): min 6 chars
   - validatePhone(String? value): Ethiopian format +251xxxxxxxxx or 09xxxxxxxx
   - validateRequired(String? value, String fieldName): not empty check
   - validateAmount(String? value): positive decimal number
   - validateCampaignGoal(String? value): must be > 0
```

---

## 🔐 PHASE 2 — Network Layer & Authentication

### Prompt 2.1 — Dio HTTP client with JWT interceptor

```
Using the EthioFund Flutter project context, generate `lib/core/network/dio_client.dart`

Requirements:
- Create a DioClient class (singleton pattern using Riverpod provider)
- Initialize Dio with:
  - baseUrl: ApiConstants.baseUrl
  - connectTimeout: 30 seconds
  - receiveTimeout: 30 seconds
  - Headers: Content-Type: application/json

- Add a RequestInterceptor that:
  - Reads the JWT token from SecureStorage before every request
  - If token exists, adds Authorization: Bearer <token> header
  - Skips token for /auth/login and /auth/register endpoints

- Add a ResponseInterceptor that:
  - On 401 response: deletes token from SecureStorage, redirects to login
  - On any error: throws ApiException with the message from response body
    { "success": false, "message": "..." }

- Add a LogInterceptor in debug mode only

- Export a dioClientProvider using Riverpod Provider<DioClient>

Also generate `lib/core/network/api_exception.dart`:
- ApiException class extends Exception
- Fields: message (String), statusCode (int?)
- Factory constructor: ApiException.fromDioError(DioException e)
  - Handle: DioExceptionType.connectionTimeout → 'Connection timeout'
  - Handle: DioExceptionType.receiveTimeout → 'Server not responding'
  - Handle: DioExceptionType.badResponse → extract message from response.data
  - Handle: DioExceptionType.connectionError → 'No internet connection'
  - Fallback: 'Something went wrong'
```

---

### Prompt 2.2 — Secure storage wrapper

```
Using the EthioFund Flutter project context, generate `lib/core/storage/secure_storage.dart`

Create a SecureStorage class with:
- Private FlutterSecureStorage instance
- Static keys:
  static const String _tokenKey = 'ethiofund_jwt_token';
  static const String _userKey = 'ethiofund_user_data';
  static const String _roleKey = 'ethiofund_user_role';

- Async methods:
  Future<void> saveToken(String token)
  Future<String?> getToken()
  Future<void> deleteToken()
  Future<void> saveUser(String userJson)  ← saves JSON string
  Future<String?> getUser()
  Future<void> saveRole(String role)
  Future<String?> getRole()
  Future<void> clearAll()  ← called on logout

- Export a secureStorageProvider using Riverpod Provider<SecureStorage>
```

---

### Prompt 2.3 — Data models

```
Using the EthioFund Flutter project context, generate all model files.
Every model must:
- Have a const constructor
- Implement fromJson(Map<String, dynamic> json) factory
- Implement toJson() → Map<String, dynamic>
- Use copyWith() method
- Handle null values safely

Generate these models:

`lib/models/user_model.dart`
Fields: userId (int), fullName (String), email (String),
phoneNumber (String?), role (String), status (String)
JSON key mapping: user_id → userId, full_name → fullName, etc.

`lib/models/campaign_model.dart`
Fields: campaignId (int), title (String), description (String),
goalAmount (double), raisedAmount (double), status (String),
category (String), organizerId (int), organizerName (String?),
createdAt (DateTime)
Add computed getter: double get progressPercentage => raisedAmount / goalAmount
Add computed getter: bool get isActive => status == 'active' || status == 'approved'

`lib/models/campaign_update_model.dart`
Fields: updateId (int), campaignId (int), content (String), postedAt (DateTime)

`lib/models/donation_model.dart`
Fields: donationId (int), amount (double), donationDate (DateTime),
paymentStatus (String), isAnonymous (bool), donorId (int),
campaignId (int), campaignTitle (String?)

`lib/models/comment_model.dart`
Fields: commentId (int), content (String), userId (int),
campaignId (int), createdAt (DateTime), fullName (String?)

`lib/models/withdrawal_model.dart`
Fields: withdrawalId (int), amount (double), status (String),
bankAccount (String?), requestDate (DateTime),
campaignId (int), campaignTitle (String?)

`lib/models/dashboard_stats_model.dart`
Fields: totalUsers (int), totalCampaigns (int), totalDonations (int),
totalRaised (double), pendingCampaigns (int), pendingWithdrawals (int)
```

---

### Prompt 2.4 — Auth service and provider

```
Using the EthioFund Flutter project context, generate the auth layer:

`lib/services/auth_service.dart`
- Takes DioClient as dependency (injected via constructor or Riverpod)
- Methods:
  Future<Map<String, dynamic>> login(String email, String password)
    → POST /auth/login
    → Returns { token: String, user: UserModel }
    → Throws ApiException on failure

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,  // 'donor' or 'organizer'
  })
    → POST /auth/register
    → Returns UserModel
    → Throws ApiException on failure

  Future<void> logout()
    → POST /auth/logout
    → Then calls SecureStorage.clearAll()

`lib/providers/auth_provider.dart`
- Define AuthState class with:
  isAuthenticated (bool), user (UserModel?), isLoading (bool), error (String?)

- Create AuthNotifier extends AsyncNotifier<AuthState>:
  - On build(): check SecureStorage for existing token + user
    If token exists: restore state as authenticated
    If not: state is unauthenticated
  
  - login(email, password):
    Set loading state
    Call authService.login
    Save token and user to SecureStorage
    Update state to authenticated
    Handle errors

  - register(fullName, email, phone, password, role):
    Call authService.register
    Auto-login after registration

  - logout():
    Call authService.logout
    Clear SecureStorage
    Set state to unauthenticated

- Export authNotifierProvider using AsyncNotifierProvider<AuthNotifier, AuthState>
- Export convenience providers:
  currentUserProvider → reads user from authNotifierProvider
  isAuthenticatedProvider → reads isAuthenticated bool
  userRoleProvider → returns role string or 'guest'
```

---

## 🗺️ PHASE 3 — Navigation & Routing

### Prompt 3.1 — GoRouter with role-based guards

```
Using the EthioFund Flutter project context, generate `lib/core/router/app_router.dart`

Requirements:
- Use go_router package
- Export a goRouterProvider using Riverpod Provider<GoRouter>
- The router must watch authNotifierProvider and redirect based on auth state

Define these named routes:
'/splash'           → SplashScreen
'/onboarding'       → OnboardingScreen
'/login'            → LoginScreen
'/register'         → RegisterScreen
'/home'             → HomeScreen (public campaign feed)
'/campaigns/:id'    → CampaignDetailScreen (public)
'/campaigns/create' → CreateCampaignScreen (organizer only)
'/campaigns/:id/edit' → EditCampaignScreen (organizer only)
'/my-campaigns'     → MyCampaignsScreen (organizer only)
'/donate/:id'       → DonateScreen (donor only)
'/payment'          → PaymentWebViewScreen (donor only)
'/payment/success'  → PaymentSuccessScreen
'/payment/failed'   → PaymentFailedScreen
'/my-donations'     → MyDonationsScreen (donor only)
'/withdrawals/request/:id' → RequestWithdrawalScreen (organizer)
'/my-withdrawals'   → MyWithdrawalsScreen (organizer)
'/profile'          → ProfileScreen (authenticated)
'/admin'            → AdminDashboardScreen (admin only)
'/admin/campaigns'  → AdminCampaignsScreen (admin only)
'/admin/users'      → AdminUsersScreen (admin only)
'/admin/withdrawals' → AdminWithdrawalsScreen (admin only)
'/admin/reports'    → AdminReportsScreen (admin only)
'/unauthorized'     → Simple screen showing "Access Denied"

Redirect logic:
- If unauthenticated and trying to access protected route → /login
- If authenticated and trying to access /login or /register → /home
- If role is 'donor' and trying to access organizer/admin routes → /unauthorized
- If role is 'organizer' and trying to access admin routes → /unauthorized
- Admin can access all routes

Use ShellRoute for the bottom navigation shell (home, profile, and role-specific tabs).
For admin users, the bottom nav shows: Dashboard, Campaigns, Users, Reports.
For organizers: Home, My Campaigns, Withdrawals, Profile.
For donors: Home, My Donations, Profile.
For guests: Home, Login.
```

---

## 🏠 PHASE 4 — Home Screen & Campaign Feed

### Prompt 4.1 — Campaign service and provider

```
Using the EthioFund Flutter project context, generate the campaigns layer:

`lib/services/campaign_service.dart`
- Takes DioClient as dependency
- Methods:
  Future<List<CampaignModel>> getCampaigns() → GET /campaigns
  Future<CampaignModel> getCampaignById(int id) → GET /campaigns/:id
  Future<CampaignModel> createCampaign({
    required String title,
    required String description,
    required double goalAmount,
    required String category,
  }) → POST /campaigns
  Future<CampaignModel> updateCampaign(int id, Map<String, dynamic> data)
  Future<List<CampaignUpdateModel>> getCampaignUpdates(int id)
  Future<CampaignUpdateModel> postCampaignUpdate(int id, String content)
  Future<void> approveCampaign(int id) → PATCH /campaigns/:id/approve
  Future<void> rejectCampaign(int id) → PATCH /campaigns/:id/reject

`lib/providers/campaign_provider.dart`
- campaignsProvider: AsyncNotifierProvider returning List<CampaignModel>
  - Loads all approved campaigns on build
  - refresh() method to reload

- campaignDetailProvider(int id): AsyncNotifierProvider for single campaign
  - Also loads updates for this campaign

- filteredCampaignsProvider(String category): derived provider
  - Filters campaignsProvider by category
  - 'all' category returns everything

- myCampaignsProvider: for organizer's own campaigns (filtered by organizerId)
```

---

### Prompt 4.2 — Home screen and campaign card UI

```
Using the EthioFund Flutter project context, generate the home screen UI files.

`lib/features/home/home_screen.dart`
- Scaffold with EthioFundAppBar showing "EthioFund" title + search icon
- Body: Column with:
  1. Category filter chips (horizontal scroll): 
     All, Medical, Education, Funeral, Emergency, Community
     Active chip uses AppColors.primary background
  2. When category selected, show filteredCampaignsProvider
  3. RefreshIndicator wrapping ListView.builder of campaign cards
  4. Show LoadingWidget while loading
  5. Show ErrorWidget with retry button on error
  6. Show EmptyStateWidget if no campaigns

`lib/features/home/widgets/campaign_card.dart`
- Material Card with rounded corners (borderRadius 12)
- Layout:
  - Campaign image (use a placeholder green container if no image)
  - Category badge chip (color coded: medical=red, education=blue, etc.)
  - Campaign title (bold, 16sp, max 2 lines overflow ellipsis)
  - Description (14sp, grey, max 2 lines)
  - Progress bar (CampaignProgressBar widget)
  - Row: "ETB X raised" + "X% of goal"
  - Row: Organizer name + days remaining or "Completed"
- On tap: navigate to /campaigns/:id using GoRouter

`lib/features/home/widgets/category_filter.dart`
- Horizontal ListView of FilterChip widgets
- Props: List<String> categories, String selected, Function(String) onSelected
- Selected chip: AppColors.primary fill, white text
- Unselected chip: white fill, grey border

`lib/features/campaign/widgets/campaign_progress_bar.dart`
- Props: double raised, double goal
- Show LinearProgressIndicator with value = raised/goal (clamp 0.0 to 1.0)
- Color: AppColors.primary, backgroundColor: AppColors.background
- Below bar: Row with "ETB X,XXX raised" (left) and "X% of ETB X,XXX goal" (right)
- Both in 12sp grey text
```

---

### Prompt 4.3 — Campaign detail screen

```
Using the EthioFund Flutter project context, generate `lib/features/campaign/campaign_detail_screen.dart`

This screen receives campaignId from GoRouter path parameter.
Uses campaignDetailProvider(campaignId) to load data.

Layout (CustomScrollView with Slivers):
1. SliverAppBar:
   - Expandable with campaign image (or green placeholder)
   - Back button
   - Share icon button (share campaign URL)
   - Floating action button: 
     * If donor: "Donate Now" → navigate to /donate/:id
     * If organizer (own campaign): "Post Update" 
     * If guest: "Login to Donate"
     * If admin: shows nothing

2. SliverToBoxAdapter with campaign info:
   - Category badge + status badge (color coded)
   - Campaign title (24sp bold)
   - By: organizer name + created date
   - CampaignProgressBar (large, prominent)
   - "ETB X,XXX raised of ETB X,XXX goal" in large text
   - Number of donors badge

3. SliverToBoxAdapter — Description section:
   - Section header "About this Campaign"
   - Full description text with "Show more / Show less" toggle

4. SliverToBoxAdapter — Campaign Updates section:
   - Section header "Updates (X)"
   - List of CampaignUpdateCard widgets
   - Empty state: "No updates yet"

5. SliverToBoxAdapter — Comments section:
   - Section header "Comments"
   - CommentList widget showing campaign comments
   - AddCommentBar at bottom (only for authenticated users)

6. SliverToBoxAdapter — Recent Donors section:
   - Section header "Recent Donors"
   - List of donor names and amounts (anonymous shows "Anonymous")
```

---

## 💰 PHASE 5 — Donation & Payment Flow

### Prompt 5.1 — Donation service and payment service

```
Using the EthioFund Flutter project context, generate donation and payment services:

`lib/services/donation_service.dart`
- Methods:
  Future<List<DonationModel>> getMyDonations() → GET /donations/my
  Future<List<DonationModel>> getCampaignDonations(int campaignId)
    → GET /donations/campaign/:id

`lib/services/payment_service.dart`
- Methods:
  Future<String> initializePayment({
    required int campaignId,
    required double amount,
    required bool isAnonymous,
  })
  → POST /payments/initialize
  → Returns the checkout_url string
  → Throws ApiException if campaign not found or not approved

`lib/providers/donation_provider.dart`
- myDonationsProvider: AsyncNotifierProvider<List<DonationModel>>
  - Loads on build for authenticated users
  - refresh() method

- campaignDonationsProvider(int campaignId): derived AsyncProvider
```

---

### Prompt 5.2 — Donate screen and payment WebView

```
Using the EthioFund Flutter project context, generate the full payment flow screens:

`lib/features/donation/donate_screen.dart`
- Route: /donate/:id (receives campaignId)
- Loads campaign data to show summary at top

Layout:
- AppBar: "Make a Donation"
- Campaign summary card: title, progress bar, raised/goal
- Form section:
  1. Amount input field:
     - TextFormField with ETB prefix text and number keyboard
     - Quick amount chips: ETB 50, ETB 100, ETB 200, ETB 500, ETB 1000
       Tapping a chip fills the amount field
     - Validator: must be positive number, minimum ETB 10
  2. Anonymous toggle:
     - SwitchListTile "Donate Anonymously"
     - Subtitle: "Your name will not be shown publicly"
  3. Note: "You will be redirected to Chapa's secure payment page"
- "Proceed to Payment" ElevatedButton (full width, green)
  - On press: validate form → call paymentService.initializePayment
  - Show CircularProgressIndicator while loading
  - On success: navigate to /payment with checkout_url as extra param
  - On error: show SnackBar with error message

`lib/features/donation/payment_webview_screen.dart`
- Route: /payment (receives checkout_url as GoRouter extra)
- Uses flutter_inappwebview InAppWebView

Layout:
- AppBar: "Secure Payment" + CircularProgressIndicator while page loads
- InAppWebView with:
  - initialUrlRequest: URLRequest(url: checkout_url)
  - onLoadStop: check if URL contains CLIENT_URL/payment/success or /payment/failed
    → If success URL detected: navigate to /payment/success (replace)
    → If failed URL detected: navigate to /payment/failed (replace)
  - onReceivedError: show error SnackBar
- Note: Chapa's return_url in the backend is set to CLIENT_URL/payment/success
  The WebView detects this redirect to close itself

`lib/features/donation/payment_success_screen.dart`
- Green success animation (use AnimatedContainer or Lottie if available)
- "Payment Successful!" heading
- "Your donation has been confirmed and the campaign has been updated."
- "View My Donations" button → /my-donations
- "Back to Campaigns" button → /home

`lib/features/donation/payment_failed_screen.dart`
- Red error icon
- "Payment Failed" heading
- "Your payment could not be processed. No money was charged."
- "Try Again" button → pops back to donate screen
- "Back to Campaigns" button → /home

`lib/features/donation/my_donations_screen.dart`
- AppBar: "My Donations"
- Uses myDonationsProvider
- ListView of donation cards showing:
  - Campaign title
  - Amount (bold green, "ETB X,XXX")
  - Date formatted with formatDate()
  - Payment status badge (successful=green, pending=orange, failed=red)
- Empty state: "You haven't made any donations yet. Browse campaigns to get started."
```

---

## 💬 PHASE 6 — Comments Module

### Prompt 6.1 — Comments UI and service

```
Using the EthioFund Flutter project context, generate the comments module:

`lib/services/comment_service.dart`
- addComment(int campaignId, String content) → POST /comments
- getComments(int campaignId) → GET /comments/campaign/:id
- Returns List<CommentModel>

`lib/features/comments/widgets/comment_list.dart`
- Props: int campaignId
- Uses commentProvider(campaignId) AsyncProvider
- ListView of comment items:
  - CircleAvatar with initials from fullName
  - fullName (bold 14sp) + relative time (grey 12sp) on same row
  - Comment content text (14sp)
  - Divider between comments
- Pull to refresh support

`lib/features/comments/widgets/add_comment_bar.dart`
- Props: int campaignId, VoidCallback onCommentAdded
- Only render if user is authenticated (watch isAuthenticatedProvider)
- Row with:
  - CircleAvatar (current user initials)
  - Expanded TextField: hint "Write a comment...", max lines 3
  - IconButton Send (AppColors.primary)
- On send: validate not empty → call commentService.addComment
  → Show loading on button → On success: clear field, call onCommentAdded
  → On error: show SnackBar
- Note: backend uses Google Gemini AI to moderate comments before showing
  Show a small info text: "Comments are reviewed before appearing publicly"
```

---

## 📣 PHASE 7 — Campaign Organizer Features

### Prompt 7.1 — Create and manage campaigns

```
Using the EthioFund Flutter project context, generate organizer-specific screens:

`lib/features/campaign/create_campaign_screen.dart`
- Route: /campaigns/create (organizer only — router guards this)
- AppBar: "Create Campaign"

Form with sections:
1. Basic Info:
   - Title field: TextFormField, required, max 150 chars, shows char count
   - Category dropdown: DropdownButtonFormField
     Options: Medical, Education, Funeral, Emergency, Community
   - Goal Amount: TextFormField with "ETB" prefix, number keyboard, required > 0

2. Campaign Description:
   - TextFormField multiline, min 5 lines, required, hint with guidance

3. Preview card (updates live as user types):
   - Small CampaignCard widget showing what the campaign will look like

4. Important notice box (amber background):
   "Your campaign will be reviewed by an admin before going public.
    This usually takes 24-48 hours."

- "Submit Campaign" ElevatedButton
  - On press: validate all fields → call campaignService.createCampaign
  - On success: show success dialog → navigate to /my-campaigns
  - On error: show SnackBar

`lib/features/campaign/my_campaigns_screen.dart`
- AppBar: "My Campaigns"
- Uses myCampaignsProvider (filtered to current organizer)
- Status filter tabs: All | Pending | Active | Closed
- For each campaign card, show additional organizer actions:
  - If pending: show "Awaiting Review" badge, no actions
  - If approved/active: "Post Update" button + "Request Withdrawal" button
  - If rejected: "View Reason" + "Edit & Resubmit" buttons
- FAB: "+" to create new campaign → /campaigns/create

`lib/features/campaign/edit_campaign_screen.dart`
- Pre-fills form with existing campaign data
- Same layout as create but title is "Edit Campaign"
- Note: only allowed for approved/active campaigns

Post Update bottom sheet (shown when "Post Update" tapped):
- BottomSheet with TextFormField (multiline)
- "Post Update" button → calls campaignService.postCampaignUpdate
- On success: refresh campaign detail, show success SnackBar
```

---

## 🏦 PHASE 8 — Withdrawal Module

### Prompt 8.1 — Withdrawal screens

```
Using the EthioFund Flutter project context, generate withdrawal screens:

`lib/services/withdrawal_service.dart`
- requestWithdrawal({ campaignId, amount, bankAccount }) → POST /withdrawals
- getMyWithdrawals() → GET /withdrawals/my
- Returns List<WithdrawalModel>

`lib/features/withdrawal/request_withdrawal_screen.dart`
- Route: /withdrawals/request/:id (receives campaignId)
- AppBar: "Request Withdrawal"
- Shows campaign summary: title, total raised, already withdrawn

Form:
- Amount field: max is campaign's available balance
  Show available balance: "Available: ETB X,XXX"
  Validator: must be <= available balance and > 0
- Bank Account / Mobile Money field:
  TextFormField with hint "CBE account or Telebirr number"
- Important notice (amber card):
  "Withdrawal requests are reviewed by admins before processing.
   Funds will be released to your account within 2-3 business days."
- "Submit Request" button

`lib/features/withdrawal/my_withdrawals_screen.dart`
- AppBar: "My Withdrawal Requests"
- Uses myWithdrawalsProvider
- List cards showing:
  - Campaign title
  - Amount requested (bold)
  - Bank account (last 4 digits only for privacy)
  - Status badge: Pending (orange), Approved (green), Rejected (red)
  - Request date
- Empty state message
```

---

## 👤 PHASE 9 — Profile Screen

### Prompt 9.1 — Profile screen

```
Using the EthioFund Flutter project context, generate `lib/features/profile/profile_screen.dart`

Layout:
- AppBar: "Profile"
- Header section:
  - Large CircleAvatar (80px) with user initials on green background
  - User's full name (20sp bold)
  - Email address (14sp grey)
  - Role badge chip (Donor / Organizer / Admin)

- Edit Profile section (Card):
  - Full Name TextFormField (pre-filled)
  - Phone Number TextFormField (pre-filled)
  - Email shown but NOT editable (grey disabled field with lock icon)
  - Note: "Email cannot be changed for security reasons"
  - "Save Changes" button

- Actions section (ListTiles):
  - If donor: "My Donations" → /my-donations
  - If organizer: "My Campaigns" → /my-campaigns
  - If organizer: "My Withdrawals" → /my-withdrawals
  - "Help & Support" (placeholder)
  - "About EthioFund" (placeholder)

- Danger zone:
  - "Logout" ListTile with red icon
    → Show confirmation AlertDialog
    → On confirm: call authNotifier.logout() → GoRouter redirects to /login
```

---

## 🛡️ PHASE 10 — Admin Panel

### Prompt 10.1 — Admin dashboard and campaign management

```
Using the EthioFund Flutter project context, generate admin screens:

`lib/features/admin/admin_dashboard_screen.dart`
- AppBar: "Admin Dashboard"
- Uses adminService.getDashboard() → GET /admin/dashboard
- Grid of stat cards (2 columns):
  - Total Users (blue icon)
  - Total Campaigns (green icon)
  - Total Donations (purple icon)
  - Total Raised in ETB (gold icon)
  - Pending Campaigns (orange icon — tap to go to /admin/campaigns)
  - Pending Withdrawals (red icon — tap to go to /admin/withdrawals)
- Recent Activity section:
  - List of last 10 activity log entries
  - Shows: action text + timestamp
  - Icon based on action type

`lib/features/admin/admin_campaigns_screen.dart`
- AppBar: "Campaign Management"
- Status filter tabs: All | Pending | Approved | Active | Rejected | Suspended
- Default to "Pending" tab
- Campaign cards with admin action buttons:
  - For pending: "Approve" (green) + "Reject" (red) buttons
  - For approved/active: "Suspend" button
  - For any: tap card to view full campaign detail
- Confirm dialog before approve/reject/suspend
  - Rejection dialog asks for reason (optional text field)
- Pull to refresh

`lib/features/admin/admin_users_screen.dart`
- AppBar: "User Management"
- Search bar to filter by name or email
- User list cards showing:
  - Avatar with initials
  - Full name + email
  - Role badge + status badge
  - For active users: "Suspend" action (swipe or button)
  - For suspended users: "Activate" action
- Confirm dialog before suspend/activate

`lib/features/admin/admin_withdrawals_screen.dart`
- AppBar: "Withdrawal Requests"
- Filter tabs: Pending | Approved | Rejected
- Withdrawal cards showing:
  - Campaign title
  - Organizer name
  - Amount requested
  - Bank account
  - Request date
  - For pending: "Approve" + "Reject" buttons
- Confirm dialog for both actions

`lib/features/admin/admin_reports_screen.dart`
- AppBar: "Reports"
- Four report type buttons as large cards with icons:
  1. Campaign Report (bar chart icon)
  2. Donation Report (money icon)
  3. User Report (people icon)
  4. Financial Report (analytics icon)
- On tap: fetch that report type and show in a bottom sheet or new screen
- Each report screen shows the data in Card widgets with clear labels
- Financial report shows total raised, total withdrawn, pending amount
- All amounts formatted with formatEtb()
```

---

## 🧩 PHASE 11 — Shared Widgets

### Prompt 11.1 — Reusable UI components

```
Using the EthioFund Flutter project context, generate all shared widget files:

`lib/shared/widgets/primary_button.dart`
- PrimaryButton StatelessWidget
- Props: String label, VoidCallback? onPressed, bool isLoading (default false)
- Full width ElevatedButton with green background
- When isLoading: show CircularProgressIndicator (white, size 20) instead of label
- Disabled when onPressed is null or isLoading is true
- BorderRadius: 12, height: 52

`lib/shared/widgets/loading_widget.dart`
- Centered Column: CircularProgressIndicator (AppColors.primary) + "Loading..." text
- Props: String? message (optional custom message)

`lib/shared/widgets/error_widget.dart` (name it AppErrorWidget to avoid conflict)
- Centered Column: error icon (red) + message text + optional retry button
- Props: String message, VoidCallback? onRetry

`lib/shared/widgets/empty_state_widget.dart`
- Centered Column: large icon + title + subtitle + optional action button
- Props: IconData icon, String title, String subtitle, String? actionLabel, VoidCallback? onAction
- Uses AppColors.textSecondary for text

`lib/shared/widgets/ethiofund_app_bar.dart`
- Custom AppBar with EthioFund branding
- Props: String title, List<Widget>? actions, bool showBackButton
- Green background, white text
- EthioFund logo or "EF" text badge on left if no back button

`lib/shared/widgets/status_badge.dart`
- Small Container widget showing campaign/withdrawal status
- Props: String status
- Color mapping:
  pending → orange background
  approved | active → green background
  rejected | suspended → red background
  closed → grey background
- White text, borderRadius 20, horizontal padding 8
```

---

## 🌀 PHASE 12 — Splash & Onboarding

### Prompt 12.1 — Splash and onboarding screens

```
Using the EthioFund Flutter project context, generate:

`lib/features/splash/splash_screen.dart`
- Full screen with AppColors.primary background
- Centered content: EF logo (large Text widget styled as logo) + "EthioFund" text
- Subtitle: "Crowdfunding for Ethiopia"
- On initState: wait 2 seconds → check auth state
  → If authenticated: navigate to /home
  → If not: check if first launch (SharedPreferences key 'onboarding_shown')
    → First launch: navigate to /onboarding
    → Returning user: navigate to /login

`lib/features/onboarding/onboarding_screen.dart`
- PageView with 3 onboarding pages:
  Page 1:
    - Icon: campaign/megaphone
    - Title: "Start a Campaign"
    - Body: "Create fundraising campaigns for medical emergencies, education, and more. Your cause reaches donors in Ethiopia and the diaspora."

  Page 2:
    - Icon: heart/donate
    - Title: "Support Others"
    - Body: "Browse verified campaigns and donate securely using Telebirr, CBE Birr, and other local payment methods through Chapa."

  Page 3:
    - Icon: shield/verified
    - Title: "Transparent & Trusted"
    - Body: "Every campaign is admin-verified. Track donations in real time and know your money reaches those who need it."

- Bottom row:
  - Page indicator dots
  - Skip button (first two pages only)
  - Next/Get Started button
- On Get Started: set 'onboarding_shown' true in SharedPreferences → navigate to /register
```

---

## 🔐 PHASE 13 — Auth Screens

### Prompt 13.1 — Login and register screens

```
Using the EthioFund Flutter project context, generate auth screens:

`lib/features/auth/login_screen.dart`
- No AppBar (full screen design)
- SafeArea Column:
  - EthioFund logo/header (green, 80px top padding)
  - "Welcome Back" title (24sp bold)
  - "Sign in to continue" subtitle (grey)
  - Form:
    - Email TextFormField: email keyboard, validator: validateEmail
    - Password TextFormField: obscured, toggle visibility icon button
    - validator: validatePassword
  - "Forgot Password?" text button (right aligned, placeholder)
  - "Sign In" PrimaryButton
    → calls authNotifier.login(email, password)
    → Shows loading state on button
    → On success: GoRouter redirects based on role
    → On error: shows SnackBar with error message
  - Divider with "OR"
  - "Don't have an account? Register" TextButton → /register

`lib/features/auth/register_screen.dart`
- AppBar: "Create Account" (back button goes to /login)
- SingleChildScrollView Form:
  - "Join EthioFund" heading
  - Full Name field: validateRequired
  - Email field: validateEmail
  - Phone Number field: validatePhone (Ethiopian format)
  - Password field: obscured, toggle visibility, validatePassword
  - Confirm Password field: validator checks == password field
  - Role selector (SegmentedButton or two toggle cards):
    - "I want to Donate" → role: donor
    - "I want to Fundraise" → role: organizer
    - Each option shows an icon and short description
    - Selected option gets green border
  - Register PrimaryButton → calls authNotifier.register(...)
  - "Already have an account? Sign In" → /login
```

---

## ✅ PHASE 14 — Final Integration & Polish

### Prompt 14.1 — App entry point and final wiring

```
Using the EthioFund Flutter project context, generate the final wiring files:

`lib/main.dart`
- void main() with WidgetsFlutterBinding.ensureInitialized()
- Set preferred orientations to portrait only
- Wrap with ProviderScope (Riverpod)
- runApp(const EthioFundApp())

`lib/app.dart`
- EthioFundApp StatelessWidget (ConsumerWidget)
- MaterialApp.router with:
  - routerConfig: goRouterProvider (from Riverpod ref)
  - theme: AppTheme.lightTheme
  - title: 'EthioFund'
  - debugShowCheckedModeBanner: false
  - locale: const Locale('en', 'ET')
  - supportedLocales: [Locale('en', 'ET')]

`lib/shared/extensions/context_extensions.dart`
- Extension on BuildContext:
  - ThemeData get theme → Theme.of(this)
  - ColorScheme get colors → Theme.of(this).colorScheme
  - TextTheme get textTheme → Theme.of(this).textTheme
  - bool get isAdmin → reads userRoleProvider == 'admin'
  - bool get isOrganizer → reads userRoleProvider == 'organizer'
  - bool get isDonor → reads userRoleProvider == 'donor'
  - void showSnackBar(String message, {bool isError = false})
  - void showSuccessSnackBar(String message)

Also generate `android/app/src/main/AndroidManifest.xml` additions:
- Add INTERNET permission
- Add android:usesCleartextTraffic="true" for development HTTP
```

---

### Prompt 14.2 — Final audit and fixes

```
Review the complete EthioFund Flutter app I have built.

Check for and fix these common issues:

1. All GoRouter navigation uses context.go() or context.push() not Navigator.push
2. All Riverpod providers are read with ref.watch (for UI) and ref.read (for actions)
3. No direct BuildContext used across async gaps — use mounted checks
4. All API calls are in Service classes, not in UI widgets or providers directly
5. JWT token attached to every protected API call via Dio interceptor
6. All TextFormField validators match the validators.dart helpers
7. All ETB amounts use formatEtb() from formatters.dart
8. All DateTime values use formatDate() or formatRelativeTime()
9. The payment WebView correctly detects the return URL and navigates
10. The CampaignProgressBar clamps value between 0.0 and 1.0 to avoid overflow
11. Images use errorBuilder to show placeholder on load failure
12. All screens have proper loading and error states using Riverpod AsyncValue
13. Riverpod AsyncValue.when() used consistently in all Consumer widgets

Then generate `README.md` for the Flutter project that includes:
- Prerequisites (Flutter SDK version, Android SDK)
- Backend setup requirement
- How to run on emulator and physical device
- How to change the API base URL for physical device
- Environment variables needed (backend URL, no secrets in Flutter)
- App features by role summary table
```

---

## 📝 Quick Inline Copilot Snippets

> Paste these into **inline chat** (`Ctrl+I`) while your cursor is inside a specific file.

### Convert any Widget to ConsumerWidget for Riverpod:
```
Convert this StatelessWidget to a ConsumerWidget for Riverpod.
Add WidgetRef ref parameter to build method.
Use ref.watch for reactive state and ref.read inside callbacks.
```

### Add AsyncValue loading/error/data handling:
```
Wrap this widget body with proper Riverpod AsyncValue.when() handling.
Show LoadingWidget for loading state.
Show AppErrorWidget with retry callback for error state.
Show the actual data widget for data state.
```

### Add pull-to-refresh to a list screen:
```
Add RefreshIndicator to this screen's ListView.
On refresh: call ref.refresh() on the relevant provider.
Show CircularProgressIndicator only on first load, not on refresh.
```

### Fix GoRouter navigation in a callback:
```
Replace any Navigator.push/pop calls in this file with GoRouter equivalents.
Use context.go() for replace navigation and context.push() for stack navigation.
For named routes use context.goNamed() with proper params map.
```

### Add form validation to a screen:
```
Add a GlobalKey<FormState> to this screen.
Wrap all TextFormField widgets in a Form widget.
Add validator to each field using validators.dart helpers.
Call formKey.currentState!.validate() before the submit action.
```

### Add empty state and error state to a list:
```
Wrap this list widget in an AsyncValue.when() block.
Add EmptyStateWidget when data list is empty.
Add AppErrorWidget with onRetry when error occurs.
Add LoadingWidget centered when loading.
```
