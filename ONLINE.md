# Deploying ToDo Project Online (Free)

Follow these steps to host your Flutter app and Node.js backend online for free. This will ensure the backend stays active and accessible even when your laptop is closed.

---

## 1. Database: [Aiven](https://aiven.io/) or [TiDB Cloud](https://pingcap.com/products/tidb-cloud/)
Choose a free MySQL hosting provider.

1.  **Sign up** for a free account.
2.  **Create a MySQL Instance**.
3.  **Note the Connection Details**:
    *   Host (e.g., `mysql-xxxx.aivencloud.com`)
    *   Port (usually `3306`)
    *   User (e.g., `avnadmin`)
    *   Password
    *   Database Name (e.g., `defaultdb`)
4.  **Import Schema**: Use a tool like MySQL Workbench or the provider's console to run your table creation scripts.

---

## 2. Backend: [Render](https://render.com/)
Render is excellent for hosting Node.js APIs for free.

1.  **Push your code to GitHub**. Make sure the `backend/` folder is at the root or correctly tracked.
2.  **Login to Render** and click **New > Web Service**.
3.  **Connect your GitHub Repository**.
4.  **Configure the Service**:
    *   **Name**: `todo-api`
    *   **Runtime**: `Node`
    *   **Root Directory**: `backend`
    *   **Build Command**: `npm install`
    *   **Start Command**: `node server.js`
5.  **Environment Variables**: Click "Advanced" and add the following:
    *   `DB_HOST`: (Your Aiven Host)
    *   `DB_PORT`: `3306`
    *   `DB_USER`: (Your Aiven User)
    *   `DB_PASSWORD`: (Your Aiven Password)
    *   `DB_NAME`: (Your Aiven DB Name)
    *   `FIREBASE_SERVICE_ACCOUNT_PATH`: `./config/firebase-service-account.json`
6.  **Deploy**: Click "Create Web Service". Once finished, you will get a URL like `https://todo-api.onrender.com`.

---

## 3. Frontend: [Firebase Hosting](https://firebase.google.com/docs/hosting)
Since you already use Firebase, this is the most seamless way to host the app.

1.  **Build Flutter for Web**:
    ```bash
    flutter build web --release
    ```
2.  **Install Firebase CLI**:
    ```bash
    npm install -g firebase-tools
    ```
3.  **Login and Initialize**:
    ```bash
    firebase login
    firebase init hosting
    ```
    *   Select your project.
    *   Set public directory to `build/web`.
    *   Configure as a single-page app: **Yes**.
4.  **Deploy**:
    ```bash
    firebase deploy --only hosting
    ```

---

## 4. Final step: Update API URL
In your Flutter project, update `lib/utils/constants.dart`:

```dart
// OLD: const String kBaseUrl = 'http://10.0.2.2:3000/api';
const String kBaseUrl = 'https://todo-api.onrender.com/api'; // Use your Render URL
```

> [!NOTE]
> Render's free tier "sleeps" if not used for 15 minutes. The first request after a break might take 30-40 seconds to respond.
