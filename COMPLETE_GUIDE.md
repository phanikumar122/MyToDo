# Complete Guide

This guide is the slow, beginner-friendly version for running the app with MongoDB Atlas.

## Phase 1: What You Are Setting Up

The project has three pieces:

- The Flutter app you run on your phone or emulator
- The Node.js backend that receives API requests
- MongoDB Atlas, which stores users and tasks online

## Phase 2: Create the Database in MongoDB Atlas

1. Go to MongoDB Atlas and create an account.
2. Create a cluster.
3. Open `Database Access` and create a database user.
4. Open `Network Access` and allow your current IP.
5. Click `Connect`, choose the Node.js driver, and copy the connection string.
6. Replace the placeholder username and password in the string with the real ones.

Your backend will use:

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=ToDoApp
MONGODB_DB_NAME=todo_app
```

You do not need to run any SQL file. The backend creates the MongoDB collections automatically.

## Phase 3: Configure the Backend

1. Open a terminal in the `backend/` folder.
2. Run:

```powershell
npm install
```

3. Create a file named `backend/.env`.
4. Put this inside:

```env
PORT=3000
MONGODB_URI=YOUR_ATLAS_CONNECTION_STRING
MONGODB_DB_NAME=todo_app
FRONTEND_URL=http://localhost:3000
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account"...}
```

5. Save the file.
6. Start the backend:

```powershell
npm run dev
```

If the connection works, the server will start and connect to Atlas.

## Phase 4: Run the Flutter App

Go back to the project root and run:

```powershell
flutter pub get
flutter run
```

## Phase 5: What Gets Created in MongoDB

The backend uses:

- `users`
- `tasks`
- `counters`

The `counters` collection is used to keep task IDs numeric so the current Flutter app continues working.

See [backend/database/README.md](/c:/Users/phani/OneDrive/Documents/Projects/ToDo/backend/database/README.md) for the collection shape.

## Phase 6: Common Problems

- `Missing MONGODB_URI environment variable`
  Add `MONGODB_URI` to `backend/.env`.
- Atlas says your IP is blocked
  Add your IP in `Network Access`.
- `Authentication failed`
  Recheck the database username and password in the connection string.
- Google login works but the backend rejects requests
  Recheck the Firebase Admin credentials in `.env`.
