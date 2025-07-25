# 🔐 Kundali Lock

A secure Flutter vault app that uniquely blends **Vedic astrology** with modern **AES encryption**. Unlock your private vault using a custom pattern derived from your **birth chart** — no passwords, just planets.

---

![Flutter](https://img.shields.io/badge/Built%20with-Flutter-blue.svg)
![State](https://img.shields.io/badge/State%20Management-Provider-green.svg)
![Encryption](https://img.shields.io/badge/Encryption-AES%20256-orange.svg)

## 🌌 Features

* 🔭 **Birth Chart Generator**
  Enter birth date, time, and place to generate a sidereal Vedic Kundali.

* 🔒 **Planet-Based Pattern Unlock**
  Draw a custom pattern using planets like Mars, Saturn, or Moon to access your vault.

* 🧠 **Honeypot Vault Mode**
  Enter a wrong but “valid” pattern? You'll be shown a decoy vault with fake data.

* 🛡️ **AES Encryption**
  Vault data is encrypted using AES-256, with keys derived from your pattern.

* 🗂️ **Secure Vault Storage**
  Save notes, passwords, and files. No internet required. Data stays on device.

* 🎭 **Hidden Gestures**
  Triple tap or long press to switch between modes — a stealthy way to access or hide your vault.

* ✨ **Modern UI**
  Clean, dark-themed design with animated transitions and planetary theming.


---

## 🧠 How It Works

1. **User inputs** birth data (date, time, location)
2. **App generates** a Kundali using sidereal calculations
3. **User selects** a pattern of planets (e.g. Saturn → Mars → Venus → Ketu)
4. **Key is derived** using the selected planets + pepper → AES encryption
5. **Vault unlocks** and data is decrypted on device

---

## 🛡️ Tech Stack

* Flutter (UI)
* Provider (State management)
* SharedPreferences (Local storage)
* AES encryption (manual + crypto lib)
* Vedic astrology logic (custom logic)

---

## 🚀 Getting Started

### Prerequisites

* Flutter 3.10+
* Dart SDK
* Android Studio or VS Code

### Setup

```bash
git clone https://github.com/Gupta-Aniket/kundali-lock.git
cd kundali-lock
flutter pub get
flutter run
```

---

## 🔐 Security Note

All data is stored **locally**. No remote servers, APIs, or cloud access. Vault keys are derived from **deterministic planetary info**, making the pattern **unique and reproducible** but secure (unless someone knows your exact birth data *and* planet pattern).

---

## 📂 Folder Structure (Simplified)

```
lib/
├── controllers/
├── models/
├── services/
├── views/
└── main.dart
```

---

## 🧩 TODOs

* [ ] Add biometric fallback
* [ ] Integrate planetary transit tracking
* [ ] Export vault data as encrypted file
* [ ] iOS build and release

---

## 🙌 Credits

Built with ❤️ by [Aniket Gupta](https://github.com/Gupta-Aniket)

---
