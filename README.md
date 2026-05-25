# 🌾 FarmMate - Smart Livestock Management 

**FarmMate** is a comprehensive, Flutter-based mobile application designed to empower dairy farmers and livestock owners with intelligent farm management tools. Developed as a Final Year Project (FYP), this application bridges the gap between traditional agricultural practices and modern technology by providing an offline-first database and an intelligent voice assistant. 

### ✨ Key Features
* **🤖 AI Vet Assistant (Urdu):** Integrated with Google Gemini 2.5 Flash, featuring a WhatsApp-style voice-note system. Farmers can speak into the app in Urdu, and the AI will analyze symptoms and reply with voice-guided veterinary advice.
* **🐄 Herd Management:** A complete SQLite-powered local database to track individual animal profiles, including tags, breeds, ages, and custom profile pictures.
* **💰 Financial Tracking:** A premium dashboard to log daily milk production income and track feed/medicine expenses to calculate farm profitability.
* **🔔 Smart Reminders:** Background notifications that trigger daily to remind farmers of critical tasks.
* **📱 Premium UI/UX:** Built using Flutter's Material 3 design system, featuring custom floating cards, soft-shadows, smooth animations, and an intuitive user experience.

### 🛠️ Technology Stack
* **Framework:** Flutter (Dart)
* **Local Database:** sqflite, shared_preferences
* **Artificial Intelligence:** google_generative_ai (Gemini)
* **Hardware Integrations:** Audio recording (`record`), Text-to-Speech (`flutter_tts`), Image Picker
