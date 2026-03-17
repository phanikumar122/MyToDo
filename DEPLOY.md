# Deployment Guide: Share Your App with Friends

This guide explains how to host your backend in the cloud so it stays online 24/7 (even when your laptop is closed) and how to share the app with your friends.

## Phase 1: Host the Backend (API) on Render

Render is a free-tier friendly platform for hosting Node.js apps.

1.  **Create a GitHub Repository**:
    - Push your `backend/` folder (and the root files if you want) to a new private or public GitHub repository.
    - *Note: Ensure your `node_modules` and `.env` files are in `.gitignore`.*

2.  **Create a Web Service on Render**:
    - Sign in to [Render](https://render.com).
    - Click **New +** > **Web Service**.
    - Connect your GitHub repository.
    - Set the **Root Directory** to `backend`. (If you only pushed the backend folder, leave it blank).
    - **Build Command**: `npm install`
    - **Start Command**: `npm start`

3.  **Add Environment Variables**:
    - In the Render dashboard, go to the **Environment** tab.
    - Add the same variables from your local `.env`:
        - `MONGODB_URI`: Your full MongoDB Atlas connection string.
        - `MONGODB_DB_NAME`: `todo_app`
        - `FIREBASE_SERVICE_ACCOUNT_JSON`: Your full Firebase JSON string (minify it first using a tool if needed).
        - `PORT`: `10000` (Render's default, or leave it and it will use the default).

4.  **Copy Your New URL**:
    - Once deployed, Render will give you a URL like `https://mytodo-backend.onrender.com`.
    - **Important**: Update `lib/utils/constants.dart` in your Flutter project to use this new URL:
      ```dart
      const String kProdUrl = 'https://mytodo-backend.onrender.com/api';
      ```

---

## Phase 2: Share the App with Friends (Android APK)

To let your friends install the app on their Android phones without needing your laptop:

1.  **Change to Production Mode**:
    - In `lib/utils/constants.dart`, ensure `kBaseUrl` is using `kProdUrl`.

2.  **Build the APK**:
    - Open your terminal in the project root.
    - Run:
      ```powershell
      flutter build apk --release
      ```

3.  **Find the File**:
    - After the build finishes, your APK will be at:
      `build/app/outputs/flutter-apk/app-release.apk`

4.  **Share**:
    - Send this `app-release.apk` file to your friends (via WhatsApp, Telegram, Google Drive, etc.).
    - They need to enable "Install from Unknown Sources" on their phones to install it.

---

## Phase 3: Optional - Host as a Web App (Easiest for Sharing)

If your friends don't have Android or don't want to install an APK, you can host the app as a website.

1.  **Build for Web**:
    ```powershell
    flutter build web
    ```

2.  **Host on Netlify or Vercel**:
    - Drag and drop the `build/web` folder into [Netlify Drop](https://app.netlify.com/drop).
    - You will get a link (e.g., `https://my-shiny-todo.netlify.app`) that anyone can open in their browser.

---

## Troubleshooting Cloud Deployment

- **Cold Starts**: On Render's free tier, the backend "sleeps" if not used for 15 minutes. The first request from the app might take 30-60 seconds to wake it up.
- **CORS Error**: If using the Web version, make sure to add your Netlify/Vercel URL to the `ALLOWED_ORIGIN` in the backend's Render environment variables.
