# 📚 StudyShelf

> A gamified study companion built with Flutter, PHP, and MySQL.

StudyShelf is a mobile study app designed to make focused studying a little more fun. Users can start timed study sessions, earn Study Coins, build study streaks, unlock collectible figurines, decorate their personal shelf, and keep track of their study history.

The project was built to explore how a Flutter frontend can communicate with a custom PHP API and MySQL database to create a complete full-stack mobile application.

---

## ✨ Features

### ⏱️ Focus Timer

* Customizable study sessions
* Preset durations from 1 to 60 minutes
* Subject tracking
* Earn **1 Study Coin per minute** of completed study
* Abandon a session without earning coins

### 🔥 Study Streaks

* Automatically tracks consecutive study days
* Streak increases when studying on consecutive days
* Helps encourage consistent study habits

### 🪙 Study Coins

* Earn coins by completing study sessions
* Use coins to unlock collectibles from the Store

### 🛍️ Collectible Store

* Browse available collectibles
* Collectibles have different rarities:

  * Common
  * Rare
  * Epic
  * Legendary
* Each collectible has its own cost
* Owned collectibles are tracked per user

### 🗄️ Personal Shelf

* View unlocked collectibles
* Place collectibles into a 3×3 shelf
* Move or remove collectibles
* Shelf positions are saved to the database

### 📜 Study History

* View previous study sessions
* See the subject, duration, completion status, and date
* Completed and abandoned sessions are visually distinguished

### 🔐 Authentication

* User registration and login
* Passwords are securely hashed using PHP's `password_hash()`
* Authentication uses generated session tokens
* User-specific data is protected through the API

---

## 🛠️ Tech Stack

### Frontend

* **Flutter**
* **Dart**
* Material 3
* `http`
* `shared_preferences`

### Backend

* **PHP**
* REST-style API endpoints
* JSON request/response format

### Database

* **MySQL**
* User accounts
* Study sessions
* Collectibles
* User-owned collectibles
* Shelf positions

### Development Tools

* Android Studio
* VS Code
* XAMPP
* Git / GitHub

---

## 🏗️ Architecture

StudyShelf follows a simple client-server architecture:

```text
┌─────────────────────┐
│   Flutter Android   │
│      App            │
└─────────┬───────────┘
          │
          │ HTTP + JSON
          ▼
┌─────────────────────┐
│      PHP API        │
│     api.php         │
└─────────┬───────────┘
          │
          │ SQL
          ▼
┌─────────────────────┐
│       MySQL         │
│    StudyShelf DB    │
└─────────────────────┘
```

For example, when the Store page loads:

```text
Flutter
   ↓
api('shop')
   ↓
PHP API
   ↓
MySQL collectibles table
   ↓
JSON response
   ↓
Flutter
   ↓
Store UI
```

This same architecture is used for authentication, study sessions, the shelf, and study history.

---

## 📱 Main Screens

### 🔐 Authentication

Users can create an account or log into an existing account.

### ⏱️ Focus

The main study timer where users choose a subject and duration and start a focused study session.

### 🛍️ Store

Users can spend their Study Coins to unlock collectibles.

### 📚 Shelf

Unlocked collectibles can be placed into a 3×3 personal shelf.

### 📜 History

Users can review their previous study sessions.

---

## 🔌 API

The Flutter application communicates with the PHP backend through `api.php`.

Some of the available actions include:

| Action         | Purpose                                      |
| -------------- | -------------------------------------------- |
| `register`     | Create a new account                         |
| `login`        | Authenticate a user                          |
| `me`           | Retrieve the current user's information      |
| `save_session` | Save a study session and award coins         |
| `history`      | Retrieve study history                       |
| `shop`         | Retrieve available collectibles              |
| `unlock`       | Purchase a collectible                       |
| `shelf`        | Retrieve the user's shelf/owned collectibles |
| `place`        | Place or remove a collectible from the shelf |

Requests use JSON and authentication tokens.

Example:

```text
POST /api.php?action=shop
```

---

## 🗃️ Database

The application uses MySQL to store persistent data.

The main entities include:

```text
users
   │
   ├── study_sessions
   │
   └── user_collectibles
              │
              ▼
        collectibles
```

### Users

Stores account information, coins, streaks, and authentication tokens.

### Study Sessions

Stores:

* Subject
* Duration
* Completion status
* Creation date

### Collectibles

Stores the available figurines and their:

* Name
* Rarity
* Cost
* Emoji/image representation

### User Collectibles

Connects users with the collectibles they own and stores their shelf position.

---

## 🚀 Running the Project Locally

### Prerequisites

Install:

* Flutter
* Dart
* Android Studio
* XAMPP
* MySQL
* Git

### 1. Clone the repository

```bash
git clone https://github.com/YOUR-USERNAME/studyshelf.git
cd studyshelf
```

### 2. Set up the Flutter project

```bash
flutter pub get
```

### 3. Set up XAMPP

Place the PHP backend inside:

```text
C:\xampp\htdocs\studyshelf\
```

Make sure Apache and MySQL are running.

### 4. Create the database

Create a MySQL database named:

```text
studyshelf
```

Then import the project's SQL/database structure.

### 5. Configure the API URL

In the Flutter project, update:

```dart
const base = 'http://YOUR-PC-IP/studyshelf/api.php';
```

For Android Emulator, the host machine can typically be accessed through:

```text
http://10.0.2.2/
```

For a physical Android device, use the computer's local network IP address.

> Both the phone and computer need to be reachable on the same network when using a local XAMPP server.

### 6. Run the application

```bash
flutter run
```

---

## 🔒 Security Notes

This project is primarily a learning/development project.

Before deploying it publicly, several areas should be improved, including:

* HTTPS
* Stronger token/session management
* Environment-based database credentials
* Production database configuration
* More restrictive CORS settings
* API rate limiting
* Additional input validation
* Production error handling

Do **not** commit real database passwords, API keys, or production credentials to GitHub.

---

## 🎯 Project Goals

StudyShelf was created to explore practical full-stack mobile development and understand how different technologies work together.

The project covers:

* Flutter UI development
* Dart programming
* Stateful and stateless widgets
* HTTP requests
* JSON
* REST-style APIs
* PHP backend development
* MySQL databases
* Authentication
* CRUD operations
* Persistent application state
* Client-server communication

---

## 📖 What I Learned

Building StudyShelf provided hands-on experience with the complete flow of an application:

```text
User interaction
      ↓
Flutter
      ↓
HTTP request
      ↓
PHP API
      ↓
MySQL
      ↓
PHP response
      ↓
JSON
      ↓
Flutter UI update
```

The project also helped demonstrate how frontend, backend, and database components can work together as one application.

---

## 🚧 Future Improvements

Some possible future improvements include:

* 🎨 Replace emoji collectibles with custom illustrations
* 🧸 Add more collectible characters
* 🏆 Add achievements
* 📊 Add study statistics and charts
* 🔔 Add study reminders
* 🌙 Add dark mode
* 👤 Add profile customization
* ☁️ Deploy the backend to a real server
* 📱 Improve responsive UI
* 🔐 Improve production security
* 🎵 Add optional focus sounds

---

## 👩‍💻 Author

**Busra**

Built as a learning project while exploring Flutter, Dart, PHP, and MySQL.

---

## ⭐ If you found this project interesting

Feel free to explore the code, experiment with it, and build on top of it!
