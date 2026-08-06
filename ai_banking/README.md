# SmartBank AI — Next-Gen Digital Banking Platform

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.x-00599C?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green.style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-blue?style=for-the-badge)

> **SmartBank AI** is a enterprise-grade digital banking simulation built with **Flutter** and **Firebase**. It delivers a frictionless mobile and web banking experience paired with an integrated **AI Financial Assistant**, strict **KYC Gatekeeper Enforcement**, **Product Approval Workflows**, and a full-featured **Admin Portal**.

---

## 📋 Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Key Features](#2-key-features)
  - [🔒 Authentication & Security](#-authentication--security)
  - [📊 Customer Dashboard & Cards](#-customer-dashboard--cards)
  - [💸 Money Transfers & Payments](#-money-transfers--payments)
  - [🤖 AI Financial Assistant](#-ai-financial-assistant)
  - [🛡️ KYC Verification & Access Control](#️-kyc-verification--access-control)
  - [⚡ Product Applications & Management](#-product-applications--management)
  - [🏛️ Admin Portal & Compliance](#️-admin-portal--compliance)
- [3. Application Architecture](#3-application-architecture)
- [4. Technology Stack](#4-technology-stack)
- [5. Database Overview](#5-database-overview)
- [6. Project Structure](#6-project-structure)
- [7. Installation & Setup](#7-installation--setup)
- [8. Environment Configuration](#8-environment-configuration)
- [9. Running the Application](#9-running-the-application)
- [10. User Roles & Access Control](#10-user-roles--access-control)
- [11. Security Model](#11-security-model)
- [12. Banking Workflow](#12-banking-workflow)
- [13. Future Roadmap](#13-future-roadmap)
- [14. Screenshots](#14-screenshots)
- [15. Contributors](#15-contributors)
- [16. License](#16-license)
- [17. Acknowledgements](#17-acknowledgements)

---

## 1. Project Overview

**SmartBank AI** is designed to demonstrate how modern financial institutions deliver intelligent, secure, and compliance-driven digital services. Built using Flutter and Firebase, SmartBank AI simulates core retail banking functions while introducing automated governance and personalized AI guidance.

### Target Users:
- **Bank Customers**: Individuals seeking real-time account tracking, card management, instant transfers, and AI-driven spending advice.
- **Compliance & Operations Admins**: Authorized bank staff managing customer onboarding, KYC document reviews, and product application approvals.
- **Super Administrators**: Executive administrators with permissions to manage system access, assign admin roles, and inspect immutable audit logs.

### Key Objectives:
1. **Regulated Product Protection**: Enforce strict **KYC Gatekeeper** rules across frontend and backend services to block unverified users from applying for or activating regulated banking products.
2. **End-to-End Governance**: Provide administrators with a dedicated, isolated portal (`/admin`) featuring real-time queues for document review, application approvals, user searches, and security auditing.
3. **Smart Financial Insights**: Integrate an AI Assistant to help users query transactions, analyze budgets, and request savings recommendations naturally.

---

## 2. Key Features

### 🔒 Authentication & Security
- **Multi-Factor User Auth**: Firebase Email/Password login paired with session persistence and automatic token renewal.
- **6-Digit Transaction PIN**: Required for sensitive banking operations (transfers, card linking, profile updates).
- **Biometric Authentication**: Support for Face ID and Fingerprint login on supported mobile platforms.
- **Isolated Admin Auth**: Dedicated authentication flow (`/admin/login`) verifying claims against `admin_users` Firestore collections.

### 📊 Customer Dashboard & Cards
- **Account Carousel**: Dynamic card viewer displaying active Savings and Current Accounts with interactive card flip animations.
- **Real-Time Balances**: Toggle balance visibility for privacy with automatic synchronization across Riverpod providers.
- **Visa & Mastercard Auto-Detection**: Instant card network classification based on card prefix numbers.
- **Card Controls**: Freeze/unfreeze cards, manage daily transaction limits, and request replacement cards.

### 💸 Money Transfers & Payments
- **Multi-Destination Transfers**: Transfer between personal accounts, to external cards, or to other SmartBank users.
- **Beneficiary Management**: Save, edit, and organize frequently used payees for 1-tap transfers.
- **Instant Top-Up**: Fund accounts using demo deposits or linked payment methods.
- **Digital Receipts**: Auto-generated transaction receipts with unique reference IDs and shareable details.

### 🤖 AI Financial Assistant
- **Context-Aware Assistance**: Powered by Google Gemini API to analyze account activity and offer tailored advice.
- **Streaming Responses**: Real-time natural language interaction for financial query processing.
- **Smart Prompts**: Pre-configured quick prompts for spending breakdowns, savings goals, and budget alerts.

### 🛡️ KYC Verification & Access Control
- **Document Capture**: Step-by-step submission of government IDs, personal details, and live selfie verification.
- **Non-Repeatability System**: Approved users see a prominent **"Identity Verified"** certificate view and are blocked from repeating the verification flow.
- **Backend Gatekeeper**: Service-level validation (`UserProductApplicationService`) queries Firestore `profiles.kycStatus` before writing to application queues.

### ⚡ Product Applications & Management
- **Product Catalog**: Browse regulated Savings Accounts, Checking Accounts, Loans, Credit Cards, and Time Deposits.
- **In-App Application Tracker**: Prominent **"My Applications"** card on the product screen displaying real-time status badges (`Pending`, `Approved`, `Rejected`, `More Info Required`).
- **Automatic Account Provisioning**: Approving a product application instantly provisions the new account document in Firestore with initial deposit funding.

### 🏛️ Admin Portal & Compliance
- **Dedicated Admin Workspace**: Isolated router (`/admin/*`) with specialized top-level layout (`AdminShell`).
- **KYC Review Queue**: Inspect submitted ID photos, view applicant details, and approve, reject, or request additional documents.
- **Product Approval Workflow**: Process pending account/loan applications with single-tap approvals and automatic account creation.
- **Immutable Audit Logging**: Every administrative action (approval, rejection, role assignment) is logged to the `audit_logs` collection.
- **Customer Search**: Search bank customers by name, email, or UID to inspect account statuses.

---

## 3. Application Architecture

SmartBank AI strictly adheres to **Clean Architecture** principles, maintaining a decoupling between business logic, data persistence, and presentation interfaces.

```
                  ┌─────────────────────────────────────────┐
                  │           Presentation Layer            │
                  │   (Flutter Widgets, Screens, UI Theme)  │
                  └────────────────────┬────────────────────┘
                                       │
                                       ▼
                  ┌─────────────────────────────────────────┐
                  │               Domain Layer              │
                  │   (Entities, Use Cases, Value Objects)  │
                  └────────────────────▲────────────────────┘
                                       │
                                       ▼
                  ┌─────────────────────────────────────────┐
                  │                Data Layer               │
                  │ (Repositories, Data Sources, Firestore) │
                  └─────────────────────────────────────────┘
```

### Layer Breakdown:
- **Presentation Layer**: Riverpod `ConsumerWidget` and `ConsumerStatefulWidget` components consuming reactive state.
- **Domain Layer**: Immutable Freezed entities (`Account`, `ProductApplication`, `AdminUser`, `AuditLog`) defining core business rules.
- **Data Layer**: Concrete repository implementations (`FirestoreWalletRepository`, `KycAdminRepository`, `ProductApplicationRepository`) interacting with Cloud Firestore.
- **Core Layer**: Global utilities, theme definitions, network handlers, and `KycGatekeeper` status parsing engines.

---

## 4. Technology Stack

| Category | Technology | Usage / Description |
| :--- | :--- | :--- |
| **Frontend Framework** | [Flutter 3.x](https://flutter.dev) | Cross-platform framework for Web, Android, iOS, Windows |
| **Language** | [Dart 3.x](https://dart.dev) | Strongly-typed language powering Flutter logic |
| **State Management** | [Riverpod 2.x](https://riverpod.dev) | Compile-safe reactive state management with code generation |
| **Backend & Database** | [Google Firebase](https://firebase.google.com) | Cloud Firestore NoSQL Database & Realtime Sync |
| **Authentication** | Firebase Auth | Secure user identity management & session persistence |
| **Storage** | Firebase Storage | Cloud bucket storage for KYC document & ID uploads |
| **AI Processing** | Google Gemini API & [Groq LPU](https://groq.com) | Ultra-fast LLM inference & financial insights processing engine |
| **UI Components** | Material 3 & Lucide Icons | Premium aesthetic styling with custom glassmorphic accents |
| **Code Generation** | Freezed & JsonSerializable | Immutable data models and JSON serialization |

---

## 5. Database Overview

SmartBank AI utilizes Cloud Firestore with a normalized document-collection schema designed for low-latency queries and real-time streaming:

```
cloud_firestore/
├── users/{userId}                    # Core user credentials & authentication metadata
├── profiles/{userId}                 # Extended customer profile & real-time kycStatus
├── accounts/{accountId}              # Active savings/checking accounts & card balances
├── transactions/{transactionId}      # Financial ledger for debits, credits, and transfers
├── kyc_records/{recordId}            # Submitted KYC documents, ID photos, and status
├── product_applications/{appId}     # Product requests pending admin review
├── admin_users/{adminUid}            # Admin accounts, assigned roles, and privileges
├── audit_logs/{logId}                # Immutable administrative activity audit log
└── beneficiaries/{beneficiaryId}     # Saved payees linked to customer accounts
```

### Key Relationships:
- `profiles.userId` maps 1:1 with `users.uid`.
- `accounts.userId` maps 1:N with customer accounts displayed in the dashboard card carousel.
- `product_applications.userId` links customer product applications to `accounts` upon Admin approval.
- `audit_logs.targetUserId` tracks admin decisions against specific customer records.

---

## 6. Project Structure

```text
lib/
├── app/                              # Application configuration & Routing
│   ├── constants/                    # Spacing, colors, and layout constants
│   ├── router/                       # GoRouter definition with Admin Shell isolation
│   └── theme/                        # App theme and color palettes
├── core/                             # Shared utilities & services
│   ├── errors/                       # Failure definitions and error handling
│   ├── services/                     # Database seeder & provisioning services
│   └── utils/                        # KycGatekeeper engine & Card validation
├── features/                         # Feature-driven modular architecture
│   ├── admin/                        # Admin Portal (Dashboard, KYC Queue, Applications, Audit Logs)
│   ├── ai_assistant/                 # Gemini AI Assistant screen & chat provider
│   ├── analytics/                    # Spending charts & financial reports
│   ├── auth/                         # Authentication, PIN setup, and Login screens
│   ├── card_management/              # Card detail views & card limits
│   ├── dashboard/                    # Customer Home, Balance Cards, Quick Actions
│   ├── kyc/                          # KYC document capture & status view
│   ├── products/                     # Product catalog, Application forms & Tracker
│   ├── profile/                      # Profile settings & KYC status tile
│   ├── transactions/                 # Transaction ledger & Digital receipt generator
│   ├── transfer/                     # Money transfer forms & Beneficiary picker
│   └── wallet/                       # Digital Wallet & account management
├── shared/                           # Reusable UI widgets & domain models
│   ├── models/                       # Shared Account, Transaction, and User models
│   └── widgets/                      # Buttons, Input fields, Badges, and Dialogs
├── firebase_options.dart             # Auto-generated Firebase setup configuration
└── main.dart                         # Application entrypoint & initialization
```

---

## 7. Installation & Setup

### Prerequisites
- **Flutter SDK**: `^3.19.0` or higher
- **Dart SDK**: `^3.3.0` or higher
- **Firebase Project**: Created in [Firebase Console](https://console.firebase.google.com) with Auth & Firestore enabled
- **IDE**: VS Code or Android Studio with Flutter plugin installed

### Step-by-Step Guide

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Sole248k/SmartBanking-AI.git
   cd SmartBanking-AI/ai_banking
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**:
   The project uses `freezed` and `riverpod_generator`. Generate required files by running:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase**:
   Install the FlutterFire CLI and link your Firebase project:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

---

## 8. Environment Configuration

Create a `.env` file in the root directory (or update `lib/firebase_options.dart`) with your environment credentials:

```env
# Gemini AI Assistant API Key
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Web / Mobile Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=smartbank-ai-c784d
```

> **Note**: Do not commit your real `.env` file or API credentials to public repositories.

---

## 9. Running the Application

### 🌐 Flutter Web
```bash
flutter run -d chrome --web-port=5000
```
- **Customer Portal**: `http://localhost:5000/#/welcome`
- **Admin Portal**: `http://localhost:5000/#/admin/login`

### 📱 Android
```bash
flutter run -d android
```

### 🍎 iOS (macOS host required)
```bash
flutter run -d ios
```

---

## 10. User Roles & Access Control

SmartBank AI implements Role-Based Access Control (RBAC) across three distinct privilege levels:

| Privilege Level | Scope | Permissions & System Access |
| :--- | :--- | :--- |
| **Regular Customer** | Customer Portal | View accounts, execute transfers, manage cards, submit KYC, apply for products, interact with AI assistant. |
| **Operations Admin** | Admin Portal | Review customer KYC applications, approve/reject product requests, search customer records. |
| **Super Administrator** | Admin Portal | All Ops permissions + manage administrator accounts, grant role elevations, inspect global audit logs. |

---

## 11. Security Model

1. **KYC Approval Gatekeeper**:
   Unverified users are blocked at both UI and repository levels from creating bank accounts or applying for loans.
2. **Transaction PIN Verification**:
   All transfer operations validate the 6-digit transaction PIN prior to writing debits/credits to Firestore.
3. **Idempotent Account Creation**:
   Application approvals stamp a unique `applicationId` on created account records to prevent duplicate provisioning.
4. **Immutable Audit Logging**:
   Administrative actions emit immutable logs containing `adminUid`, `action`, `targetUserId`, `previousStatus`, `newStatus`, and server timestamps.

---

## 12. Banking Workflow

```text
       ┌────────────────────────┐
       │   Customer Register    │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │  Setup 6-Digit PIN     │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │ Submit KYC Documents   │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │ Admin Reviews & Approves│
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │ Apply Banking Products │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │ Auto-Provision Account │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │ Transfer & Track Ledgers│
       └────────────────────────┘
```

---

## 13. Future Roadmap

- [ ] **QR Code Payments**: Generate and scan EMV-compliant QR codes for merchant checkout.
- [ ] **Real Payment Gateway**: Integration with Stripe / PayMongo for real credit card cash-ins.
- [ ] **Multi-Currency Accounts**: Hold USD, EUR, and PHP in unified wallet accounts.
- [ ] **Push Notifications**: Real-time FCM notifications on transaction debits and KYC status changes.
- [ ] **Advanced AI Forecasting**: Predictive cash flow analysis using historical transaction vectors.

---

## 14. Screenshots

| Customer Dashboard | Cards & Accounts | Admin KYC Queue |
| :---: | :---: | :---: |
| *(Placeholder)* | *(Placeholder)* | *(Placeholder)* |

| Product Applications | AI Assistant | Application Tracker |
| :---: | :---: | :---: |
| *(Placeholder)* | *(Placeholder)* | *(Placeholder)* |

---

## 15. Contributors

| Name | Role | Responsibilities |
| :--- | :--- | :--- |
| **Sole248k** | Lead Developer | Full-Stack Flutter Architecture, Firebase Integration & Admin Governance |
| **SmartBank Team** | Product & Design | UI/UX Glassmorphism Design & Financial Domain Specifications |

---

## 16. License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 17. Acknowledgements

- [Flutter Framework](https://flutter.dev) & [Dart Language](https://dart.dev)
- [Firebase Cloud Firestore & Authentication](https://firebase.google.com)
- [Google DeepMind & Gemini AI](https://deepmind.google)
- [Groq LPU AI Inference Engine](https://groq.com)
- [Riverpod Reactive State Management](https://riverpod.dev)
- [Lucide Icons Community](https://lucide.dev)
