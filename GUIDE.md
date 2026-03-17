# Quick Guide

This guide sets up the backend with MongoDB Atlas and the mobile app with Flutter.

## 1. Install Tools

- Flutter SDK
- Node.js 18+
- A MongoDB Atlas account
- A Firebase project with Google Sign-In enabled

## 2. Create MongoDB Atlas Database

1. Log in to MongoDB Atlas.
2. Create a cluster if you do not already have one.
3. In `Database Access`, create a database user and save the username and password.
4. In `Network Access`, allow your current IP address. For development, you can temporarily allow `0.0.0.0/0`.
5. In the cluster, click `Connect` and copy the Node.js connection string.
6. Replace `<username>`, `<password>`, and the database name with your real values.

Example:

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=ToDoApp
MONGODB_DB_NAME=todo_app
```

## 3. Configure the Backend

1. Open the `backend/` folder.
2. Run:

```powershell
npm install
```

3. Create `backend/.env` with:

```env
PORT=3000
MONGODB_URI=YOUR_ATLAS_CONNECTION_STRING
MONGODB_DB_NAME=todo_app
FRONTEND_URL=http://localhost:3000
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account"...}
```

4. Start the backend:

```powershell
npm run dev
```

The API will create its MongoDB collections automatically on first use.

## 4. Run the Flutter App

From the project root:

```powershell
flutter pub get
flutter run
```

## 5. If Something Breaks

- Atlas connection error: check `MONGODB_URI`, database user password, and Atlas IP allowlist.
- Backend starts but sign-in fails: verify your Firebase Admin credentials.
- `mongoose` missing: run `npm install` again inside `backend/`.
