# 🏁 Beginner's Guide: Running TaskFlow on Your Computer

Welcome to TaskFlow! This guide is written specifically for beginners. 
We will take you step-by-step through setting up the **Backend (Node.js & MySQL)** and the **Mobile App (Flutter)** so you can run the app on your own computer.

Don't worry if you haven't done this before—just follow the instructions exactly!

---

## 🛠️ Step 1: Install Required Software
Before we can run the code, your computer needs the right tools. Download and install these if you haven't already:

1. **[Node.js](https://nodejs.org/)** (Choose the "LTS" version).
2. **[MySQL Community Server](https://dev.mysql.com/downloads/installer/)** (During setup, it will ask you to create a `root` password. **Remember this password!**)
3. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Follow the official guide for Windows).
4. **[Android Studio](https://developer.android.com/studio)** (Used to run the Android Emulator).

---

## 💾 Step 2: Setup the Database (MySQL)
The app needs a database to store users and tasks.

1. Open a terminal (Command Prompt or PowerShell) and connect to MySQL:
   ```bash
   mysql -u root -p
   ```
2. It will ask for the `root` password you created when installing MySQL. Type it and hit Enter.
3. Now, you are inside MySQL. We need to run the setup script to create the database and tables.
   Find the `schema.sql` file in this project folder: `backend/database/schema.sql`.
4. Copy the entire contents of that `schema.sql` file and paste it into the MySQL terminal window, then hit Enter.
5. *(Optional)* Type `SHOW DATABASES;` and hit Enter to verify that `todo_app` was created! Type `exit` to close MySQL.

---

## 🔥 Step 3: Setup Firebase (For Google Sign-In)
The app uses Google Sign-In, which is managed by a free service called Firebase.

1. Go to the [Firebase Console](https://console.firebase.google.com/) and click **"Add project"**. Name it `TaskFlow App`. 
2. In the left menu, click **Authentication**, click **Get Started**, choose **Google**, and enable it.
3. Keep the Firebase window open for Step 4 and Step 5!

---

## 🖥️ Step 4: Setup and Run the Backend API

The backend is a Node.js server that talks to the database. It lives in the `backend/` folder.

1. Open your terminal and go into the backend folder:
   ```bash
   cd backend
   ```
2. Install the necessary Node packages (like downloading plugins):
   ```bash
   npm install
   ```

### 4.1 Configure Backend Passwords (`.env`)
1. In the `backend/` folder, create a new text file and name it exactly `.env` (don't forget the dot at the start).
2. Open the `.env` file in a text editor like Notepad or VS Code, and paste this inside:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=YOUR_MYSQL_PASSWORD_HERE
   DB_NAME=todo_app
   FIREBASE_SERVICE_ACCOUNT_PATH=./config/firebase-service-account.json
   ```
   *(Change `YOUR_MYSQL_PASSWORD_HERE` to the root password you made during MySQL installation).*

### 4.2 Add Firebase Credentials to the Backend
1. Go back to your Firebase project on the web. Click the **Gear icon (Settings) -> Project Settings**.
2. Click the **Service Accounts** tab.
3. Click the **Generate new private key** button. This downloads a `.json` file.
4. Rename that downloaded file to **`firebase-service-account.json`**.
5. Move that file into your project folder at: `backend/config/firebase-service-account.json`.

### 4.3 Start the Backend!
1. Keep your terminal open in the `backend/` folder and type:
   ```bash
   node server.js
   ```
2. You should see a message saying: `Server running on port 3000`. **Leave this terminal open!** The backend is now alive.

---

## 📱 Step 5: Setup and Run the Mobile App (Flutter)

Now we will get the actual app running on your screen! The app code lives in the `lib/` folder.

### 5.1 Add Firebase Credentials to the App
1. Go back to your Firebase project on the web. Go to **Project Settings -> General**.
2. Click the **Android icon** near the bottom to add an Android app.
3. Under "Android package name", type: `com.todoapp.todo_app`.
4. Click **Register app**, and then click **Download google-services.json**.
5. Move that downloaded file into your project folder at: `android/app/google-services.json`.

### 5.2 Start the Android Emulator
1. Open **Android Studio**.
2. Go to **More Actions -> Virtual Device Manager**.
3. Create a device (like a Pixel 7) and click the **Play button ▶️** to start the emulator. Wait for the fake phone to turn on.

### 5.3 Run the App!
1. Open a **New** terminal window (keep the backend terminal running!).
2. Make sure you are in the main project folder (the folder containing `pubspec.yaml`).
3. Download the Flutter plugins:
   ```bash
   flutter pub get
   ```
4. Finally, tell Flutter to run the app:
   ```bash
   flutter run
   ```
5. Wait a few minutes for it to build for the first time. The app will magically appear on your Android Emulator!

---

## 🎉 Congratulations!
You have successfully set up a full-stack database, API server, and mobile application! 

### Troubleshooting Tips:
- **Red error text in Flutter?** Double check that your `google-services.json` file is in the exact `android/app/` folder.
- **Can't log in?** Ensure your Node.js backend terminal is still open and running without errors. See the **Troubleshooting** section below.
- **Database error in the backend?** Double check your `backend/.env` file password.

---

## 🛠️ How to Fix Login Errors (ApiException 10)

If you see a red box saying `PlatformException(sign_in_failed, ... Api10)`, it means Firebase is rejecting the login because of missing security keys.

### 1. Add SHA Fingerprints to Firebase
1. Go to **Firebase Console -> Project Settings (Gear icon) -> General**.
2. Scroll to **Your apps**, click your Android app.
3. Click **Add fingerprint** and add these two (specific to your computer):
   - **SHA-1:** `5F:C4:DA:50:94:49:C4:4B:BE:EF:D3:D6:A8:0D:A9:A9:F6:27:52:B6`
   - **SHA-256:** `CD:8C:F4:8F:13:27:80:CB:5D:76:8A:A1:94:A8:5A:52:DE:93:97:1E:E5:F8:C7:6B:C7:7A:E3:25:4B:6F:28:EA`

### 2. Set "Support Email"
1. In the same **Project Settings -> General** page, find the **Support email** box.
2. Select your email address from the dropdown. **Login will fail if this is empty.**

### 3. Update the Config File
1. Download the updated `google-services.json` from the same settings page.
2. Replace the old file in `android/app/google-services.json`.

---

