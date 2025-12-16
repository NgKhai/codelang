# CodeLang

**CodeLang** is a specialized cross-platform application (Mobile/Web) designed to enhance technical English proficiency for developers. It helps users learn and practice English vocabulary and concepts specifically tailored for the software development industry.

<img src="https://github.com/user-attachments/assets/5c8c1f18-8b3c-48c9-aa14-f34cc3097a83"/>

## ✨ Features

-   **Active Lingo Coach (AI Powered)**: Get real-time feedback on your technical communication (clarity, tone, lingo) powered by Google Gemini AI.
-   **Authentication**: Secure Login and Registration system with JWT.
-   **Home Dashboard**: Browse and access various exercise sets.
-   **Unified Exercises**: Interactive exercises to test your knowledge including Multiple Choice and Fill-in-the-blanks.
-   **Flashcards**: Learn technical vocabulary with flip-card animations and text-to-speech support.
-   **Offline Learning**: Download courses and flashcards for offline access.
-   **Profile Management**: Manage your user profile and settings.
-   **Theme Support**: Fully supported Dark and Light modes for comfortable viewing in any environment.

## 🛠 Tech Stack

### 📱 Client (Flutter)
-   **Framework**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
-   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Bloc & Cubit)
-   **Navigation**: [go_router](https://pub.dev/packages/go_router)
-   **Offline Storage**: [hive](https://pub.dev/packages/hive) & [shared_preferences](https://pub.dev/packages/shared_preferences)
-   **Authentication**: Custom Auth with JWT & [google_sign_in](https://pub.dev/packages/google_sign_in)
-   **Networking**: [http](https://pub.dev/packages/http) & [connectivity_plus](https://pub.dev/packages/connectivity_plus)
-   **UI/UX**: [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) & [flutter_tts](https://pub.dev/packages/flutter_tts)

### 🖥️ Server (Node.js)
-   **Runtime**: [Node.js](https://nodejs.org/)
-   **Framework**: [Express.js](https://expressjs.com/)
-   **Database**: [MongoDB](https://www.mongodb.com/) (Native Driver)
-   **AI Integration**: [Google Gemini AI](https://deepmind.google/technologies/gemini/) (@google/generative-ai)
-   **Security**: [helmet](https://www.npmjs.com/package/helmet), [cors](https://www.npmjs.com/package/cors), [bcryptjs](https://www.npmjs.com/package/bcryptjs)
-   **Rate Limiting**: [express-rate-limit](https://www.npmjs.com/package/express-rate-limit)

## 📂 Project Structure

```
codelang/
├── lib/                   # Flutter App Source
│   ├── business/          # Logic layer (Blocs, Cubits)
│   ├── data/              # Data layer (Models, Repositories, Services, Hive Adapters)
│   ├── presentation/      # UI layer (Screens, Widgets, Common Components)
│   └── style/             # App styling (Colors, Themes, Router)
├── server/                # Node.js Backend Source
│   ├── src/
│   │   ├── config/        # DB, Auth configs
│   │   ├── controllers/   # Request handlers (ALC/AI, Auth, User, Data)
│   │   ├── middleware/    # Auth, Validation middlewares
│   │   ├── models/        # Database models
│   │   ├── routes/        # API Routes
│   │   └── server.js      # Entry point
│   └── package.json
└── README.md
```

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.9.2 or higher)
-   [Node.js](https://nodejs.org/) (LTS recommended)
-   MongoDB instance (Local or Atlas)
-   Google Gemini API Key

### Installation

#### 1. Server Setup

Navigate to the server directory and install dependencies:
```bash
cd server
npm install
```

Create a `.env` file in the `server` directory with the following variables:
```env
PORT=3000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_api_key
```

Start the server:
```bash
npm start
# OR for development
npm run dev
```

#### 2. Client Setup

Navigate to the project root and install Flutter dependencies:
```bash
# Return to root if you are in server/
cd ..
flutter pub get
```

Create a `.env` file in the root directory (for the Flutter app):
```env
API_URL=http://localhost:3000/api
# Add other necessary client-side env vars
```

Run the application:
```bash
flutter run
```
