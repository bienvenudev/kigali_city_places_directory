import 'package:flutter/material.dart';

// App Theme Colors
class AppColors {
  static const Color primary = Color(0xFF1E3A5F); // Dark blue from UI
  static const Color secondary = Color(0xFFFFC107); // Yellow/Amber
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

// Categories for listings
class ListingCategories {
  static const List<String> categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police station':
        return Icons.local_police;
      case 'library':
        return Icons.local_library;
      case 'restaurant':
        return Icons.restaurant;
      case 'café':
        return Icons.local_cafe;
      case 'park':
        return Icons.park;
      case 'tourist attraction':
        return Icons.attractions;
      case 'utility office':
        return Icons.business;
      default:
        return Icons.place;
    }
  }
}

// Validation patterns
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateCoordinate(String? value, String type) {
    if (value == null || value.isEmpty) {
      return '$type is required';
    }
    final double? coordinate = double.tryParse(value);
    if (coordinate == null) {
      return 'Enter a valid number';
    }
    if (type == 'Latitude' && (coordinate < -90 || coordinate > 90)) {
      return 'Latitude must be between -90 and 90';
    }
    if (type == 'Longitude' && (coordinate < -180 || coordinate > 180)) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }
}
