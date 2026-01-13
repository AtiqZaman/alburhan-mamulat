# 🕌 Alburhan Mamulat - Islamic Spiritual Development Tracking App

> A comprehensive Flutter application for tracking spiritual progress through structured 40-day learning cycles with role-based guidance system.

## 📱 Overview

**Alburhan Mamulat** is an Islamic spiritual development tracking application that connects:
- **Admins** who manage the system
- **Murabis** (spiritual guides) who assign tasks and approve promotions
- **Salikeens** (students) who complete daily tasks and track progress

## ✨ Key Features

### For Salikeens (Students):
- 📊 Real-time progress tracking across 40-day levels
- 🔥 Streak counting for consecutive days
- ✅ Daily task submission with completion tracking
- 📈 Performance analytics and statistics
- 🏆 Level progression with Murabi approval
- 🎯 Clear goals and milestones

### For Murabis (Guides):
- 👥 Manage assigned Salikeens
- ✅ Review and approve level progressions
- 📊 Performance comparison and rankings
- 🏅 Medal-based rankings (🥇 🥈 🥉)
- 📱 Real-time updates from Salikeens
- 📈 Comprehensive analytics

### For Admins:
- 👤 User management (create Murabis and Salikeens)
- 📚 Level creation and management
- ✏️ Task creation with categories and counts
- 🔗 Murabi-Salik relationship setup

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Android Studio or Android Emulator
- Firebase project configured
- VS Code with Flutter extension

### Installation

1. **Clone/Download the project**
```bash
cd alburhan-mamulat
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Start emulator**
```bash
flutter emulators launch emulator-5554
```

4. **Run the app**
```bash
flutter run -d emulator-5554
```

## 📋 Project Structure

```
lib/
├── services/
│   ├── auth_service.dart        # Firebase authentication
│   ├── firestore_service.dart   # Database operations
│   └── level_service.dart       # Level progression logic
├── models/
│   └── user_models.dart         # Data models
├── screens/
│   ├── auth/                    # Login/Signup
│   ├── admin/                   # Admin dashboard
│   ├── salik/                   # Student interface
│   └── murabi/                  # Guide interface
└── main.dart                    # App entry point
```

## 🔐 Authentication

### Login Credentials (Test)
Create accounts through the signup screen. Accounts are categorized by role:
- **Admin**: Full system access
- **Murabi**: Manage assigned Salikeens
- **Salik**: Track personal progress

## 🗄️ Database Structure

### Firestore Collections:

**users/** - User profiles
```
uid: string
name: string
email: string
role: 'admin' | 'murabi' | 'salik'
level: number
currentDay: number
currentStreak: number
assignedMurabi: string (Murabi's UID)
```

**levels/** - 40-day progression cycles
```
levelNumber: number
levelName: string
daysRequired: number (40)
description: string
```

**tasks/** - Daily activities
```
levelId: string
taskName: string
description: string
category: string
isCountable: boolean
maxCount: number
order: number
```

**dailyUpdates/** - Daily submissions
```
salikId: string
tasksCompleted: {taskId: boolean}
date: timestamp
submittedAt: timestamp
```

**promotionRequests/** - Level progression requests
```
salikId: string
murabiId: string
currentLevel: number
requestedLevel: number
status: 'pending' | 'approved' | 'rejected'
```

## 📊 Daily Workflow

1. **Salik Submits Daily Update**
   - View assigned tasks for current level
   - Check/uncheck completed tasks
   - For countable tasks (e.g., "تکبیر اولیٰ"), enter count
   - Add optional daily notes
   - Submit update

2. **System Processes Update**
   - Increments currentDay counter
   - Updates currentStreak (consecutive days)
   - Recalculates completion percentage
   - Saves to Firestore

3. **Murabi Reviews**
   - See recent updates from Salikeens
   - View performance metrics
   - Approve/reject level progression requests

4. **Level Progression (at 40 days)**
   - Salik requests promotion
   - Murabi approves/rejects
   - On approval: reset to day 1 of next level
   - New tasks appear for new level

## 🎨 UI/UX Features

- 🌙 Dark theme with gradient backgrounds
- ✨ Glassmorphic card design
- 📱 Responsive layout (mobile-first)
- 🇵🇰 Full Urdu support with RTL layout
- ⚡ Real-time Firestore updates
- 🎯 Intuitive navigation

## 🧪 Testing

### Recommended Test Scenarios

1. **Complete 40-Day Cycle**
   - Create Salik account
   - Submit daily updates for 40 days
   - Request and receive promotion
   - Start new level

2. **Multi-Salik Tracking**
   - Login as Murabi
   - View performance of multiple Salikeens
   - Test promotion approval workflow

3. **Analytics Verification**
   - Check streak calculation
   - Verify completion percentage
   - Confirm progress calculations

See `TESTING_GUIDE.md` for detailed test scenarios.

## 🔧 Configuration

### Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create Firestore database
5. Update `google-services.json` in `android/app/`

### Firestore Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Murabis can read their Salikeens
    match /dailyUpdates/{docId} {
      allow create: if request.auth.uid == request.resource.data.salikId;
      allow read: if request.auth.uid == resource.data.salikId || 
                     isMurabiOf(resource.data.salikId);
    }
  }
}
```

## 📱 Building for Production

### Generate APK
```bash
flutter build apk --release
```

### Generate App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### Installation on Device
```bash
flutter install -d <device_id>
```

## 🐛 Troubleshooting

### Common Issues

**App won't build**
```bash
flutter clean
flutter pub get
flutter run
```

**Firestore not syncing**
- Check internet connection
- Verify Firestore rules
- Check user authentication status
- Look at Firebase console for errors

**UI not rendering properly**
- Clear Flutter cache: `flutter clean`
- Rebuild: `flutter run`
- Verify screen orientation is portrait

**Streaks showing zero**
- Ensure daily updates have valid timestamps
- Check timezone settings
- Verify date format in dailyUpdates

## 📚 Dependencies

```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.16.0
cloud_firestore: ^4.17.5
provider: ^6.0.0
intl: ^0.19.0
flutter_local_notifications: ^14.0.0
```

## 🌐 Localization

The app includes:
- **English**: Default interface language
- **Urdu**: Full RTL support with NotoNastaliq font
- **Date formatting**: Localized for Pakistan

## 📞 Support

For issues or questions:
1. Check the [Implementation Guide](IMPLEMENTATION_GUIDE.md)
2. Review [Testing Guide](TESTING_GUIDE.md)
3. Check Firestore console for data structure
4. Verify Firebase configuration

## 📄 License

This project is created for Islamic spiritual development purposes.

## 👥 Contributors

Built as a complete spiritual development tracking solution.

## 🙏 Acknowledgments

Built with ❤️ for the Muslim community to support structured Islamic learning and spiritual growth.

---

## 🚀 Quick Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run -d emulator-5554

# Clean project
flutter clean

# Build release
flutter build apk --release

# Check issues
flutter doctor

# Format code
flutter format lib/

# Analyze code
flutter analyze
```

## 📊 Version History

- **v1.0.0** - Complete implementation with all features
  - Authentication system
  - Admin dashboard
  - Salik interface (dashboard, daily updates, progression)
  - Murabi interface (dashboard, approvals, analytics)
  - Level progression workflow
  - Real-time Firestore sync
  - Beautiful Urdu UI

---

**Status**: ✅ Ready for Testing & Deployment

Built with Flutter 🚀 | Firebase 🔥 | Firestore 💾 | ❤️ For Islamic Development