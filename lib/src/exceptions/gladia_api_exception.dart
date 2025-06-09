import 'package:dio/dio.dart';

/// Exception when working with Gladia API
class GladiaApiException implements Exception {
  /// Error message
  final String message;

  /// HTTP status code, if applicable
  final int? statusCode;

  /// Response data, if available
  final Map<String, dynamic>? responseData;

  /// Validation errors, if available
  final List<Map<String, dynamic>>? validationErrors;

  /// Original exception, if available
  final Object? innerException;

  /// Additional message about inner exception
  final String? innerExceptionMessage;

  /// Exception stack trace
  final StackTrace? stackTrace;

  /// Whether the exception includes debug information
  final bool includeDebugInfo;

  /// Creates a new instance of [GladiaApiException]
  GladiaApiException({
    required this.message,
    this.statusCode,
    this.responseData,
    this.validationErrors,
    this.innerException,
    this.innerExceptionMessage,
    this.stackTrace,
    this.includeDebugInfo = false,
  });

  /// Creates exception from Dio error
  factory GladiaApiException.fromDioError(
    DioException error, {
    StackTrace? stackTrace,
    bool includeDebugInfo = false,
  }) {
    int? statusCode;
    Map<String, dynamic>? responseData;
    List<Map<String, dynamic>>? validationErrors;
    String message;

    if (error.response != null) {
      statusCode = error.response!.statusCode;

      try {
        if (error.response!.data is Map<String, dynamic>) {
          responseData = error.response!.data as Map<String, dynamic>;

          // Extract validation errors, if available
          if (responseData.containsKey('validation_errors')) {
            final errorsData = responseData['validation_errors'];
            if (errorsData is List) {
              validationErrors = errorsData
                  .where((e) => e is Map<String, dynamic>)
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
            }
          }

          // Try to extract error message from API response
          if (responseData.containsKey('error')) {
            final errorValue = responseData['error'];
            message = errorValue is String ? errorValue : errorValue.toString();
          } else if (responseData.containsKey('message')) {
            final messageValue = responseData['message'];
            message =
                messageValue is String ? messageValue : messageValue.toString();
          } else if (validationErrors != null && validationErrors.isNotEmpty) {
            // If there are validation errors, include the first one in the message
            message =
                'Validation error: ${_formatValidationError(validationErrors.first)}';
          } else {
            message = 'API error: ${error.message}';
          }
        } else if (error.response!.data is String) {
          // Handle string response data
          final stringData = error.response!.data as String;
          message = 'API error: $stringData';
        } else {
          message =
              'API error: ${error.message} (Response type: ${error.response!.data.runtimeType})';
        }
      } catch (e) {
        // If type casting fails, provide a safe fallback
        message = 'API error: ${error.message} (Failed to parse response: $e)';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'API request timeout exceeded';
    } else {
      message = 'Network error: ${error.message}';
    }

    return GladiaApiException(
      message: message,
      statusCode: statusCode,
      responseData: responseData,
      validationErrors: validationErrors,
      innerException: error,
      stackTrace: stackTrace,
      includeDebugInfo: includeDebugInfo,
    );
  }

  /// Formats validation error to string representation
  static String _formatValidationError(Map<String, dynamic> error) {
    final field = error['field'] ?? 'unknown field';
    final errorMessage = error['message'] ?? 'unknown error';
    return '$field - $errorMessage';
  }

  /// Returns string representation of all validation errors
  String? get formattedValidationErrors {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return null;
    }

    return validationErrors!.map(_formatValidationError).join('\n');
  }

  /// Returns detailed debug information
  String? get debugInfo {
    if (!includeDebugInfo) return null;

    final parts = <String>[];

    if (innerException != null) {
      parts.add('Inner Exception: ${innerException.toString()}');
    }

    if (innerExceptionMessage != null) {
      parts.add('Inner Exception Message: $innerExceptionMessage');
    }

    if (responseData != null) {
      parts.add('Response Data: ${responseData.toString()}');
    }

    if (stackTrace != null) {
      parts.add('Stack Trace:\n${stackTrace.toString()}');
    }

    return parts.isNotEmpty ? parts.join('\n\n') : null;
  }

  @override
  String toString() {
    String result = 'GladiaApiException: $message';

    if (statusCode != null) {
      result += ' (Status: $statusCode)';
    }

    if (validationErrors != null && validationErrors!.isNotEmpty) {
      result += '\nValidation errors:\n$formattedValidationErrors';
    }

    // Always show response data for validation errors to help debugging
    if (statusCode == 400 && responseData != null) {
      result += '\nFull response data: $responseData';
    }

    if (includeDebugInfo && debugInfo != null) {
      result += '\n\n--- Debug Info ---\n$debugInfo';
    }

    return result;
  }
}
