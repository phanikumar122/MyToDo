# ToDo App

A full-stack productivity app built with Flutter on the frontend and Node.js on the backend, using Firebase Authentication and MongoDB Atlas for persistence.

## Stack

- Flutter
- Firebase Authentication with Google Sign-In
- Node.js + Express
- MongoDB Atlas + Mongoose

## Project Structure

```text
ToDo/
├── backend/
│   ├── config/
│   │   ├── db.js
│   │   └── firebase.js
│   ├── database/
│   │   └── README.md
│   ├── middleware/
│   │   └── auth.js
│   ├── models/
│   │   ├── counter.js
│   │   ├── task.js
│   │   └── user.js
│   ├── routes/
│   │   ├── tasks.js
│   │   └── users.js
│   ├── package.json
│   └── server.js
├── lib/
├── GUIDE.md
├── COMPLETE_GUIDE.md
├── DEPLOY.md
└── ONLINE.md
```

## Local Setup

### 1. Prerequisites

- Flutter SDK
- Node.js 18+
- A Firebase project with Google Sign-In enabled
- A MongoDB Atlas cluster

### 2. Backend Setup

From the project root:

```powershell
cd backend
npm install
```

Create `backend/.env`:

```env
PORT=3000
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@CLUSTER_URL/?retryWrites=true&w=majority&appName=ToDoApp
MONGODB_DB_NAME=todo_app
FRONTEND_URL=http://localhost:3000
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account"...}
```

The backend creates MongoDB collections automatically. Collection details and recommended indexes are documented in [backend/database/README.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/backend/database/README.md).

Start the API:

```powershell
cd backend
npm run dev
```

### 3. Flutter Setup

```powershell
flutter pub get
flutter run
```

Make sure your Flutter app points to the backend URL configured in `lib/utils/constants.dart`.

## Environment Variables

### Backend

- `MONGODB_URI`: MongoDB Atlas connection string
- `MONGODB_DB_NAME`: Database name inside Atlas, defaults to `todo_app`
- `PORT`: API port, defaults to `3000`
- `FRONTEND_URL`: Allowed CORS origin for web deployments
- `FIREBASE_SERVICE_ACCOUNT` or `FIREBASE_SERVICE_ACCOUNT_JSON`: Firebase Admin credentials

## API Notes

- User IDs remain the Firebase UID.
- Task IDs stay numeric even in MongoDB so the Flutter client and notification logic continue to work without changes.
- The API response shape remains snake_case for compatibility with the existing app models.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Missing MONGODB_URI environment variable` | Add `MONGODB_URI` to `backend/.env` |
| Atlas connection timeout | Check the Atlas connection string, database user password, and IP access list |
| `User not found` after sign-in | Confirm Firebase Admin credentials are valid and the `/api/users` upsert call succeeds |
| `Cannot find module 'mongoose'` | Run `npm install` inside [backend/package.json](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/backend/package.json) |

## Docs

- [GUIDE.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/GUIDE.md): quick local setup
- [COMPLETE_GUIDE.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/COMPLETE_GUIDE.md): beginner-friendly walkthrough
- [DEPLOY.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/DEPLOY.md): deployment guide
- [ONLINE.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/ONLINE.md): short hosted setup notes
