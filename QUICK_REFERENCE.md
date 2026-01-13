#!/bin/bash

# 🕌 Alburhan Mamulat - Quick Reference Guide

## 🚀 QUICK START

# 1. Get dependencies
flutter pub get

# 2. Start emulator (if not running)
flutter emulators launch emulator-5554

# 3. Run app
flutter run -d emulator-5554

# 4. Watch for changes (auto-hot-reload)
flutter run -d emulator-5554 --hot

## 🧹 CLEANING & TROUBLESHOOTING

# Clean everything
flutter clean
flutter pub get
flutter run -d emulator-5554

# Check doctor
flutter doctor

# Analyze code issues
flutter analyze

# Format code
flutter format lib/

## 📦 BUILDING

# Build debug APK
flutter build apk --debug

# Build release APK (final)
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Install on device
flutter install -d emulator-5554

## 🔍 TESTING

# Run all tests
flutter test

# Run specific test file
flutter test test/services/level_service_test.dart

# Run with coverage
flutter test --coverage

## 📱 DEVICE MANAGEMENT

# List all devices
flutter devices

# List emulators
flutter emulators

# Run on specific device
flutter run -d <device_id>

## 🔧 CONFIGURATION

# Update dependencies
flutter pub upgrade

# Add new package
flutter pub add package_name

# Get specific version
flutter pub get

# Check pubspec.yaml
cat pubspec.yaml

## 📊 FIRESTORE SETUP

# 1. Go to Firebase Console: https://console.firebase.google.com
# 2. Create new project: "Alburhan Mamulat"
# 3. Enable Authentication:
#    - Email/Password
# 4. Create Firestore Database:
#    - Start in test mode
#    - Select region (nearest to you)
# 5. Download google-services.json
# 6. Move to android/app/google-services.json
# 7. Verify in android/build.gradle:
#    - Has com.google.gms:google-services classpath
# 8. Verify in android/app/build.gradle:
#    - Apply com.google.gms.google-services plugin

## 🎯 TEST SCENARIOS

# SCENARIO 1: Create admin user
# 1. Launch app
# 2. Click "إنشاء حساب" (Create Account)
# 3. Enter: name, email, password
# 4. Check "مدیر" (Admin) - auto selected first user
# 5. Click "إنشاء حساب" (Create Account)

# SCENARIO 2: Create Murabi
# 1. Login as admin
# 2. Click "مربی شامل کریں" (Add Murabi)
# 3. Enter: Name (مربی احمد), Email, Phone
# 4. Click "شامل کریں" (Add)
# 5. Verify in Firebase Console: users collection

# SCENARIO 3: Create Salik
# 1. Click "سالک شامل کریں" (Add Salik)
# 2. Enter: Name (سالک علی), Email, Phone
# 3. Select Murabi from dropdown
# 4. Click "شامل کریں" (Add)
# 5. Verify in Firebase Console

# SCENARIO 4: Create Level
# 1. Click "لیول منتظم کریں" (Manage Levels)
# 2. Click "لیول شامل کریں" (Add Level)
# 3. Enter:
#    - Level Name: "لیول اول"
#    - Level Number: 1
#    - Days Required: 40
#    - Description: "بنیادی معمولات"
# 4. Click "شامل کریں" (Add)

# SCENARIO 5: Create Tasks
# 1. Click "کام منتظم کریں" (Manage Tasks)
# 2. Select level
# 3. Click "کام شامل کریں" (Add Task)
# 4. Enter task details
# 5. Check "شمار ہو" if countable
# 6. Click "شامل کریں" (Add)

# SCENARIO 6: Test 40-day flow
# 1. Logout, login as Salik
# 2. See dashboard with Day 1/40
# 3. Click "روزانہ تبدیلی" (Daily Update)
# 4. Check some tasks
# 5. Click "تبدیلی بھیجیں" (Submit)
# 6. Go back to dashboard
# 7. See Day 2/40 (incremented)
# 8. Repeat 38 more times...
# 9. At Day 40, see "✓ منظوری کے لیے تیار"
# 10. Click "میری کارکردگی" (My Performance)
# 11. Click "منظوری کی درخواست" (Request Approval)

# SCENARIO 7: Test Murabi approval
# 1. Logout, login as Murabi
# 2. Click "منظوری" tab
# 3. See pending request
# 4. Click "منظور کریں" (Approve)
# 5. See success message
# 6. Request disappears

# SCENARIO 8: Test promotion result
# 1. Logout, login as Salik
# 2. Dashboard now shows Level 2, Day 1/40
# 3. See new tasks for Level 2

## 🔐 FIREBASE SECURITY RULES (PRODUCTION)

