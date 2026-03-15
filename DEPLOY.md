# 🚀 The Ultimate "Noob-Proof" Deployment Guide

This guide is for people who have **never** put an app online. We will go through 4 major stages. Each stage has tiny, simple steps. Follow them exactly, and your app will be online by the end of this page.

---

## 🏁 PREREQUISITE: Create a GitHub Account
GitHub is like "Google Drive for code." You must have one to put your app online.
1.  Go to [GitHub.com](https://github.com/) and create a free account.
2.  Install **[GitHub Desktop](https://desktop.github.com/)** on your computer. It makes "uploading code" as easy as dragging and dropping.

---

## 📂 STAGE 1: Upload Your Code to GitHub
We need to get your code from your laptop onto the internet.

1.  Open **GitHub Desktop**.
2.  Click **"File" -> "Add Local Repository"**.
3.  Click **"Browse"** and select your main project folder (the one containing this file).
4.  If it says "This folder does not appear to be a Git repository," click the blue link that says **"Create a repository here"**.
    - Set the name (e.g., `MyToDoApp`).
    - Click **"Create Repository"**.
5.  In the bottom left, look for a box that says **"Summary (required)"**. Type "Initial Upload."
6.  Click the blue button: **"Commit to main"**.
7.  Click the blue button at the top: **"Publish repository"**. 
    - Keep "Keep this code private" **UNCHECKED** (it's easier for free hosting if it's public).
    - Click **"Publish Repository"**.
    - **Result**: Your code is now live at `github.com/your-username/MyToDoApp`!

---

## 💾 STAGE 2: Setting up the Online Memory (TiDB Cloud)
TiDB Cloud provides a powerful free "Serverless" MySQL database.

1.  Go to [TiDB Cloud](https://tidbcloud.com/) and Sign Up (you can use Google or GitHub).
2.  Click **"Create Cluster"**. Select **"Serverless"** (it is the free one).
3.  Choose a region near you (e.g., AWS us-east-1).
4.  Click **"Create"**.
5.  Once the cluster is created, click the **"Connect"** button.
    - Set a **Password** for your database user.
    - Choose **"Connect with SQL Client"** or **"General"**.
6.  **Copy these details**:
    - **Host**: (e.g., `gateway01.us-east-1.prod.aws.tidbcloud.com`)
    - **Port**: `4000` (Note: TiDB often uses 4000 instead of 3306)
    - **User**: (e.g., `xxxxxx.root`)
    - **Password**: (The one you just set)
    - **Database Name**: `test` (or create a new one called `todo_app`)
7.  **Import Schema**:
    - In TiDB Cloud, click **"Chat2Query"** or **"SQL Editor"**.
    - Copy the text from `backend/database/schema.sql` and paste it there.
    - Run the code to create your tables.

---

## 🧠 STAGE 3: Setting up the Online Brain (Render)
Render is where your Node.js "Brain" will live.

1.  Go to [Render.com](https://render.com/) and sign up with your **GitHub account**.
2.  Click the blue **"New +"** button and select **"Web Service"**.
3.  You will see your GitHub project (`MyToDoApp`) in the list. Click **"Connect"**.
4.  **Fill in these exact settings**:
    - **Name**: `todo-backend`
    - **Region**: (Same as your database location if possible)
    - **Root Directory**: `backend`
    - **Runtime**: `Node`
    - **Build Command**: `npm install`
    - **Start Command**: `node server.js`
5.  **Environment Variables**: Click **"Advanced" -> "Add Environment Variable"**. You can now use `DATABASE_URL` (easier) or individual bits from your `.env` file.
    - `DATABASE_URL` = (Your TiDB Connection String - e.g., `mysql://user:pass@host:4000/todo_app`)
    - `FIREBASE_SERVICE_ACCOUNT` = (Paste the minified JSON text of your service account file here)
    - **Note**: The app also supports the old names `DB_HOST`, `DB_PORT`, etc., and `FIREBASE_SERVICE_ACCOUNT_JSON`.
6.  Click **"Create Web Service"**.
7.  **Wait.** Once it finishes, you will see a link at the top (e.g., `https://todo-backend.onrender.com`). **Save this link!**

---

## 📱 STAGE 4: Generating your Mobile App (APK)
Now we create the actual file you can install on any Android phone.

1.  **Update the "Brain" Address**:
    - Open `lib/utils/constants.dart`.
    - Paste your Render link into `kProdUrl` (e.g., `https://todo-backend.onrender.com/api`).
2.  **Generate the App File**:
    - Open your terminal.
    - Run this command: `flutter build apk --release`
3.  **Find your App**:
    - Once finished, go to this folder on your computer:
      `build/app/outputs/flutter-apk/`
    - Look for the file named: **`app-release.apk`**.
4.  **Install it**:
    - Upload this `app-release.apk` to your **Google Drive**.
    - Open Google Drive on your physical phone, download the file, and tap "Install."
    - **Note**: Your phone might say "Unsafe App" because you didn't download it from the Play Store. Click "Install anyway."

---

## 🏆 Checklist for a Perfect Deployment
- [ ] Code is on GitHub?
- [ ] Database is green and "Running"?
- [ ] Every Environment Variable in Render is spelled EXACTLY correct (all caps)?
- [ ] The Render URL ends with `/api` in your Flutter code?

### 🆘 Help! It's not working...
- **"Loading forever?"**: Refresh the page. Render's free Brain takes 30 seconds to wake up.
- **"Database Error?"**: In your database console, ensure you have ran the `schema.sql` code to create the tables. (Use a tool like MySQL Workbench or the built-in SQL Editor to connect and paste the code from `backend/database/schema.sql`).

**Congratulations! You have mastered the art of deployment!** 🎖️🚀
