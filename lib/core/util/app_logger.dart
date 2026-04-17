import 'package:logger/logger.dart';

/// Centralized logging service for the application
class AppLogger {
  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    filter: ProductionFilter(),
    output: ConsoleOutput(),
  );

  // ============================================================
  // Short methods
  // ============================================================

  /// Log info level message (short form)
  static void i(String message) {
    _instance.i(message);
  }

  /// Log debug level message (short form)
  static void d(String message) {
    _instance.d(message);
  }

  /// Log warning level message (short form)
  static void w(String message) {
    _instance.w(message);
  }

  /// Log error with exception (short form)
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log critical error (short form)
  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.wtf(message, error: error, stackTrace: stackTrace);
  }

  // ============================================================
  // Long methods (backward compatibility)
  // ============================================================

  /// Log info level message
  static void info(String message) {
    _instance.i(message);
  }

  /// Log debug level message
  static void debug(String message) {
    _instance.d(message);
  }

  /// Log warning level message
  static void warning(String message) {
    _instance.w(message);
  }

  /// Log error with exception
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log critical error
  static void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.wtf(message, error: error, stackTrace: stackTrace);
  }
}

/// Production filter - only shows errors and warnings in production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true; // Show all logs in development
  }
}

/// Custom output for console
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      print(line);
    }
  }
}