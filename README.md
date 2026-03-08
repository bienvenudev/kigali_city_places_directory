# Kigali City Services & Places Directory

A Flutter mobile app for discovering services and places in Kigali, Rwanda. Users can browse, search, and navigate to hospitals, restaurants, cafés, parks, and more.

## Features

- **Authentication**: Email/password signup with email verification
- **CRUD Operations**: Create, edit, delete your own listings
- **Real-time Sync**: Changes reflect instantly via Firestore streams
- **Search & Filter**: Find listings by name or category
- **Maps Integration**: View locations on embedded Google Maps with navigation
- **User Profiles**: Each user manages their own listings

## Tech Stack

- Flutter 3.10+
- Firebase Authentication
- Cloud Firestore
- Provider (State Management)
- Google Maps Flutter
- Geolocator & URL Launcher

## Firestore Schema

### users collection
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp",
  "notificationsEnabled": "boolean"
}
```

### listings collection
```json
{
  "name": "string",
  "category": "string",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": "number",
  "longitude": "number",
  "createdBy": "string (user UID)",
  "createdAt": "timestamp"
}
```

## Architecture

**State Management: Provider**

```
UI Layer (Screens/Widgets)
    ↓
Provider Layer (AuthProvider, ListingsProvider)
    ↓
Service Layer (AuthService, FirestoreService)
    ↓
Firebase Backend
```

- **Providers** manage state and notify listeners
- **Services** handle all Firebase operations
- **Streams** enable real-time UI updates
- No direct Firebase calls in UI code

## Setup

1. Clone the repo
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Add your Google Maps API key to `AndroidManifest.xml`
5. Run `flutter run`

## Project Structure

```
lib/
├── main.dart
├── models/         # Data models
├── services/       # Firebase operations
├── providers/      # State management
├── screens/        # UI screens
└── widgets/        # Reusable components
```

## Security

Firestore rules enforce that:
- Users can only edit their own profiles
- Users can only edit/delete their own listings
- All operations require authentication

## Assignment Details

This project was built for ALU's Mobile Development course (Individual Assignment 2). It demonstrates:
- Firebase integration (Auth + Firestore)
- Clean architecture with Provider
- Real-time data synchronization
- Google Maps integration with navigation

---

**Author**: Bienvenu Cyuzuzo  
**Repository**: [github.com/bienvenudev/kigali_city_places_directory](https://github.com/bienvenudev/kigali_city_places_directory)  
**Demo Video**: [Youtube Demo Video](https://youtu.be/x3T3Hqbvz-c)  
**individual_assignment 2 document**: [individual_assignment 2](https://docs.google.com/document/d/1BDGpMWTyCLVTU8eRwx8INnWL2wtBz2cPJ4JHs8-Gjqo/edit?usp=sharing)  
