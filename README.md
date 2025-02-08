# Dr.AI

Dr.AI is a proof-of-concept Flutter application that simulates an AI-driven "smart doctor" chat experience. It integrates speech recognition, text-to-speech, and AI-based chat functionalities to demonstrate how users might interact with a health-related assistant. Developed as part of a final-year project, this application is not intended for production or real-world medical diagnosis.

## Table of Contents

- [Dr.AI](#drai)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Screens Overview](#screens-overview)
  - [Project Structure](#project-structure)
  - [Getting Started](#getting-started)
  - [Usage](#usage)
  - [Configuration](#configuration)
  - [Dependencies](#dependencies)
  - [Roadmap](#roadmap)
  - [Disclaimer](#disclaimer)
  - [License](#license)

---

## Features

1. AI Chat Interface  
   - Chat with an AI assistant using text or images.  
   - The AI can respond based on configured models and system prompts.

2. Speech Recognition and TTS (Optional)  
   - Use speech-to-text (STT) via the microphone to transcribe user input.  
   - Use text-to-speech (TTS) to read out the AI’s responses.

3. Multiple Chat Sessions  
   - Create new chat sessions and store previous chats locally for reference or re-use.  
   - Supports naming and managing stored chat sessions.

4. Basic Settings & Customization  
   - Change themes (light/dark) and color schemes (dynamic color is supported).  
   - Configure application behavior (e.g., system prompt, markdown usage, request type).  
   - Configure host URL for connecting to an AI service.

5. Exports & Imports  
   - Export chat histories to JSON.  
   - Import chat histories retrieved from others.

6. Voice Mode (Experimental)  
   - Voice-based continuous conversation loop where the AI automatically responds with TTS and awaits further STT commands.

---

## Screens Overview

- Main Chat Screen – Central interface for chatting with the AI assistant, uploading images, or toggling voice mode.  
- Settings Screen – Configure the host, enable or disable voice, tweak chat behavior, or manage interface options.  
- Voice Screen – A dark-themed, experimental window for continuous speech-based conversations.  
- Export & Import Screen – Allows saving or retrieving JSON chat logs.  
- About Screen – Provides disclaimers, license info, and links for further information.

---

## Project Structure

Below is a condensed overview of the main files and folders. Refer to the code for detailed implementation:

```
lib
├── l10n
├── screens
│   ├── settings
│   │   ├── screen_add_calendar.dart
│   │   ├── screen_add_vaccine_record.dart
│   │   ├── screen_calendar.dart
│   │   ├── screen_map.dart
│   │   ├── screen_settings.dart
│   │   ├── screen_vaccine_record.dart
│   │   └── screen_voice.dart
├── services
│   ├── service_desktop.dart
│   ├── service_haptic.dart
│   ├── service_sender.dart
│   ├── service_setter.dart
│   └── service_theme.dart
├── widgets
│   ├── widgets_screens
│   │   ├── widgets_settings
│   │   │   ├── widget_about.dart
│   │   │   ├── widget_behavior.dart
│   │   │   ├── widget_export.dart
│   │   │   └── widget_interface.dart
│   │   ├── widget_add_calendar.dart
│   │   ├── widget_add_vaccine_record.dart
│   │   ├── widget_calendar.dart
│   │   ├── widget_main.dart
│   │   ├── widget_map.dart
│   │   ├── widget_screen_settings.dart
│   │   └── widget_vaccine_record.dart
│   ├── widgets_units
│   │   ├── widget_button.dart
│   │   ├── widget_title.dart
│   │   └── widget_toggle.dart
│   └── widgets_workers
│       └── widget_desktop.dart
└── main.dart
```

---

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/old-cookie/dr_ai
   cd DrAI
   ```

2. Install dependencies via Flutter:

   ```bash
   flutter pub get
   ```

3. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

4. (Optional) Configure a local or remote AI host if needed. See [Configuration](#configuration).

---

## Usage

1. Launch the App  
   After running the Flutter app, the Main Chat Screen will appear.

2. Chat with the Assistant  
   - Type your message in the input field at the bottom, or tap the attachment icon if voice mode is enabled or if you wish to send an image.  
   - The AI responds within the chat window.

3. Manage Chats  
   - Hover or long-press (on mobile) on chats in the sidebar to rename or delete them.  
   - Create a new chat with the “New Chat” option.  

4. Adjust Settings  
   - Access the Settings Screen to configure host, theme, AI behavior, and other advanced options.  
   - In the “Voice” tab, enable the experimental voice mode if you want to speak or have the AI read aloud its responses.

---

## Configuration

- Host  
  The app can connect to a local or remote AI service (e.g., an Ollama server). By default, the code references "<http://localhost:11434>". Modify under “Settings” or set the const variables in main.dart for a fixed setup.

- Model  
  The AI model can be selected through the model selection dialog (if enabled). Alternatively, a default model can be set in main.dart.

- Voice Mode  
  Voice functionality depends on microphone permission and TTS availability. Under “Settings > Voice,” you can enable or disable it, change languages, and control punctuation rules.

---

## Dependencies

Key packages used in this project:

- [Flutter Chat UI](https://pub.dev/packages/flutter_chat_ui) – Chat interface components.  
- [Ollama Dart](https://pub.dev/packages/ollama_dart) – Open-source library for connecting to an Ollama-based AI service.  
- [Speech to Text](https://pub.dev/packages/speech_to_text) – Speech recognition (STT).  
- [Flutter TTS](https://pub.dev/packages/flutter_tts) – Text-to-speech.  
- [File Picker](https://pub.dev/packages/file_picker) – Image selection, JSON import.  
- And more (see pubspec.yaml for the full list).

---

## Roadmap

- [x] AI Chat
- [ ] Map and Search
- [ ] Vaccines Record
- [ ] Medicine calendar

---

## Disclaimer

This project is a final-year academic demonstration and should not be used as a medical tool or to provide real-world health advice. Data privacy and security are not guaranteed. Always consult a qualified healthcare professional for any medical concerns.

---

## License

Dr.AI is released under an open license for demonstration and educational purposes. See the LICENSE file for details, or refer to the “Licenses” section within the app’s “About” tab.
