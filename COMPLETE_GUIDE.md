# 📔 The No-Experience-Required Manual: TaskFlow Deployment

Welcome to the **Master Guide**. This document is designed for someone who has never touched code, never seen a "terminal," and doesn't know what a "database" is. We will go slow, and we will explain everything.

---

## 🧐 Lesson 0: The Dictionary (Read this first!)
Before we start, let's learn the "nerd words" we will be using:
*   **Terminal / Command Prompt**: A window where you type text to tell your computer what to do, instead of clicking icons.
*   **Folder / Directory**: The same thing. A place on your computer that holds files.
*   **Repository (Repo)**: A project folder that is "tracked" so you can upload it to the internet (GitHub).
*   **Backend (The Brain)**: The part of the app that does the math and logic. It's invisible to the user.
*   **Frontend (The Face)**: The actual app you see on your phone or browser.
*   **Database (The Memory)**: Where your names and tasks are saved so they don't disappear when you close the app.
*   **Environment Variables (.env)**: A secret list of passwords the "Brain" needs to work.

---

## 🛠️ Phase 1: The Installation Party
You need to install these 4 things. Do not skip any!

1.  **Node.js**: [Download here](https://nodejs.org/). 
    - Click the button that says **"LTS"**. 
    - Run the installer. Click "Next" until it's finished.
2.  **MySQL Community Server**: [Download here](https://dev.mysql.com/downloads/installer/).
    - Choose the "Web Community" installer.
    - During setup, it will ask for a **Root Password**. **WRITE THIS DOWN ON PAPER.** You cannot reset it easily.
3.  **Flutter**: [Follow this guide](https://docs.flutter.dev/get-started/install/windows).
    - This is a bit long, but just follow the pictures on the Flutter website.
4.  **Android Studio**: [Download here](https://developer.android.com/studio).
    - This installs the "fake phone" (Emulator) we need to see the app.

---

## 💾 Phase 2: Setting up the "Memory" (MySQL)
Your app needs a place to store tasks.

1.  Click your Windows Start button, type **"Command Prompt"**, and open it.
2.  Type this exactly: `mysql -u root -p` and hit Enter.
3.  Type that password you wrote on paper (it will look like you aren't typing anything for security—just type it and hit Enter).
4.  Open the folder where you have this project. Go to `backend/database/`. Right-click `schema.sql` and select **"Open with Notepad"**.
5.  Press `Ctrl + A` to select everything, then `Ctrl + C` to copy.
6.  Go back to that black terminal window, right-click to paste, and hit Enter.
7.  Type `exit` and hit Enter. **Memory setup is done!**

---

## 🧠 Phase 3: Starting the "Brain" (Backend)
The brain needs to wake up before the app can talk to it.

1.  Open a **New Command Prompt**.
2.  We need to go into the backend folder. Type `cd ` (type cd and a space), then **drag the "backend" folder from your file explorer into the terminal window**. It will automatically type the path for you. Hit Enter.
3.  Type `npm install` and hit Enter. Wait for the loading bar to finish.
4.  **The Secret File**: In that `backend` folder, create a new text file. Rename it to exactly `.env`. 
    - Open it with Notepad.
    - Paste this inside:
      ```env
      DB_HOST=localhost
      DB_USER=root
      DB_PASSWORD=YOUR_PAPER_PASSWORD
      DB_NAME=todo_app
      FIREBASE_SERVICE_ACCOUNT_PATH=./config/firebase-service-account.json
      ```
    - Replace `YOUR_PAPER_PASSWORD` with your real MySQL password. Save and close.
5.  **Start it**: Type `node server.js` and hit Enter.
    - If it says **"Server running on port 3000"**, you are a genius! **KEEP THIS WINDOW OPEN.**

---

## 📱 Phase 4: Running the "Face" (The App)
Now for the exciting part!

1.  Open **Android Studio**. Click **"More Actions"** -> **"Virtual Device Manager"**.
2.  Click the blue **"Create Device"** button. Pick a phone (like Pixel 7). Click Next until it's done.
3.  Click the tiny **Play button (▶️)** next to your phone. A phone will appear on your screen! Wait for it to fully turn on.
4.  Open a **Third Command Prompt**.
5.  Type `cd ` and drag the **Main Project Folder** (the one with `pubspec.yaml`) into it. Hit Enter.
6.  Type `flutter pub get` and hit Enter.
7.  Type `flutter run` and hit Enter.
8.  **Wait.** The first time takes about 5 minutes. Eventually, you will see your app on the fake phone!

---

## ☁️ Phase 5: Going Online (The "Eternal" Setup)
If you want the app to work even when your laptop is turned off, you must host it on the internet.

### 1. Online Memory (Aiven)
- Go to [Aiven.io](https://aiven.io/) and make a free account.
- Click **"Create a new service"**. Pick **MySQL**.
- Pick the **"Free"** plan.
- Click **"Create Service"**.
- Once the green light says "Running," copy the **Host**, **User**, and **Password**.

### 2. Online Brain (Render)
- Put your code on **GitHub**.
- Go to [Render.com](https://render.com/). Sign in with GitHub.
- Click **"New +"** -> **"Web Service"**.
- Find your project and click "Connect."
- **Settings**:
    - **Root Directory**: `backend`
    - **Environment Variables**: Add each one from your `.env` file, but use the **Aiven** details instead of "localhost".
- Click **"Create Web Service"**.

### 3. Update the App
- Render will give you a link (e.g., `https://my-brain.onrender.com`).
- Open `lib/utils/constants.dart`.
- Change `kProdUrl` to your new link.

---

## 🚀 Final Check
If something doesn't work:
1.  Is the **Backend Terminal** still open? (It must stay open for local use).
2.  Did you type the **Secret Password** correctly in the `.env` file?
3.  Is the **Fake Phone** turned on?

**You are now a developer!** Enjoy your new To-Do app! 🥇
