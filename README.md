# KMyMoney App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-blue?style=for-the-badge)](https://flutter.dev/multi-platform)

> A comprehensive cross-platform personal finance management application built with Flutter, inspired by the KMyMoney desktop application. Features clean architecture, real-time data synchronization, and full KMyMoney file format support.

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK**: 3.10.4 or higher
- **Dart SDK**: Included with Flutter
- **IDE**: Android Studio, VS Code, or any Flutter-compatible IDE

### Installation & Running

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/kmymoney_app.git
   cd kmymoney_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk
   
   # iOS
   flutter build ios
   
   # Windows
   flutter build windows
   
   # Linux
   flutter build linux
   
   # macOS
   flutter build macos
   ```

### Desktop Development Setup

For desktop development, ensure you have:
- **Windows**: Visual Studio Build Tools 2019 or later
- **Linux**: GTK development libraries (`sudo apt-get install libgtk-3-dev`)
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)

## 📱 Features

### ✅ Implemented Features

#### Core Functionality
- **Account Management**: Multiple account types (assets, liabilities, income, expenses, equity, investments)
- **Transaction Tracking**: Complete transaction history with split transactions support
- **Scheduled Transactions**: Recurring payments and bill reminders
- **Payee Management**: Organize and track transaction recipients
- **Real-time Updates**: Reactive UI with automatic data refresh
- **Account Filtering**: Flexible filtering by account type, status, and preferences

#### Data Management
- **🗂️ KMyMoney File Support**: Import and parse KMyMoney (.kmy) files with full compatibility
- **💾 SQLite Database**: Local data storage with automatic schema migrations
- **🔢 Precise Financial Calculations**: Decimal arithmetic for accurate monetary values
- **🖥️ Cross-platform Support**: Desktop support via sqflite_common_ffi

#### User Interface
- **🎨 Material Design 3**: Modern, responsive UI following latest Material Design principles
- **📊 Dashboard View**: Comprehensive overview of accounts and upcoming scheduled transactions
- **📝 Transaction Lists**: Detailed transaction views with advanced account-specific filtering
- **⚙️ Settings Management**: Theme switching and locale preferences

### 🏗️ Architecture Features

#### Clean Architecture Implementation
- **🧩 Domain Layer**: Pure business logic with immutable models
- **💾 Data Layer**: Repository pattern with SQLite integration
- **🖼️ Presentation Layer**: Riverpod state management with reactive providers

#### State Management
- **⚡ Riverpod**: Modern, type-safe state management
- **🔄 Real-time Providers**: Automatic UI updates on database changes
- **👥 Family Providers**: Parameterized state for account-specific data

#### Database Design
- **📈 Schema Migrations**: Version-controlled database updates
- **📢 Change Notifications**: Manual change propagation for reactive updates
- **🔍 Complex Queries**: Joins and aggregations for rich data presentation

## ⚙ Technology Stack

### Core Framework
- **[Flutter](https://flutter.dev/)**: Cross-platform UI framework
- **[Dart](https://dart.dev/)**: Programming language (SDK ^3.10.4)

### State Management & Architecture
- **[Riverpod](https://riverpod.dev/)**: Modern state management (^2.5.1)
- **Clean Architecture**: Separation of concerns
- **Repository Pattern**: Data access abstraction

### Data & Storage
- **[SQLite](https://pub.dev/packages/sqflite)**: Local database (^2.3.2)
- **[sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)**: Desktop database support
- **[Decimal](https://pub.dev/packages/decimal)**: Precise financial calculations (^2.3.0)

### File Processing
- **[XML Parsing](https://pub.dev/packages/xml)**: KMyMoney file format support (^6.5.0)
- **[Archive](https://pub.dev/packages/archive)**: GZIP decompression (^3.4.10)
- **[File Picker](https://pub.dev/packages/file_picker)**: Cross-platform file selection (^8.0.0)

### UI & Navigation
- **Material Design 3**: Google's latest design system
- **[Go Router](https://pub.dev/packages/go_router)**: Declarative navigation (^12.0.0)
- **[ScreenUtil](https://pub.dev/packages/flutter_screenutil)**: Responsive design utilities (^5.9.0)

### Utilities
- **Internationalization**: flutter_localizations
- **[Date/Time](https://pub.dev/packages/intl)**: intl package (^0.20.2)
- **[Path Handling](https://pub.dev/packages/path_provider)**: path provider (^2.1.1)

## 📁 Project Structure

```
lib/
├── core/                           # Core utilities and initialization
│   └── database_initializer.dart   # SQLite database setup for desktop
├── domain/                         # Business logic layer
│   ├── models/                     # Domain entities
│   │   ├── account.dart           # Financial account model
│   │   ├── money.dart             # Precise monetary value
│   │   ├── payee.dart             # Transaction recipient
│   │   ├── schedule.dart          # Scheduled transaction
│   │   ├── ledger_transaction.dart # Transaction with splits
│   │   ├── split.dart             # Transaction line item
│   │   └── kmy_file.dart          # Top-level data container
│   └── repositories/              # Repository interfaces
│       └── kmy_repository.dart    # Data access contract
├── data/                          # Data access layer
│   ├── database/                  # Database implementation
│   │   ├── app_database.dart      # SQLite database manager
│   │   ├── account_dao.dart       # Account data access
│   │   ├── payee_dao.dart         # Payee data access
│   │   ├── schedule_dao.dart      # Schedule data access
│   │   ├── transaction_dao.dart   # Transaction data access
│   │   ├── db_change_notifier.dart # Database change events
│   │   └── models/                # Database row models
│   │       ├── account_type.dart          # Account type enum
│   │       ├── account_with_balance_row.dart # Account with balance
│   │       ├── schedule_with_details_row.dart # Schedule with joins
│   │       └── account_filter_settings.dart # Filter preferences
│   ├── kmy_file_loader.dart       # File loading and decompression
│   ├── kmy_parser.dart            # XML parsing logic
│   └── repositories/              # Repository implementations
│       └── kmy_repository_impl.dart # Concrete repository
├── presentation/                  # UI layer
│   ├── providers/                # Riverpod state management
│   │   ├── repository_providers.dart     # Dependency injection
│   │   ├── kmy_file_provider.dart         # File loading state
│   │   ├── account_list_provider.dart    # Account list with filtering
│   │   ├── account_transactions_provider.dart # Account transactions
│   │   ├── home_dashboard_providers.dart  # Dashboard data
│   │   ├── schedule_list_provider.dart   # Schedule list
│   │   ├── app_settings_provider.dart    # App settings
│   │   └── settings_provider.dart        # Account filter settings
│   └── screens/                  # UI screens
│       ├── home_screen.dart       # Main dashboard
│       ├── account_list_screen.dart     # Account management
│       ├── account_transactions_screen.dart # Transaction details
│       ├── schedules_screen.dart        # Scheduled transactions
│       ├── settings_screen.dart         # Application settings
│       ├── main_tabs_screen.dart        # Tab navigation
│       ├── app_settings_screen.dart     # App configuration
│       └── others_screen.dart           # Additional features
└── main.dart                      # Application entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (version 3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd kmymoney_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Development Setup

