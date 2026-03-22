# ChatAI — Smart Conversational App

ChatAI is a sleek and powerful conversational application that integrates **DeepSeek API** via **OpenRouter** and leverages **Firebase** for authentication and account management. With a strong focus on API design, context-aware chat flow, and seamless user experience, ChatAI is designed to be both functional and developer-friendly.

---

## ✨ Features

- 🔐 **Firebase Authentication** (Sign Up / Sign In / Delete Account)
- 🧳 **Firebase Storage** Message read and write functionality. Load all the messages for a specific conversation. Each user has their own set of conversations and messages inside that conversation, pretty much exactly how the ChatGPT application works
- 💬 **Supports Markdown** Message gets all modern Markdown support such as Bold Text, italics, underline, etc.
- 🔄 **DeepSeek API Integration** via OpenRouter
- 🧠 **Context-Aware Chat**: Chat headline updates dynamically based on chat content
- 🎨 **Polished UI** With support for Dark Mode!
- 🧰 Modular and scalable **backend & network architecture**
- 🔍 **Support for Search** Find exactly what you're looking for in the conversation sidebar with the Search function.
- 👤 **Support for Persona Selection** Tailor the AI for your needs using the Persona Selector menu.

---

## 📱 Screenshots

<img src="https://imgur.com/0jtnQCd.jpg" width="250" /> <img src="https://imgur.com/NdkkCH3.jpg" width="250" /> <img src="https://imgur.com/AsHkxrg.jpg" width="250" />
<img src="https://imgur.com/Gnria4u.jpg" width="250" /> <img src="https://imgur.com/ItSSVWw.jpg" width="250" /> <img src="https://imgur.com/1TLZwZO.jpg" width="250" />

---

## 🧩 Tech Stack

- **Language**: Swift
- **Backend**: Firebase
- **AI Model**: DeepSeek API via OpenRouter
- **UI Framework**: SwiftUI
- **Database**: Firebase

---

## 🔧 Project Structure(WIP)

```
├── constants.Swift        # API Key for OpenRouter + DeepSeek
├── firebase/              # Firebase Auth calls
├── models/                # Data models
├── views/                 # UI components
├── viewmodels/            # State management
├── ChatAI.swift           # Entry point
```

---

## 🌐 API Implementation

- All requests are routed via **OpenRouter** using an API key
- Chat messages are sent as HTTP POST requests
- Responses are parsed and rendered in real-time
- Headers and authentication managed securely

> Check `ConversationViewModel.swift` for implementation details.

---

## </a><img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/firebase/firebase-original.svg" alt="firebase" width="42" height="42" /></a>  Firebase Implementation

- **Sign Up / Sign In / Delete Account**
- **Store Messages for each User**
- Uses **Firebase Authentication SDK** and **FirebaseFirestore SDK**
- Error handling with user feedback
- Secure session management

> See `AuthViewModel.swift` and `conversationViewModel.swift` for functions and logic.

---

## 🎨 UI Design

- Clean and minimal interface
- Dynamic chat bubbles
- State-based rendering for loading/errors
- Auto-scroll and context headline updates

> Visit `ConversationView.swift, LoginView.swift, etc` for UI layout and interaction.

---

## 🧠 Chat Context & Headline

- On receiving a response, the app parses the message context
- The top headline dynamically updates to reflect the core topic
- Helps users stay aware of conversation flow and themes

> Logic handled inside `ChatViewModel.swift` → `provideTitle()` method

---

## 🏗️ Backend Design

- Lightweight client-driven architecture
- Stateless with Firebase session support
- All AI logic handled via OpenRouter proxy to DeepSeek

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/adityaanand176/ChatAI.git
   cd ChatAI
   ```

2. Setup dependencies:
   - Add your OpenRouter API key in Constants.swift
   - Get your own GoogleServiceInfo.plist file from Firebase
   - Make sure the name is the same as stated.

3. Run the app from the XCode Project File to your simulator or best use it on your iPhone!

---

## 📬 Feedback & Contributions

Found a bug? Have a feature request?
Feel free to [open an issue](https://github.com/adityaanand176/ChatAI/issues) or submit a PR.

---
