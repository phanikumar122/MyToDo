# Deploying ToDo Project Online (Free)

Follow these steps to host your Flutter app and Node.js backend online for free. This will ensure the backend stays active and accessible even when your laptop is closed.

---

## 1. Database: [TiDB Cloud](https://tidbcloud.com/) or [Clever Cloud](https://www.clever-cloud.com/)
Since Aiven has high demand, **TiDB Cloud** is the best free alternative.

1.  **Sign up** for TiDB Cloud Serverless.
2.  **Create a Cluster** (Select the Free/Serverless option).
3.  **Click Connect**: note the Host, User, Port (usually 4000), and Password.
4.  **Import Schema**: Use the built-in "SQL Editor" in the TiDB console to run your `schema.sql`.

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
    *   `DATABASE_URL`: (Your Connection String - easier!)
    *   `FIREBASE_SERVICE_ACCOUNT`: (Paste the minified JSON text here)

> [!TIP]
> To get the correct single-line JSON for Render, run this command in your `backend` folder:
> `node scripts/minify-firebase.js`
> Copy the output and paste it into Render.
6.  **Deploy**: Click "Create Web Service". Once finished, you will get a URL like `https://todo-api.onrender.com`.

---

## 3. Frontend: Mobile App (APK Build)
Instead of a website, we will build a real Android application file.

1.  **Build the APK**:
    ```bash
    flutter build apk --release
    ```
2.  **Location**: Your app file is at `build/app/outputs/flutter-apk/app-release.apk`.
3.  **Install**: Move this file to your phone and install it manually.

---

## 4. Final step: Update API URL
Before building the APK, ensure `lib/utils/constants.dart` has your **Render** URL:

```dart
const String kProdUrl = 'https://todo-api.onrender.com/api'; 
```

> [!NOTE]
> Render's free tier "sleeps" if not used for 15 minutes. The first request after a break might take 30-40 seconds to respond.
