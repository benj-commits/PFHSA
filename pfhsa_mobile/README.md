# PFHSA Mobile — Flutter App

Flutter client for the Personal Financial Health and Spending Analyzer, built against
the `pfhsa-backend` API (auth, income/expenses, budgets, goals, health score).

## Design

A "financial ledger" identity rather than a generic finance-app template:
- **Palette:** pine green (positive/on-track), brass (goals/highlights), clay (warnings), deep ink on warm paper — full dark-mode variants defined in `lib/config/theme.dart`
- **Type:** Fraunces (serif display, for headlines and the score) + Inter (body) + IBM Plex Mono (amounts, ledger-style)
- **Signature element:** a hand-drawn-dial-style health score gauge (`widgets/health_score_gauge.dart`), custom-painted rather than a stock progress ring — tick marks like a physical meter, arc color shifts with the rating
- **Sidebar:** persistent on every screen, including login/register (`widgets/app_sidebar.dart`) — collapses to an icon rail via the menu button at the top. Nav items, the mini profile, and logout only appear once authenticated.
- **Dark mode:** the pill switch in the sidebar toggles app-wide light/dark colors, driven by `config/theme_controller.dart`. Preference is remembered via `shared_preferences`.
- **Dashboard:** redesigned as a colorful card layout — a gradient greeting banner, a current-week day strip, and three colored stat chips (income/expenses/savings) above the health score gauge and category breakdown.

## Setup

1. **Install Flutter** (3.x): https://docs.flutter.dev/get-started/install

2. **Get dependencies:**
   ```bash
   cd pfhsa_mobile
   flutter pub get
   ```

3. **Point the app at your backend.** Edit `lib/config/api_config.dart`:
   - Android emulator: `http://10.0.2.2:5000/api` (already set)
   - iOS simulator: `http://localhost:5000/api`
   - Physical device: `http://<your-computer-LAN-IP>:5000/api`
   - Make sure the `pfhsa-backend` server is running first.

4. **Run:**
   ```bash
   flutter run
   ```

## Structure

```
lib/
├── config/
│   ├── api_config.dart      # backend base URL
│   ├── theme.dart            # colors (light/dark), typography, ThemeData
│   └── theme_controller.dart # singleton dark-mode toggle + persistence
├── models/                   # one file per API resource (mirrors backend schema)
├── services/api_service.dart # HTTP client, token storage (shared_preferences), error handling
├── providers/                 # ChangeNotifier state per resource, calls ApiService
│   ├── auth_provider.dart
│   ├── finance_provider.dart  # income + expenses + categories
│   ├── budget_provider.dart
│   ├── goal_provider.dart
│   └── dashboard_provider.dart
├── screens/
│   ├── root_shell.dart         # top-level: sidebar + auth flow / app views
│   ├── login_screen.dart / register_screen.dart  # embedded views, not routes
│   ├── dashboard_screen.dart   # gradient hero, week strip, colorful stat cards, health gauge
│   ├── transactions_screen.dart # tabbed income/expense ledger + add sheets
│   ├── budgets_screen.dart     # usage bars, add budget
│   ├── goals_screen.dart       # progress bars, contribute flow
│   └── profile_screen.dart
├── widgets/
│   ├── app_sidebar.dart        # persistent collapsible sidebar + dark mode toggle
│   ├── health_score_gauge.dart # signature custom-painted gauge
│   └── ledger_widgets.dart     # SectionCard, LedgerRow, LedgerDivider
└── main.dart                   # providers wiring + theme rebuild + RootShell
```

## Notes

- Auth token is stored via `shared_preferences` and auto-checked on launch (`_AuthGate` in `main.dart`).
- All amounts are shown unformatted for currency symbol (the backend proposal used UGX) —
  adjust `NumberFormat.currency` calls in the screens if you want a specific currency symbol.
- The dashboard, budgets, and dashboard's category breakdown currently default to the
  **current calendar month**, matching the backend's default date-range behavior.

## Next steps

- Add pull-to-refresh already wired on Dashboard; extend to Budgets/Goals/Ledger tabs
- Add category management screen (custom categories, matching `POST /api/categories`)
- Add report export (PDF/CSV) once the backend adds those endpoints
- Add charts (fl_chart is already a dependency) for spending trends over time
- Add form validation polish and offline handling
