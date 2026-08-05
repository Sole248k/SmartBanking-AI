# SmartBank AI - Premium Fintech Application

A production-ready, scalable, and maintainable Flutter banking application featuring an integrated AI financial assistant.

## 🚀 Key Features

- **Clean Architecture:** Strict separation of concern with Data, Domain, and Presentation layers.
- **Premium UI/UX:** Material 3 design, glassmorphism effects, and smooth animations.
- **AI Assistant:** Context-aware, streaming AI chat for financial insights.
- **Core Banking:** Multi-account management, Transfers, QR Payments, and Digital Wallet.
- **Analytics & Budgeting:** Visual spending reports using `fl_chart` and real-time budget tracking.
- **Reactive State:** Powered by Riverpod 2.x with code generation.

---

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Dart SDK 3.0+
- Android Studio / VS Code
- **Developer Mode:** If running on Windows/Android, ensure Developer Mode is enabled.

### Installation

1. **Clone the repository** (if applicable)
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Generate required code:**
   The project uses `freezed`, `riverpod_generator`, and `json_serializable`. You MUST run this command before building:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

## 🧪 Testing

### Running Unit Tests
We have implemented core logic tests for Auth and Budgeting modules.
```bash
flutter test
```

### Manual Testing Flow
1. **Login:** Use `test@smartbank.ai` / `password`.
2. **Dashboard:** Explore balances and pull-to-refresh.
3. **Transfer:** Click "Send" to try the multi-step transfer flow.
4. **QR:** Try "Scan to Pay" (simulated via mock) or view "My QR".
5. **Analytics:** View your spending charts in the bottom navigation.
6. **AI Assistant:** Tap the FAB (✨) and ask "What is my balance?".

---

## 🏗️ Architecture

The project follows **Feature-First Clean Architecture**:

```
lib/
├── app/          # Global configuration (Router, Theme, Constants)
├── core/         # Shared services, error handling, and utilities
├── features/     # Business logic modules
│   ├── auth/     # Login & Session management
│   ├── dashboard/# Home overview & Transactions
│   ├── transfer/ # Money movement flow
│   ├── qr/       # QR Scanning & Generation
│   ├── wallet/   # Digital wallet management
│   ├── analytics/# Charts & Reports
│   ├── ai_assistant/ # LLM Chat interface
│   └── profile/  # User settings & Security
└── shared/       # Reusable domain models and widgets
```

---

## 🛠️ Implementation Details

- **State Management:** Riverpod 2.x (AsyncNotifier)
- **Navigation:** GoRouter (Declarative routing)
- **Networking:** Dio (Mocked initially)
- **Local Storage:** Hive & Flutter Secure Storage
- **Charts:** fl_chart
- **Scanner:** mobile_scanner

---

## 📝 Roadmap & Status

- [x] Phase 1: Core Foundation
- [x] Phase 2: Design System
- [x] Phase 3: Dashboard & Transactions
- [x] Phase 4: Banking & Transfers
- [x] Phase 5: QR & Wallet
- [x] Phase 6: Budgeting & Analytics
- [x] Phase 7: AI Assistant
- [x] Phase 8: Production Readiness

---
*Built with ❤️ by the SmartBank AI Engineering Team.*
