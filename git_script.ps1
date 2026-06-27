git add pubspec.yaml pubspec.lock README.md .gitignore analysis_options.yaml .metadata android/ ios/ web/ linux/ macos/ test/ assets/
git commit -m "Initial Flutter project setup with standard templates"

git add packages/modern_upi_plugin/
git commit -m "Setup modern UPI plugin scaffolding for native payments"

git add lib/core/constants/
git commit -m "Add core constants and typography tokens"

git add lib/core/theme/
git commit -m "Configure app theme and dark mode styling"

git add lib/core/router/
git commit -m "Add shell routing setup using GoRouter"

git add lib/core/widgets/clay_container.dart
git commit -m "Add custom ClayContainer for 3D neumorphic styling"

git add lib/core/widgets/scaffold_with_nav_bar.dart
git commit -m "Setup Scaffold with bottom navigation bar"

git add lib/core/utils/
git commit -m "Add currency formatter utility"

git add lib/data/models/transaction*
git commit -m "Setup Isar database models for Transaction"

git add lib/data/models/merchant* lib/data/models/budget*
git commit -m "Setup Isar models for Merchant and Budget"

git add lib/data/models/udhar* lib/data/models/category*
git commit -m "Setup Udhar entry and category models"

git add lib/data/services/isar* lib/data/repositories/
git commit -m "Implement Isar service and local repositories"

git add lib/data/providers/db_provider.dart lib/data/providers/repositories_provider.dart
git commit -m "Add Riverpod providers for database access"

git add lib/data/services/groq_service.dart lib/data/providers/groq_provider.dart lib/features/ai_assistant/
git commit -m "Add Groq AI integration service and consent dialog"

git add lib/features/splash/
git commit -m "Implement video splash screen transition"

git add lib/features/passbook/
git commit -m "Add passbook dashboard view and transaction feed"

git add lib/features/add_transaction/add_income_sheet.dart lib/features/add_transaction/add_expense_sheet.dart
git commit -m "Build add transaction sheets for Income and Expense"

git add lib/features/add_transaction/upi_payment_flow.dart
git commit -m "Implement UPI Payment flow and intent handling"

git add lib/features/udhar/ lib/features/add_transaction/add_udhar_sheet.dart
git commit -m "Build Udhar ledger and settlement logic"

git add lib/features/qr_scanner/
git commit -m "Implement QR Scanner feature for merchants"

git add lib/features/budget/ lib/features/merchants/
git commit -m "Build Budget and Merchant tracking screens"

git add lib/main.dart lib/features/analytics/ lib/features/more/ lib/features/settings/ lib/data/services/sms_service.dart
git commit -m "Add main entrypoint and supplementary features"

git add .
git commit -m "Final UI polish, claymorphism enhancements, and bug fixes"

git push origin main