# Paste this in Firestore Rules tab:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow read: if isAdmin() || isMurabi();
    }
    
    match /dailyUpdates/{document=**} {
      allow create: if request.auth.uid == request.resource.data.salikId;
      allow read: if request.auth.uid == resource.data.salikId || 
                     isMurabiOf(resource.data.salikId);
    }
    
    match /promotionRequests/{document=**} {
      allow create: if request.auth.uid == request.resource.data.salikId;
      allow read: if request.auth.uid == resource.data.murabiId ||
                     request.auth.uid == resource.data.salikId;
      allow update: if request.auth.uid == resource.data.murabiId;
    }
    
    match /levels/{document=**} {
      allow read;
      allow write: if isAdmin();
    }
    
    match /tasks/{document=**} {
      allow read;
      allow write: if isAdmin();
    }
    
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isMurabi() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'murabi';
    }
    
    function isMurabiOf(salikId) {
      return get(/databases/$(database)/documents/users/$(salikId)).data.assignedMurabi == request.auth.uid;
    }
  }
}
*/

## 📺 SCREENS TO CHECK

# Admin Dashboard
# Location: lib/screens/admin/admin_dashboard.dart
# Tests: Create Murabi, Salik, Levels, Tasks

# Salik Dashboard (Enhanced)
# Location: Artifact "enhanced_salik_dashboard"
# Tests: Progress tracking, streak, status

# Murabi Dashboard (Enhanced)
# Location: Artifact "enhanced_murabi_dashboard"
# Tests: View Salikeens, approvals, performance

# Daily Update
# Location: lib/screens/salik/salik_daily_update_screen.dart
# Tests: Submit tasks, see increment

# Level Progression
# Location: lib/screens/salik/level_progression_screen.dart
# Tests: Day counter, eligibility, request

## 🗂️ IMPORTANT FILES

# Services
# - lib/services/auth_service.dart
# - lib/services/firestore_service.dart
# - lib/services/level_service.dart (NEW)

# Models
# - lib/models/user_models.dart (NEW)

# Main file
# - lib/main.dart

# Database structure documented in:
# - README.md
# - IMPLEMENTATION_GUIDE.md
# - BUILD_SUMMARY.md

## 🐛 DEBUG TIPS

# View logs
flutter run -d emulator-5554 2>&1 | grep 'flutter'

# Check Firebase in console
# Go to: https://console.firebase.google.com
# Select project
# Go to Firestore Database
# View collections: users, levels, tasks, dailyUpdates, promotionRequests

# Check auth
# Go to Firebase Console
# Authentication tab
# View created users

# Check app performance
flutter run --profile -d emulator-5554

## 📞 COMMON ISSUES

# "No emulator found"
flutter emulators
flutter emulators launch emulator-5554

# "Permission denied"
chmod +x gradlew

# "Build failed"
flutter clean
flutter pub get
flutter run -d emulator-5554

# "Firestore not updating"
- Check internet connection
- Check Firebase console for data
- Verify authentication
- Check Firestore rules (test mode)

# "Urdu text not showing"
- Verify NotoNastaliq font in pubspec.yaml
- Check fontFamily: 'NotoNastaliq'
- Font should be in assets/fonts/

## 🚀 RELEASE CHECKLIST

# Before release:
- [ ] Test all 8 scenarios
- [ ] Verify Firestore data
- [ ] Check UI on different devices
- [ ] Test with multiple users
- [ ] Verify performance
- [ ] Check error handling
- [ ] Review security rules
- [ ] Test on real device

# Build release:
flutter build apk --release

# Install on device:
flutter install -d <device_id>

# Upload to Play Store (optional):
# Use Android Studio or
# Go to Google Play Console

## 📚 DOCUMENTATION FILES

README.md
  - Overview
  - Features
  - Installation
  - Structure
  - Testing
  - Troubleshooting

IMPLEMENTATION_GUIDE.md
  - Setup guide
  - Testing checklist
  - Debugging tips
  - Firestore structure
  - Security rules
  - Next steps

BUILD_SUMMARY.md
  - What was built
  - File structure
  - Data flow
  - Feature list
  - Ready status

## ✨ KEY FEATURES RECAP

✅ 40-day level progression
✅ Day counter auto-increment
✅ Streak calculation
✅ Completion percentage
✅ Promotion workflow
✅ Real-time Firestore sync
✅ Beautiful Urdu UI
✅ Role-based access
✅ Performance analytics
✅ Murabi approval system

## 🎯 YOU'RE READY TO:

1. ✅ Test the application
2. ✅ Generate APK
3. ✅ Deploy on device
4. ✅ Submit to Play Store
5. ✅ Gather user feedback
6. ✅ Make improvements

---

**Happy testing! 🎉**

For detailed guides, see:
- README.md
- IMPLEMENTATION_GUIDE.md
- BUILD_SUMMARY.md