For desktop development, ensure you have the required platform dependencies:
- **Windows**: Visual Studio Build Tools
- **Linux**: GTK development libraries
- **macOS**: Xcode Command Line Tools

## Documentation

This project features comprehensive documentation throughout the codebase:

### Documentation Standards
- **DartDoc Comments**: Complete API documentation with `///` syntax
- **File Headers**: Copyright, purpose, and licensing information
- **Parameter Documentation**: Detailed parameter descriptions using `[param]` syntax
- **Usage Examples**: Code examples for complex operations
- **Architecture Documentation**: Explanations of design patterns and data flow

### Copyright Notice
All files include the copyright header:
```
// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT
```

### Key Documentation Areas
- **Domain Models**: Complete business entity documentation
- **Data Access Objects**: Database operation documentation
- **Providers**: State management and data flow documentation
- **Screens**: UI component and interaction documentation

## 🗄️ Database Schema

The application uses SQLite with the following main tables:

- **accounts**: Financial account information
- **transactions**: Transaction headers with dates
- **splits**: Transaction line items with amounts
- **schedules**: Recurring transaction definitions
- **payees**: Transaction recipients

The database includes automatic migrations and supports schema versioning.

## 🧪 Testing

The project includes comprehensive unit tests for core functionality:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/data/kmy_parser_accounts_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Coverage Areas
- KMyMoney file parsing
- Financial calculations
- Database operations
- Schedule interpretation
- Data model validation

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** with proper documentation
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Code Style & Guidelines
- Follow Flutter/Dart official style guidelines
- Add comprehensive documentation to all public APIs
- Include copyright headers in all new files
- Write tests for new functionality
- Use semantic versioning for releases

### Development Workflow
```bash
# Install dependencies
flutter pub get

# Run code generation
flutter packages pub run build_runner build

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[KMyMoney](https://kmymoney.org/)**: Inspiration for this mobile application
- **[Flutter](https://flutter.dev/)**: Cross-platform UI framework
- **[Riverpod](https://riverpod.dev/)**: Modern state management solution
- **[sqflite](https://pub.dev/packages/sqflite)**: SQLite database operations

## 📚 Additional Resources

### Documentation
- **[Flutter Documentation](https://flutter.dev/docs)**: Official Flutter guides and API reference
- **[Riverpod Documentation](https://riverpod.dev/docs)**: State management documentation
- **[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)**: Uncle Bob's Clean Architecture

### Related Projects
- **[KMyMoney Desktop](https://kmymoney.org/)**: Original desktop application
- **[GnuCash](https://www.gnucash.org/)**: Another personal finance management tool

### Community & Support
- **[Flutter Community](https://github.com/flutter/flutter)**: Official Flutter repository
- **[Dart Language](https://dart.dev/community)**: Dart programming language resources
- **[Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)**: Flutter development support

## 📋 Version History

### v1.0.0+1 (Current)
- ✅ Initial release with core functionality
- ✅ Account and transaction management
- ✅ KMyMoney file import/export
- ✅ SQLite database with migrations
- ✅ Comprehensive documentation
- ✅ Cross-platform support

### Planned Features
- 🔮 Cloud synchronization
- 🔮 Advanced reporting and analytics
- 🔮 Budget management
- 🔮 Investment portfolio tracking
- 🔮 Multi-currency support

---

**Built with ❤️ using Flutter**

> For questions, suggestions, or issues, please open an issue on GitHub.
