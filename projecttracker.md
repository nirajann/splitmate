# SplitMate Project Tracker

## Core App Vision

SplitMate is a Flutter mobile app where users can create an account, create expense lobbies/groups, invite people, add shared expenses, and clearly see who owes money and who is owed money in a simple and fun way.

## Main Features — Do Not Change

1. Splash screen with automatic login check using SharedPreferences.
2. Login screen.
3. Signup screen.
4. Home/dashboard screen.
5. Lobby/group creation screen.
6. Lobby/group detail screen with expenses and members.
7. Invite people to join a lobby.
8. Add shared expenses.
9. Show balances clearly: you owe / you are owed.
10. Search and filter expenses easily.
11. Use dummy data first, then connect to backend/database later.
12. Keep the app clean, modern, smooth, and mobile-friendly.

## Database Direction

Recommended future database: Firebase first for fast launch.

Firebase services planned later:

* Firebase Authentication for login/signup.
* Cloud Firestore for users, lobbies, members, expenses, splits, and settlements.
* Firebase Storage later if profile images or receipt uploads are added.
* Firebase Cloud Messaging later for notifications.

## Current Development Strategy

Phase 1: Build Flutter UI with dummy models and dummy data.
Phase 2: Add SharedPreferences login persistence.
Phase 3: Add navigation between screens.
Phase 4: Connect Firebase Authentication.
Phase 5: Connect Firestore database.
Phase 6: Add real balance calculation and settlement logic.

## Screens To Build First

1. SplashScreen
2. LoginScreen
3. SignupScreen
4. HomeScreen
5. LobbiesScreen
6. CreateLobbyScreen
7. LobbyDetailScreen

## Current Progress History

### Step 1

Created premium SplitMate home UI direction inspired by the orange gradient Splitwise-style design.

### Step 2

Decided to build with Flutter mobile first.

### Step 3

Decided to use dummy data and clean models first so Firebase can be connected later without changing the main app structure.

### Step 4

Confirmed important product foundations before coding:

* Flexible expense split model
* Activity log for trust and safety
* Lobby/group invite flow
* Search/filter support
* Future Firebase connection
* Future simplify-debt and settlement system

### Step 5

Created Firebase-ready model structure and dummy data plan:

* AppUser
* Lobby
* Expense
* ExpenseSplit
* ActivityLog

### Step 6

Added SharedPreferences auth flow plan:

* Splash screen
* Login screen
* Signup screen
* Automatic login check

### Step 7

Started UI polish target: HomeScreen, BalanceBox, BillCard, FriendCard should match the prototype closely with floating pill navigation, compact bill cards, rounded white panels, and real dummy data connected through shared app state.

### Step 8

Moving to AppState foundation so all screens use real dummy data and calculated balances instead of hardcoded values.

### Step 9

Current visible progress before stopping today:

* MainShell bottom navigation is working as fixed placeholder navigation.
* Lobbies tab shows current dummy lobbies from app data.
* Activity, Add Expense, and Profile are still placeholder screens.
* Next focus is to make lobby card tap open a detailed lobby view inside the same MainShell-style flow and polish the remaining prototype screens.

## Next Task

Create Flutter model files and dummy data:

* app_user.dart
* lobby.dart
* expense.dart
* expense_split.dart
* activity_log.dart
* dummy_data.dart

These files will be Firebase-ready using id fields, DateTime fields, toMap(), and fromMap().
