# HireMe — Firebase Setup Guide

## Step 1: Create Firebase Project

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login
firebase login

# Create project (or use an existing one)
npx firebase-tools@latest projects:create hireme-app
```

## Step 2: Enable Authentication

Go to [Firebase Console → Authentication → Sign-in method](https://console.firebase.google.com/project/_/authentication/providers) and enable:
- ✅ **Phone** (for OTP — primary for Indian workers)
- ✅ **Email/Password** (for email login)
- ✅ **Google** (for social login)

## Step 3: Create Firestore Database

```bash
# List available locations
npx firebase-tools@latest firestore:locations

# Create Firestore (choose asia-south1 for India)
npx firebase-tools@latest firestore:databases:create "(default)" --location="asia-south1"
```

## Step 4: Add Android App & Download Config

1. Go to [Firebase Console → Project Settings → Your apps](https://console.firebase.google.com/project/_/settings/general/)
2. Click **Add app → Android**
3. Package name: `com.hireme`
4. Download `google-services.json`
5. Place it at: `hire_me/android/app/google-services.json`

## Step 5: Uncomment Firebase Init in main.dart

In [`lib/main.dart`](lib/main.dart), uncomment:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

And run FlutterFire CLI to generate `firebase_options.dart`:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=hireme-4aec7
```

## Step 6: Deploy Security Rules & Indexes

```bash
# In the hire_me/ directory
npx firebase-tools@latest deploy --only firestore:rules,firestore:indexes
```

## Step 7: Run the App

```bash
flutter run
```

---

## Firestore Data Structure

```
/users/{uid}
  name, phone, email, role, profilePhotoUrl, address,
  location (GeoPoint), geohash, createdAt
  [Worker]: skillCategory, experienceYears, idProofUrl, isAvailable

/job_requests/{jobId}
  customerId, customerName, categoryId, categoryName,
  title, description, location (GeoPoint), address, geohash,
  status (pending → accepted → in_progress → completed/cancelled),
  workerId, workerName, photoUrls[], createdAt, estimatedBudget
```

## Security Rules Summary

| Collection | Who can read | Who can write |
|-----------|-------------|--------------|
| `users/{uid}` | Owner only (PII protected) | Owner only; role is immutable; server fields blocked |
| `job_requests` | Any authenticated user | Customer creates; customer/worker updates with valid transitions |

> ⚠️ These are **prototype** security rules. Review carefully before a public launch.
