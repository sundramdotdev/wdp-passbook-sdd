<div align="center">
  <img src="assets/images/logo.png" alt="WDP Passbook Logo" width="120" />
  
  #  WDP Passbook
  
  **A Smart, AI-Driven Personal Finance & Ledger Ecosystem**
  
  [![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Database](https://img.shields.io/badge/Database-Isar-F97316?style=for-the-badge)](https://isar.dev)
  [![State](https://img.shields.io/badge/State-Riverpod-1A2435?style=for-the-badge)](https://riverpod.dev)
</div>

<br/>

## The Idea
Traditional expense trackers are tedious. **WDP Passbook** reimagines personal finance by unifying your daily transactions, merchant ledgers, and friend-to-friend lending (*Udhar*) into a single, beautiful, and hyper-intelligent interface.

Instead of manually typing data, you can simply tell the AI: *"chai aur momos 80 mein"* or scan a merchant's QR code to pay directly via UPI. It’s a complete financial command center wrapped in a breathtaking **Navy Blue & Orange Claymorphism UI**.

---

##  Key Features

###  AI-Powered Intelligence
Stop filling out forms. Tap the AI button and type in natural language (Hinglish/English). The integrated Groq AI parses the text and automatically extracts the amount, category, and remark. 

###  Built-in UPI Payments & QR Scanner
Scan any UPI QR code using the built-in scanner. The app securely hands off the payment to your preferred UPI app using our custom `ModernUpiPlugin`. Upon a successful payment, the transaction is automatically recorded in your passbook.

###  Udhar (Lending & Borrowing) Ledger
Never forget who owes you money. 
- Track **"I Gave"** and **"I Took"** entries.
- One-tap **Settle** button automatically generates a balancing transaction in your core ledger, keeping your balance perfectly in sync.

###  Passbook & Budget Tracking
- A unified chronological feed of your Income, Expenses, and Settlements.
- Smart filters (UPI, Cash, Udhar, Pending).
- Set monthly limits per category and track progress via visual progress bars.

---

##  Design Philosophy: True Claymorphism
The UI was meticulously crafted using authentic **Claymorphism**.
- **The Palette:** Built around a bespoke Deep Navy Blue (`#0F1724`) and vibrant Brand Orange (`#F97316`).
- **The Feel:** Elements feature generous border radii, dual inner-shadow highlights, and grounding outer shadows. The interface feels puffy, soft, and 3D—a stark contrast to flat, generic apps.

---

## Architecture & Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
- **Local Database:** [Isar Database](https://isar.dev/) (NoSQL, Blazing Fast)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) for deep linking and shell routing.
- **Native Integrations:**
  - `modern_upi_plugin` (Custom Native Android Plugin for UPI Intent handling)
  - `mobile_scanner` (QR Code Detection)
  - `flutter_native_splash` (Seamless video splash screen transitions)

### Directory Structure

```text
lib/
├── core/
│   ├── constants/    # Theme colors, typography, dimensions
│   ├── router/       # GoRouter configurations
│   ├── theme/        # Light/Dark ThemeData definitions
│   ├── utils/        # Formatters, helpers
│   └── widgets/      # Shared components (ClayContainer, NavBars)
├── data/
│   ├── models/       # Isar Collections (Transaction, Merchant, Budget)
│   └── providers/    # Riverpod providers for DB & APIs
└── features/
    ├── add_transaction/ # Unified bottom sheets for Income/Expense
    ├── budget/          # Budget tracking limits
    ├── merchants/       # Merchant ledgers and analytics
    ├── passbook/        # Main Dashboard feed
    ├── qr_scanner/      # Mobile Scanner implementation
    ├── splash/          # Video Splash Screen
    └── udhar/           # Udhar Ledger & Settlement Logic
```

---

> [!Tips!]  
> **Testing UPI:** The UPI flow utilizes a custom Android intent plugin (`modern_upi_plugin`). It will only function on physical Android devices or emulators that have UPI apps (like GPay, PhonePe, Paytm) installed.

---

