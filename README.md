# Kigali City Services & Places Directory

A Flutter mobile app that allows users to discover and contribute to a directory of services and places in Kigali, Rwanda.

## Features
- User authentication (signup, login, email verification)
- Browse and search listings by category
- Add, edit, and delete your own listings
- View listing details with contact and navigation options
- Leave reviews and ratings
- Location-based services
- Dark mode support

## Firebase Integration
- **Firebase Authentication** - Email/password authentication with email verification
- **Cloud Firestore** - Real-time database for listings and reviews

## Firestore Database Structure
- **users** - User profiles (uid, email, displayName, createdAt)
- **listings** - Place listings (name, category, address, description, contactNumber, latitude, longitude, createdBy, rating, reviewCount)
- **reviews** - User reviews (listingId, userId, userName, rating, comment, createdAt)

## State Management
Provider package is used for state management following the MVVM pattern:
- **AuthProvider** - Manages authentication state
- **ListingProvider** - Manages listings data and filtering
- **SettingsProvider** - Manages app settings

## Architecture
UI ? Provider ? Service ? Firebase
