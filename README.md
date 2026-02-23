# KMyMoney App

A Flutter mobile application for personal finance management, inspired by the KMyMoney desktop application.

## Project Overview

KMyMoney App is a comprehensive personal finance management tool that helps users track their income, expenses, accounts, and investments. The app provides a clean, intuitive interface for managing financial data on mobile devices.

## Features

### Core Features
- **Account Management**: Create and manage multiple accounts (checking, savings, credit cards, investments)
- **Transaction Tracking**: Record and categorize income and expenses
- **Budget Planning**: Set and monitor budget limits for different categories
- **Financial Reporting**: Generate reports for spending analysis and financial overview
- **Data Import/Export**: Support for KMyMoney (.kmy) file format

### Planned Features
- **Investment Tracking**: Monitor portfolio performance and asset allocation
- **Bill Reminders**: Set up recurring payment notifications
- **Multi-currency Support**: Handle transactions in different currencies
- **Cloud Sync**: Synchronize data across multiple devices
- **Advanced Reporting**: Detailed financial analysis and trend visualization

## Architecture

The app follows a clean architecture pattern with the following layers:

- **Domain Layer**: Core business logic and entities
- **Data Layer**: Data access objects (DAOs) and database management
- **Presentation Layer**: UI components and state management using Riverpod

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Database**: SQLite (via sqflite)
- **Architecture**: Clean Architecture with Repository Pattern
- **File Format**: KMyMoney (.kmy) compatibility

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0 or higher)
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

## Project Structure

```
lib/
├── domain/           # Business logic and models
│   ├── models/       # Data models
│   └── repositories/ # Repository interfaces
├── data/            # Data access layer
│   ├── database/    # Database helpers and DAOs
│   └── repositories/ # Repository implementations
├── presentation/    # UI layer
│   ├── screens/     # Main screens
│   ├── widgets/     # Reusable UI components
│   └── providers/   # State management
└── core/            # Utilities and constants
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the [KMyMoney](https://kmymoney.org/) desktop application
- Built with [Flutter](https://flutter.dev/)
