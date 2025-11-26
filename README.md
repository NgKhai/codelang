# CodeLang

**CodeLang** is a specialized cross-platform application (Mobile/Web) designed to enhance technical English proficiency for developers. It helps users learn and practice English vocabulary and concepts specifically tailored for the software development industry.

<img src="https://github.com/user-attachments/assets/5c8c1f18-8b3c-48c9-aa14-f34cc3097a83"/>

## ✨ Features

-   **Authentication**: Secure Login and Registration system.
-   **Home Dashboard**: Browse and access various exercise sets.
-   **Unified Exercises**: Interactive exercises to test your knowledge.
-   **Flashcards**: Learn technical vocabulary with flip-card animations and text-to-speech support.
-   **Profile Management**: Manage your user profile and settings.
-   **Theme Support**: Fully supported Dark and Light modes for comfortable viewing in any environment.

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
-   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Bloc & Cubit)
-   **Navigation**: [go_router](https://pub.dev/packages/go_router)
-   **Database**: [MongoDB](https://www.mongodb.com/) (via [mongo_dart](https://pub.dev/packages/mongo_dart))
-   **Authentication**: Custom Auth with JWT & [google_sign_in](https://pub.dev/packages/google_sign_in)
-   **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences) & [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
-   **Utilities**:
    -   [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) for environment variables.
    -   [flutter_tts](https://pub.dev/packages/flutter_tts) for Text-to-Speech.
    -   [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) for UI effects.

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.9.2 or higher recommended)
-   MongoDB instance (Local or Atlas)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/NgKhai/codelang.git
    cd codelang
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup**
    Create a `.env` file in the root directory and add your configuration:
    ```env
    MONGO_URL=your_mongodb_connection_string
    # Add other necessary environment variables here
    ```

4.  **Run the application**
    ```bash
    flutter run
    ```

## 📂 Project Structure

```
lib/
├── business/           # Logic layer (Blocs, Cubits)
├── data/              # Data layer (Models, Repositories, Services)
├── presentation/      # UI layer (Screens, Widgets)
├── style/             # App styling (Colors, Themes, Router)
└── main.dart          # Application entry point
```
