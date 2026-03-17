# Online Setup

## Database

Use MongoDB Atlas.

1. Create a cluster.
2. Create a database user.
3. Allow your app host in `Network Access`.
4. Copy the Node.js connection string.

## Backend Environment

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=ToDoApp
MONGODB_DB_NAME=todo_app
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account"...}
FRONTEND_URL=https://your-frontend-url.example
```

## Notes

- No SQL schema import is needed.
- Collections are created automatically.
- Task IDs stay numeric through the `counters` collection for app compatibility.
