# Kigali City Services & Places Directory

A comprehensive Flutter mobile application for discovering and managing services and places in Kigali, Rwanda. This app helps residents locate essential public services and leisure locations including hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions.

## Features

### Authentication
- ✅ Email/password authentication via Firebase Auth
- ✅ Email verification requirement
- ✅ Secure login/logout
- ✅ User profile management in Firestore

### Listings Management (CRUD)
- ✅ Create new service/place listings
- ✅ View all listings in a shared directory
- ✅ Update your own listings
- ✅ Delete your own listings
- ✅ Real-time synchronization with Firestore

### Search & Filter
- ✅ Search listings by name
- ✅ Filter by category (Hospital, Police, Library, Restaurant, Café, Park, etc.)
- ✅ Combined search and filter functionality

### Maps Integration
- ✅ Google Maps integration with location markers
- ✅ Embedded maps on listing detail pages
- ✅ Turn-by-turn navigation to selected locations
- ✅ Map view showing all listings

### User Experience
- ✅ Bottom navigation with 4 main screens
- ✅ Material Design UI
- ✅ Real-time updates across the app
- ✅ Location-based notifications toggle (settings)
- ✅ Profile information display

## Screenshots

The app includes:
- Login/Signup screens
- Email verification flow
- Directory with search and category filters
- Listing detail pages with embedded maps
- My Listings management screen
- Add/Edit listing forms
- Map view with all locations
- Settings screen with profile info

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Navigation**: URL Launcher

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── user_model.dart           # User data model
│   └── listing_model.dart        # Listing data model
├── services/
│   ├── auth_service.dart         # Firebase Authentication logic
│   └── firestore_service.dart    # Firestore CRUD operations
├── providers/
│   ├── auth_provider.dart        # Authentication state management
│   └── listings_provider.dart    # Listings state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── directory/
│   │   ├── directory_screen.dart
│   │   └── listing_detail_screen.dart
│   ├── my_listings/
│   │   ├── my_listings_screen.dart
│   │   └── add_edit_listing_screen.dart
│   ├── map/
│   │   └── map_view_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   └── listing_card.dart         # Reusable listing card widget
└── utils/
    └── constants.dart            # App constants and validators
```

## Firebase Firestore Database Structure

### Collections

#### `users`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp",
  "notificationsEnabled": "boolean"
}
```

#### `listings`
```json
{
  "name": "string",
  "category": "string",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": "number",
  "longitude": "number",
  "createdBy": "string (userId)",
  "createdAt": "timestamp"
}
```

## State Management Architecture

The app uses **Provider** for state management, following a clean architecture pattern:

### Data Flow
```
UI Layer (Screens/Widgets)
    ↓
Provider Layer (ChangeNotifier)
    ↓
Service Layer (Firebase operations)
    ↓
Firebase Backend
```

### Key Principles
- UI widgets never directly call Firebase APIs
- All backend operations go through service classes
- Providers expose data and methods to UI via Consumer/Provider.of
- Real-time updates automatically propagate through streams
- Loading and error states handled consistently

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Firebase CLI
- Android Studio / VS Code
- Android emulator or physical device

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/bienvenudev/kigali-city-places-directory.git
   cd kigali_city_places_directory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password authentication
   - Create a Firestore database in test mode
   - Run `flutterfire configure` and select your project
   - The `firebase_options.dart` file will be auto-generated

4. **Google Maps API Setup**
   - Get an API key from [Google Cloud Console](https://console.cloud.google.com)
   - Enable Maps SDK for Android and iOS
   - Add the API key to:
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/AppDelegate.swift`

5. **Run the app**
   ```bash
   flutter run
   ```

## Firestore Security Rules

Apply these security rules in your Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    
    // Listings collection
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null 
        && request.resource.data.createdBy == request.auth.uid;
      allow update: if request.auth != null 
        && resource.data.createdBy == request.auth.uid;
      allow delete: if request.auth != null 
        && resource.data.createdBy == request.auth.uid;
    }
  }
}
```

## Key Features Explanation

### Authentication Flow
1. User signs up with email/password
2. Verification email sent automatically
3. User must verify email before accessing app
4. User profile created in Firestore upon signup

### Listings CRUD
- **Create**: Any authenticated user can create listings
- **Read**: All users can view all listings
- **Update**: Users can only update their own listings
- **Delete**: Users can only delete their own listings

### Real-time Updates
- Uses Firestore streams for automatic UI updates
- No manual refresh needed
- Changes propagate instantly across all screens

### Search & Filter
- Client-side filtering for instant results
- Category-based filtering
- Name-based search
- Can combine both filters

## Dependencies

```yaml
dependencies:
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  provider: ^6.1.2
  google_maps_flutter: ^2.9.0
  geolocator: ^13.0.2
  url_launcher: ^6.3.1
  intl: ^0.19.0
```

## Known Issues & Solutions

### Issue: Google Maps not showing
- **Solution**: Ensure API key is properly configured in AndroidManifest.xml
- Enable Maps SDK for Android/iOS in Google Cloud Console

### Issue: Location permissions denied
- **Solution**: Grant location permissions in device settings
- Request permissions at runtime via geolocator package

### Issue: Email verification not working
- **Solution**: Check spam folder for verification email
- Ensure Firebase Auth is properly configured

## Development Notes

- Uses Provider for clean separation of concerns
- Firestore streams for real-time data
- Form validation throughout
- Error handling with user-friendly messages
- Responsive UI design
- Material Design guidelines followed

## Testing the App

1. Sign up with a test email
2. Verify email (check inbox/spam)
3. Login with verified credentials
4. Create a test listing with Kigali coordinates
5. Test search and filter functionality
6. View listing on map
7. Test navigation to location
8. Update and delete your listing
9. Toggle notification settings
10. Logout and login again

## Future Enhancements

- [ ] Add user ratings and reviews
- [ ] Implement favorites/bookmarks
- [ ] Add photos to listings
- [ ] Push notifications for nearby places
- [ ] Offline mode with local caching
- [ ] Admin panel for moderation

## Contributing

This is an academic project for ALU. Contributions are welcome for learning purposes.

## License

MIT License - Feel free to use for educational purposes.

## Author

**Bienvenu Dev**
- GitHub: [@bienvenudev](https://github.com/bienvenudev)

## Acknowledgments

- African Leadership University
- Firebase & Flutter Teams
- Google Maps Platform

---

**Made with ❤️ for Kigali**
