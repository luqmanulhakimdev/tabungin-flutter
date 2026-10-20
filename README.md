# Tabungin — Personal Finance Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Test Coverage](https://img.shields.io/badge/Coverage-94.13%25-brightgreen)](file:///coverage/lcov.info)
[![Tests Passed](https://img.shields.io/badge/Tests-44%20Passed-success)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()

**Tabungin** is a modern, lightweight, and offline-first personal finance tracking mobile application built with **Flutter** and **Dart**. Designed with modern **Material Design 3** aesthetics, robust state management, and an enterprise-grade automated test suite boasting **94.13% code coverage**, Tabungin provides users with an intuitive, clutter-free way to record transactions, monitor cashflow health, and visualize monthly spending patterns.

---

## 📑 Table of Contents
- [Key Highlights](#-key-highlights)
- [UI/UX & Design System](#-uiux--design-system)
- [Feature Overview](#-feature-overview)
  - [1. Financial Dashboard](#1-financial-dashboard)
  - [2. Add & Edit Transactions](#2-add--edit-transactions)
  - [3. Transaction History & Filtering](#3-transaction-history--filtering)
  - [4. Financial Analytics & Statistics](#4-financial-analytics--statistics)
  - [5. Unified Navigation](#5-unified-navigation)
- [Architecture & Technical Decisions](#-architecture--technical-decisions)
- [Project Directory Structure](#-project-directory-structure)
- [Automated Testing & Coverage Report (94.13%)](#-automated-testing--coverage-report-9413)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Setup](#installation--setup)
  - [Running the Application](#running-the-application)
  - [Building Release APK](#building-release-apk)
- [Developer Guide](#-developer-guide)
  - [Extending Categories](#extending-categories)
  - [How State Management Works](#how-state-management-works)
- [Author & License](#-author--license)

---

## 🌟 Key Highlights

- **100% Offline-First Privacy**: Operates completely on-device without external server dependencies, authentication walls, or internet access requirements.
- **Accurate Mathematical Balance Engine**: Calculations are strictly derived from real persistent records rather than static placeholders:
  $$\text{Current Balance} = \text{Initial Balance} + \sum \text{Income} - \sum \text{Expenses}$$
- **Material Design 3 Craftsmanship**: Curated typography, emerald green gradients, rounded containers (16–24px), subtle drop shadows, and zero layout overflows across various screen sizes.
- **Indonesian Currency & Date Localization**: Preconfigured with standard Indonesian Rupiah currency formatting (`Rp1.250.000`) and localized date representations (`Selasa, 20 Oktober 2026`).
- **Clean Layered Architecture**: Strictly decouples UI widgets from business logic and storage abstractions, allowing seamless database migrations in future releases.
- **Battle-Tested Reliability**: Covered by 44 unit and widget tests achieving **94.13% line coverage** and zero lint warnings (`flutter analyze`).

---

## 🎨 UI/UX & Design System

The application's visual identity centers around **Emerald Green**, instilling trust, tranquility, and financial vitality.

| Color Name | Hex Code | Purpose & Usage |
| :--- | :--- | :--- |
| **Primary Emerald** | `#059669` | Brand color, primary buttons, active indicators |
| **Primary Light** | `#10B981` | Gradient accents and active hover states |
| **Mint Accent** | `#A7F3D0` | Subtle badge highlights and chips |
| **Primary Subtle** | `#ECFDF5` | Soft background for selected states and icons |
| **Income Emerald** | `#059669` | Positive cashflow representations (`+Rp...`) |
| **Expense Coral Red**| `#DC2626` | Negative cashflow representations (`-Rp...`) |
| **Background Slate** | `#F8FAFC` | Clean, glare-free scaffold background |
| **Text Slate Dark** | `#0F172A` | High-contrast, legible primary typography |
| **Text Slate Muted** | `#64748B` | Secondary details and metadata |

### Design Considerations:
- **Responsive Layouts**: Wrapped with dynamic viewports, `SingleChildScrollView`, and `Flexible`/`Expanded` flex trees to ensure zero layout clipping across compact Android smartphones and tablets.
- **Micro-Interactions**: Haptic-ready visual feedback, smooth transition states, animated bottom sheets, and explicit destructive action confirmations.

---

## 🚀 Feature Overview

### 1. Financial Dashboard
- **Dynamic Time Greeting**: Automatically detects device local time to present appropriate greetings (*Selamat Pagi*, *Selamat Siang*, *Selamat Sore*, *Selamat Malam*).
- **Emerald Gradient Balance Card**: High-visibility card highlighting current total balance alongside monthly income and monthly expense pills.
- **Adjust Initial Balance**: Interactive dialog allowing users to calibrate baseline savings without creating artificial income entries.
- **Real-Time Cashflow Monitor**: Automated card notifying whether the current monthly flow is running a **Surplus** or a **Deficit**.
- **Recent Activities**: Chronological list of the last 5 transactions with quick navigation to full history.
- **Engaging Empty State**: Meaningful call-to-action illustration when starting with a clean slate.

### 2. Add & Edit Transactions
- **Segmented Type Toggle**: Seamless switching between *Expense* (`Pengeluaran`) and *Income* (`Pemasukan`).
- **Real-Time Currency Formatter**: Auto-formats nominal inputs with Indonesian thousand separator dots (`.`) dynamically while typing (e.g. `100000` -> `100.000`) while preserving intuitive cursor position and backspace behavior.
- **Numerical Keyboard with Validation**: Real-time validation preventing negative, empty, or zero-value submissions.
- **Categorization Grid**: Quick visual selection with unique category iconography:
  - *Expense Categories*: Food & Beverage, Transportation, Shopping, Bills & Utilities, Entertainment, Healthcare, Education, Others.
  - *Income Categories*: Salary, Freelance, Business, Gift/Reward, Others.
- **Date Picker**: Intuitive Material 3 calendar modal for retroactive or forward-dated logging.
- **Optional Note Field**: Contextual remarks for personal records.

### 3. Transaction History & Filtering
- **Interactive Month Selector**: Browse any historic month via `<` `>` arrows or a modal month-picker sheet.
- **Type Filter Chips**: Filter view by *All*, *Income Only*, or *Expense Only*.
- **Transaction Details Bottom Sheet**: Inspect category, timestamp, notes, and exact amounts.
- **Safe Deletion Protocol**: Employs a dedicated confirmation dialog (`ConfirmDialog`) before removing records permanently.
- **Direct Edit Mode**: Pre-populates the transaction form for modifications.

### 4. Financial Analytics & Statistics
- **Monthly Metric Cards**: Summary of total monthly income, expenses, and net surplus/deficit.
- **Visual Cashflow Comparison Bar**: Dual-color proportional bar demonstrating the ratio of expenditure against revenue.
- **Category Spending Distribution**: Interactive progress bars demonstrating exact category amounts and relative percentage shares of the monthly total.

### 5. Unified Navigation
- **Material 3 Navigation Bar**: Quick switching across *Dashboard*, *Transactions*, and *Statistics*.
- **Floating Action Button (FAB)**: Prominent emerald action trigger for instant logging from any primary tab.

---

## 🏗️ Architecture & Technical Decisions

Tabungin follows a **Clean, Layered Architecture** pattern tailored for Flutter applications:

```mermaid
graph TD
    UI[Presentation Layer: Screens & Widgets] -->|Observes state & Dispatches actions| Provider[FinanceProvider: ChangeNotifier]
    Provider -->|Calculates financial logic| Models[Domain Models: Transaction, Category]
    Provider -->|Loads & Persists records| Service[StorageService: Local Storage Abstraction]
    Service -->|Serializes JSON string| SharedPrefs[(SharedPreferences / Native Storage)]
```

### Why `shared_preferences` for Local Persistence?
1. **Rock-Solid Stability**: Maintained directly by the official Flutter team (`flutter/packages`).
2. **Zero Native Build Failures**: Eliminates C++/NDK compilation bottlenecks common with SQLite or native libraries.
3. **JSON Serialization Mastery**: Provides an exemplary learning foundation for junior developers to master `toJson` and `fromJson` paradigms.
4. **Decoupled Architecture**: Because persistence is encapsulated inside `StorageService`, upgrading to SQLite, Hive, or a cloud backend requires zero modifications to UI screen widgets.

---

## 📂 Project Directory Structure

```text
lib/
├── main.dart                          # Application entry point & service initialization
├── app.dart                           # MaterialApp configuration & global theme binding
├── models/
│   ├── category_model.dart            # Category definitions, iconography, and color mapping
│   ├── transaction_model.dart         # Transaction entity with copyWith and JSON helpers
│   └── transaction_type.dart          # TransactionType enum (income/expense)
├── services/
│   └── storage_service.dart           # SharedPreferences persistence abstraction
├── providers/
│   └── finance_provider.dart          # Business logic, state reactivity, and financial calculations
├── theme/
│   ├── app_colors.dart                # Design tokens & semantic color constants
│   └── app_theme.dart                 # Material 3 ThemeData configuration
├── utils/
│   ├── currency_formatter.dart        # Indonesian Rupiah formatting & parsing utilities
│   └── date_formatter.dart            # Indonesian calendar dates and time greetings
├── widgets/
│   ├── balance_card.dart              # Gradient balance card with cashflow pills
│   ├── confirm_dialog.dart            # Reusable confirmation alert dialog
│   ├── empty_state_widget.dart        # Empty state component with action button
│   ├── month_selector_bar.dart        # Month navigation and bottom sheet picker
│   └── transaction_card.dart          # Transaction tile component with category badge
└── screens/
    ├── main_navigation_screen.dart    # Scaffold hosting NavigationBar & FAB
    ├── home/
    │   └── home_screen.dart           # Dashboard with greeting, cards, and recent list
    ├── transactions/
    │   ├── add_edit_transaction_screen.dart # Transaction form (create & update)
    │   └── transaction_list_screen.dart     # Transaction history and filter controls
    └── statistics/
        └── statistics_screen.dart     # Financial overview & category distribution
```

---

## 🧪 Automated Testing & Coverage Report (94.13%)

The test suite covers **44 rigorous test cases** across business logic, models, utility formatters, and widget interactions.

### Detailed Code Coverage Breakdown:

| Source File | Executable Lines | Covered Lines | Coverage Percentage | Status |
| :--- | :---: | :---: | :---: | :---: |
| `lib/models/category_model.dart` | 12 | 12 | **100.0%** | Passed ✅ |
| `lib/models/transaction_type.dart` | 14 | 14 | **100.0%** | Passed ✅ |
| `lib/models/transaction_model.dart` | 39 | 38 | **97.4%** | Passed ✅ |
| `lib/providers/finance_provider.dart` | 121 | 120 | **99.2%** | Passed ✅ |
| `lib/services/storage_service.dart` | 24 | 21 | **87.5%** | Passed ✅ |
| `lib/utils/currency_formatter.dart` | 53 | 52 | **98.1%** | Passed ✅ |
| `lib/utils/date_formatter.dart` | 24 | 23 | **95.8%** | Passed ✅ |
| `lib/widgets/balance_card.dart` | 84 | 84 | **100.0%** | Passed ✅ |
| `lib/widgets/confirm_dialog.dart` | 37 | 37 | **100.0%** | Passed ✅ |
| `lib/widgets/empty_state_widget.dart` | 20 | 20 | **100.0%** | Passed ✅ |
| `lib/widgets/month_selector_bar.dart` | 55 | 55 | **100.0%** | Passed ✅ |
| `lib/widgets/transaction_card.dart` | 44 | 44 | **100.0%** | Passed ✅ |
| `lib/screens/main_navigation_screen.dart` | 20 | 20 | **100.0%** | Passed ✅ |
| `lib/screens/statistics/statistics_screen.dart` | 173 | 166 | **96.0%** | Passed ✅ |
| `lib/screens/transactions/add_edit_transaction_screen.dart` | 160 | 147 | **91.9%** | Passed ✅ |
| `lib/screens/transactions/transaction_list_screen.dart` | 122 | 109 | **89.3%** | Passed ✅ |
| `lib/screens/home/home_screen.dart` | 166 | 139 | **83.7%** | Passed ✅ |
| `lib/theme/app_theme.dart` | 35 | 34 | **97.1%** | Passed ✅ |
| `lib/app.dart` | 4 | 3 | **75.0%** | Passed ✅ |
| **TOTAL SUITE** | **1207** | **1138** | **94.13%** | **Target Met (>80%)** 🏆 |

### Test Suites Included:
- **[`test/finance_provider_test.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/test/finance_provider_test.dart)**: Unit tests for baseline balance, transaction CRUD operations, month filtering, category breakdown aggregation, recent transaction cap, and corrupted storage recovery.
- **[`test/models_test.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/test/models_test.dart)**: Model serialization, `copyWith`, equality operators (`==`), and category fallback resolution.
- **[`test/formatter_test.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/test/formatter_test.dart)**: Indonesian Rupiah formatting/parsing, real-time input formatting, and calendar dates.
- **[`test/widgets_test.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/test/widgets_test.dart)**: Component tests for `TransactionCard`, `BalanceCard`, `ConfirmDialog`, `MonthSelectorBar`, and `EmptyStateWidget`.
- **[`test/screens_test.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/test/screens_test.dart)**: Integration widget tests for navigation, dialogs, form validation, filter chips, and bottom sheets.

---

## 💻 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.24.0` (Recommended: `3.47.7` stable)
- **Dart SDK**: `>= 3.5.0`
- **Android Studio / Android SDK**: API 34+ for emulator or physical device execution

### Installation & Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/luqmanulhakimdev/tabungin-flutter.git
   cd tabungin-flutter
   ```

2. Download all package dependencies:
   ```bash
   flutter pub get
   ```

3. Verify environment setup:
   ```bash
   flutter doctor
   ```

### Running the Application
Connect an Android device with USB Debugging enabled or launch an emulator:
```bash
# Check connected devices
flutter devices

# Run on your target device
flutter run
```

### Running Tests & Code Coverage
```bash
# Verify static code analysis (zero lint issues)
flutter analyze

# Execute all 44 test cases
flutter test

# Generate lcov coverage file
flutter test --coverage
```

### Building Release APK
To create a standalone Android installation file (`.apk`):
```bash
flutter build apk --release
```
The compiled artifact will be located at:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📖 Developer Guide

### Extending Categories
To add a new category (e.g., `Investments`), simply add an entry inside [`lib/models/category_model.dart`](file:///home/luqmanul/Codes/Flutter/Personal/tabungin-flutter/lib/models/category_model.dart):

```dart
CategoryModel(
  id: 'exp_investments',
  name: 'Investasi',
  type: TransactionType.expense,
  icon: Icons.trending_up_rounded,
  color: Color(0xFF10B981),
),
```
The new category will automatically propagate across the transaction form picker, history list tiles, and statistical charts without requiring manual database migrations.

### How State Management Works
`FinanceProvider` inherits from `ChangeNotifier`. When a user saves a transaction:
```dart
await provider.addTransaction(newTransaction);
```
Under the hood:
1. The transaction is appended to the internal memory list and re-sorted chronologically.
2. The dataset is asynchronously encoded into a JSON string and persisted to `SharedPreferences`.
3. `notifyListeners()` triggers an atomic re-render across all `Consumer<FinanceProvider>` widgets listening in the active widget tree.

---

## 👨‍💻 Author & License

Developed with ❤️ by **Luqmanul Hakim** as a showcase personal finance portfolio project.

This project is licensed under the [MIT License](LICENSE).
