# Database Notes

The backend now uses MongoDB Atlas instead of MySQL.

## Collections

### `users`

```json
{
  "_id": "firebase_uid",
  "googleId": "firebase_uid",
  "name": "User Name",
  "email": "user@example.com",
  "profilePicture": "https://...",
  "createdAt": "2026-03-17T00:00:00.000Z",
  "updatedAt": "2026-03-17T00:00:00.000Z"
}
```

### `tasks`

```json
{
  "_id": "mongo_object_id",
  "taskId": 1,
  "userId": "firebase_uid",
  "title": "Buy groceries",
  "description": "Milk and eggs",
  "priority": "medium",
  "category": "Personal",
  "deadline": "2026-03-18T12:00:00.000Z",
  "status": "pending",
  "createdAt": "2026-03-17T00:00:00.000Z",
  "updatedAt": "2026-03-17T00:00:00.000Z"
}
```

### `counters`

```json
{
  "_id": "tasks",
  "seq": 42
}
```

## Recommended Indexes

These are also declared in the Mongoose models:

- `users.email` unique
- `users.googleId`
- `tasks.taskId` unique
- `tasks.userId + status + deadline`
- `tasks.userId + category`

## Environment Variables

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@cluster.mongodb.net/?retryWrites=true&w=majority
MONGODB_DB_NAME=todo_app
```
