<<<<<<< HEAD
# TaskFlow — Personal Productivity To-Do App

A full-stack personal productivity app built with **Flutter** (frontend) and **Node.js + MySQL** (backend), featuring Google Sign-In through Firebase Authentication.

---

## Features

| Feature | Details |
|---------|---------|
| 🔐 Authentication | Google Sign-In via Firebase Auth |
| ✅ Task Management | Create, edit, delete, complete tasks |
| 🏷️ Organization | Custom categories, priority levels, deadlines |
| 📊 Dashboard | Today's tasks, progress ring, overdue alerts |
| 📈 Statistics | Weekly bar chart, completion rate, streak counter |
| 🍅 Focus Mode | Pomodoro timer (25 / 5 / 15 min cycles) |
| 🔔 Notifications | 30 min deadline reminders, session complete alerts |
| 🌙 Theming | Light and Dark mode with persistent preference |

---

## Project Structure

```
TaskFlow/
├── backend/                       # Node.js REST API
│   ├── config/
│   │   ├── db.js                  # MySQL connection pool
│   │   └── firebase.js            # Firebase Admin SDK
│   ├── middleware/
│   │   └── auth.js                # Firebase token verification
│   ├── routes/
│   │   ├── users.js               # User upsert & profile
│   │   └── tasks.js               # Full CRUD + stats
│   ├── database/
│   │   └── schema.sql             # MySQL DDL
│   ├── server.js                  # Express entry point
│   ├── package.json
│   └── .env.example
│
└── lib/                           # Flutter app
    ├── models/                    # UserModel, TaskModel
    ├── services/                  # AuthService, ApiService, NotificationService
    ├── providers/                 # AuthProvider, TaskProvider, ThemeProvider, TimerProvider
    ├── screens/                   # All 9 app screens
    ├── widgets/                   # TaskCard, ProgressRing, PriorityBadge
    └── utils/                     # Theme, Constants
```

---

## Prerequisites

- Flutter SDK `>=3.0.0`
- Node.js `>=18`
- MySQL `>=8.0`
- A Firebase project (free tier is sufficient)

---

## Step 1 — Firebase Setup

> **This step is required.** The app will not compile without a valid `google-services.json`.

1. Go to [Firebase Console](https://console.firebase.google.com) and create a new project.
2. Add an **Android** app → use package name `com.todoapp.todo_app`.
3. Download `google-services.json` → place it at `android/app/google-services.json` (replace the placeholder).
4. Enable **Authentication → Sign-in method → Google**.
5. Download a **Service Account private key**:
   - Firebase Console → Project Settings → Service Accounts → **Generate new private key**
   - Save it as `backend/config/firebase-service-account.json`

---

## Step 2 — MySQL Database Setup

```bash
# Connect to MySQL and run the schema
mysql -u root -p < backend/database/schema.sql
```

This creates the `todo_app` database with `users` and `tasks` tables.

---

## Step 3 — Backend Setup

```bash
cd backend

# Copy env template and fill in your credentials
cp .env.example .env
# Edit .env:
#   DB_HOST=localhost (or use DATABASE_URL=mysql://...)
#   DB_USER=root
#   DB_PASSWORD=<your_mysql_password>
#   DB_NAME=test
#   FIREBASE_SERVICE_ACCOUNT=<your_json_string> (OR use FIREBASE_SERVICE_ACCOUNT_PATH=./config/...)

npm install
node server.js
# → 🚀 To-Do API running on http://localhost:3000
```

To run in development with auto-restart:
```bash
npm run dev
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/users` | Upsert user on sign-in |
| `GET` | `/api/users/me` | Get current user profile |
| `GET` | `/api/tasks` | Get all tasks (filters: status, priority, category) |
| `POST` | `/api/tasks` | Create a task |
| `PUT` | `/api/tasks/:id` | Update a task |
| `DELETE` | `/api/tasks/:id` | Delete a task |
| `GET` | `/api/tasks/stats` | Get productivity statistics |
| `GET` | `/health` | Health check |

All `/api/tasks` and `/api/users/me` routes require: `Authorization: Bearer <Firebase ID Token>`

---

## Step 4 — Flutter Setup

### 4a. Configure API URL

Open `lib/utils/constants.dart` and set the correct `kBaseUrl`:

```dart
// Android emulator → talks to localhost
const String kBaseUrl = 'http://10.0.2.2:3000/api';

// Physical device on same Wi-Fi
// const String kBaseUrl = 'http://192.168.x.x:3000/api';
```

### 4b. Install dependencies

```bash
flutter pub get
```

### 4c. Run the app

```bash
flutter run
```

---

## Step 5 — Android Permissions

The following are automatically included from Flutter packages. Verify `android/app/src/main/AndroidManifest.xml` contains:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

---

## Security Notes

- All API requests **must** contain a valid Firebase ID token.
- The backend verifies tokens with Firebase Admin SDK on every request.
- Task queries are always scoped to `WHERE user_id = <authenticated_uid>`.
- Users **cannot** read, update, or delete another user's tasks.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `google-services.json` not found | Replace `android/app/google-services.json` with real file from Firebase Console |
| MySQL connection refused | Ensure MySQL is running and `.env` credentials are correct |
| `PlatformException: sign_in_failed` | Ensure Google Sign-In is enabled in Firebase and SHA-1 fingerprint is added to Android app |
| `401 Unauthorized` from API | Firebase ID token may have expired — re-login |
| Chart not showing | Complete at least one task to generate stats data |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter 3 + Dart |
| State Management | Provider |
| Authentication | Firebase Auth + Google Sign-In |
| Backend API | Node.js + Express |
| Database | MySQL 8 |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
=======
# MyToDo
A simple and efficient To-Do List mobile application built with Flutter, featuring Google Authentication for secure login. The app helps users manage daily tasks, stay organized, and track productivity with a clean and user-friendly interface.
>>>>>>> 93e5d5604134d0e338b632598ece8ca3dae0c076
