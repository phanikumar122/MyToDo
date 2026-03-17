# Deploy Guide

This project now uses MongoDB Atlas as the database for both local and hosted environments.

## 1. MongoDB Atlas

Before deploying the backend:

1. Create or reuse an Atlas cluster.
2. Create a dedicated database user for production.
3. Add the deploy platform's outbound IPs to `Network Access`, or temporarily allow wider access while testing.
4. Keep the connection string ready.

Recommended environment variables:

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=ToDoApp
MONGODB_DB_NAME=todo_app
```

## 2. Deploy the Backend

Any Node-friendly host works. The minimum required env vars are:

```env
PORT=3000
MONGODB_URI=YOUR_ATLAS_CONNECTION_STRING
MONGODB_DB_NAME=todo_app
FRONTEND_URL=https://your-frontend-url.example
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account"...}
```

Start command:

```powershell
npm start
```

## 3. Deploy the Flutter App

Deploy as you already prefer for Flutter web or mobile distribution, then point the app to the hosted backend URL in `lib/utils/constants.dart`.

## 4. Deployment Checklist

- Atlas cluster is running
- Atlas database user is valid
- Atlas network access allows your backend host
- `MONGODB_URI` is set
- `MONGODB_DB_NAME` is set or allowed to default to `todo_app`
- Firebase Admin credentials are set
- Frontend URL is allowed by CORS

## 5. Troubleshooting

- Backend crashes on boot: check `MONGODB_URI`.
- Backend cannot reach Atlas: fix the Atlas IP access list.
- Requests fail only in production: check `FRONTEND_URL` and CORS settings.
