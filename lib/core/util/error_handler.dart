import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'app_logger.dart';


/// Centralized error handling for the entire application
/// Handles different types of errors with appropriate user feedback
class ErrorHandler {


  /// Convert any exception to a user-friendly message
  static String getUserFriendlyException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action.';
        case 'unavailable':
          return 'Service is temporarily unavailable. Please try again.';
        case 'not-found':
          return 'The requested data was not found.';
        case 'already-exists':
          return 'This item already exists.';
        default:
          return 'Firebase error: ${error.message}';
      }
    }
    if (error is TimeoutException) {
      return 'Request timed out. Check your internet connection.';
    }
    if (error is SocketException) {
      return 'No internet connection. Please connect and try again.';
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception:', '').trim();
    }
    return 'An unexpected error occurred. Please try again.';
  }


  /// Handle API/Network errors
  static void handleApiError(dynamic error) {
    AppLogger.error('API Error', error);

    if (error is SocketException) {
      _showErrorSnackbar(
        'Connection Error',
        'No internet connection. Some features may be limited.',
      );
    } else if (error is TimeoutException) {
      _showErrorSnackbar(
        'Request Timeout',
        'The request took too long. Please try again.',
      );
    } else {
      _showErrorSnackbar(
        'Server Error',
        'Something went wrong. Please try again later.',
      );
    }
  }

  /// Handle validation errors
  static void handleValidationError(String message) {
    AppLogger.warning('Validation Error: $message');
    _showErrorSnackbar('Invalid Input', message);
  }

  /// Handle authentication errors
  static void handleAuthError(String message) {
    AppLogger.error('Authentication Error: $message');
    _showErrorSnackbar('Authentication Failed', message);
    // Optionally redirect to login
    Get.offAllNamed('/login');
  }

  /// Handle permission errors
  static void handlePermissionError(String permission) {
    AppLogger.warning('Permission Denied: $permission');
    _showErrorSnackbar(
      'Permission Required',
      'Please grant $permission permission in settings.',
    );
  }

  /// Handle generic errors
  static void handleError(
      String title,
      String message, {
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onRetry,
      }) {
    AppLogger.error('$title: $message');
    _showErrorSnackbar(title, message, duration: duration);
  }

  /// Show error snackbar with consistent styling
  static void _showErrorSnackbar(
      String title,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      duration: duration,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Show success snackbar
  static void showSuccess(
      String title,
      String message, {
        Duration duration = const Duration(seconds: 2),
      }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      duration: duration,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// Show info snackbar
  static void showInfo(
      String title,
      String message, {
        Duration duration = const Duration(seconds: 2),
      }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      duration: duration,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }
}


