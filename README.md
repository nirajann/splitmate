# SplitMate

SplitMate is a Flutter mobile app for splitting shared expenses with friends, roommates, travel groups, and event groups. Users can create lobbies, add members, record shared expenses, split bills equally or custom-wise, and clearly see who owes whom.

The project currently uses local dummy/in-memory data for fast MVP development. It is structured to be Firebase-ready for authentication, real-time database sync, invite links, and profile images in the next phase.

---

## Features

### Core Features

- Splash screen with login check foundation
- Login and signup screens
- Main bottom navigation shell
- Home dashboard with balances and pending expenses
- Create expense lobbies/groups
- Add members to a lobby
- Remove members safely if they have no unpaid balance
- Add shared expenses
- Equal split support
- Custom split support
- Net balance calculation
- Simplified “who owes whom” calculation
- Individual settlement support
- Activity history
- Profile and friends balance screen
- Clean prototype-inspired UI

---

## Main Screens

- **Splash Screen**
- **Login Screen**
- **Signup Screen**
- **Home Screen**
- **Lobbies / Groups Screen**
- **Create Lobby Screen**
- **Lobby Detail Screen**
- **Add Expense Screen**
- **Activity Screen**
- **Profile Screen**

---

## Current Tech Stack

- Flutter
- Dart
- Provider for state management
- SharedPreferences foundation for authentication persistence
- Local dummy data / in-memory app state
- Firebase-ready model structure with `toMap()` and `fromMap()`

---

## Project Structure

```text
lib/
├── data/
│   └── dummy_data.dart
├── models/
│   ├── activity_log.dart
│   ├── app_user.dart
│   ├── expense.dart
│   ├── expense_split.dart
│   └── lobby.dart
├── screens/
│   ├── activity_screen.dart
│   ├── add_expense_screen.dart
│   ├── create_lobby_screen.dart
│   ├── home_screen.dart
│   ├── lobbies_screen.dart
│   ├── lobby_detail_screen.dart
│   ├── login_screen.dart
│   ├── main_shell.dart
│   ├── profile_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
├── services/
│   └── auth_service.dart
├── state/
│   └── app_state.dart
├── theme/
│   └── app_colors.dart
├── widgets/
│   ├── app_avatar.dart
│   ├── avatar_stack.dart
│   ├── balance_box.dart
│   ├── bill_card.dart
│   ├── category_bubble.dart
│   ├── friend_card.dart
│   └── status_pill.dart
└── main.dart
