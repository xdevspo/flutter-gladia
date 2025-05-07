# Error Handling

This section describes possible errors when working with the Gladia API SDK and how to handle them.

## Error Types

The SDK uses the `GladiaApiException` class for all API-related errors.

### GladiaApiException

The main exception class for working with the API.

```dart
GladiaApiException({
  required String message,
  int? statusCode,
  String? errorCode,
  Map<String, dynamic>? data,
})
```

**Fields:**
- `message` - error message
- `statusCode` - HTTP status code
- `errorCode` - Gladia API error code
- `data` - additional error data

## Handling HTTP Request Errors

All API methods can throw exceptions in case of network or API problems:

```dart
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  
  try {
    final result = await client.transcribeFile(file: file);
    print('Transcription successful: ${result.text}');
  } on GladiaApiException catch (e) {
    // Handling API errors
    print('API Error: ${e.message}');
    
    if (e.statusCode != null) {
      if (e.statusCode == 401) {
        print('Invalid API key or authentication problem');
      } else if (e.statusCode == 429) {
        print('Request limit exceeded. Try again later');
      } else if (e.statusCode! >= 500) {
        print('Gladia server error');
      }
    }
    
    if (e.errorCode != null) {
      print('API error code: ${e.errorCode}');
    }
    
    if (e.data != null) {
      print('Additional information: ${e.data}');
    }
  } catch (e) {
    // Handling other errors
    print('Unknown error: $e');
  }
}
```

## Common Error Codes

| Status Code | Description | Recommendations |
|-------------|-------------|----------------|
| 400 | Invalid request | Check request parameters |
| 401 | Authentication problem | Check your API key |
| 403 | Access denied | Check API key permissions |
| 404 | Resource not found | Check task ID or URL |
| 413 | File too large | Reduce file size |
| 415 | Unsupported format | Use supported audio formats |
| 429 | Request limit exceeded | Reduce request frequency |
| 5xx | Server error | Try the request again later |

## File Upload Errors

When uploading files, additional errors may occur:

```dart
try {
  final uploadResult = await client.uploadAudioFile(file);
  print('File uploaded successfully: ${uploadResult.audioUrl}');
} on GladiaApiException catch (e) {
  if (e.statusCode == 413) {
    print('File is too large. Maximum file size: 500MB');
  } else if (e.statusCode == 415) {
    print('Unsupported audio format. Use mp3, wav, ogg, flac, m4a');
  } else {
    print('Error uploading file: ${e.message}');
  }
}
```

## WebSocket Connection Errors

When working with real-time transcription, WebSocket issues may occur:

```dart
final socket = client.createLiveTranscriptionSocket(
  websocketUrl: initResult.websocketUrl,
  onTranscriptionResult: (result) {
    print('Result: ${result.text}');
  },
  onError: (error) {
    print('WebSocket error: $error');
    
    // Example of connection recovery logic
    if (error.contains('connection closed')) {
      _reconnectWebSocket();
    }
  },
  onDone: () {
    print('WebSocket connection closed');
  },
);

// Function to restore connection
Future<void> _reconnectWebSocket() async {
  try {
    print('Restoring connection...');
    // Logic for re-initializing session and connecting
  } catch (e) {
    print('Error restoring connection: $e');
  }
}
```

## Handling Timeouts

When waiting for transcription results, you can configure timeouts:

```dart
try {
  // Configure maximum number of attempts and interval between them
  final result = await client.getTranscriptionResult(
    taskId: taskId,
    maxAttempts: 30,           // Maximum 30 attempts
    retryInterval: Duration(seconds: 3), // 3 second interval
  );
  
  print('Result received: ${result.text}');
} on GladiaApiException catch (e) {
  if (e.message.contains('Timeout')) {
    print('Waiting for result timed out. Check the result later');
    print('Task ID: $taskId');
  } else {
    print('API Error: ${e.message}');
  }
}
```

## Best Practices

1. **Always use a `try-catch` block** to handle possible API errors.

2. **Add timeouts** for network operations:
   ```dart
   final client = GladiaClient(
     apiKey: 'your_api_key',
     dio: Dio()..options.connectTimeout = Duration(seconds: 30),
   );
   ```

3. **Check supported formats** before uploading files:
   ```dart
   final validFormats = ['mp3', 'wav', 'ogg', 'flac', 'm4a'];
   final extension = file.path.split('.').last.toLowerCase();
   
   if (!validFormats.contains(extension)) {
     print('Unsupported format: $extension');
     return;
   }
   ```

4. **Implement retries** for unstable connections:
   ```dart
   Future<T> withRetry<T>(Future<T> Function() operation, {int maxAttempts = 3}) async {
     int attempts = 0;
     while (true) {
       try {
         attempts++;
         return await operation();
       } catch (e) {
         if (attempts >= maxAttempts) rethrow;
         await Future.delayed(Duration(seconds: 2 * attempts));
       }
     }
   }
   
   // Usage
   final result = await withRetry(() => client.transcribeFile(file: file));
   ```

## Example of Comprehensive Error Handling

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> transcribeWithErrorHandling(File file) async {
  final client = GladiaClient(apiKey: 'your_api_key');
  
  // Check file existence
  if (!await file.exists()) {
    print('File does not exist: ${file.path}');
    return;
  }
  
  // Check file size
  final fileSize = await file.length();
  if (fileSize > 500 * 1024 * 1024) {  // 500MB
    print('File is too large: ${fileSize ~/ (1024 * 1024)}MB');
    return;
  }
  
  try {
    // Attempt transcription with retries
    int attempts = 0;
    const maxAttempts = 3;
    
    while (true) {
      try {
        attempts++;
        final result = await client.transcribeFile(file: file);
        print('Transcription successful: ${result.text}');
        break;
      } on GladiaApiException catch (e) {
        // Retry for server errors, but not for client errors
        if (e.statusCode != null && e.statusCode! >= 500 && attempts < maxAttempts) {
          print('Server error, retrying attempt $attempts of $maxAttempts');
          await Future.delayed(Duration(seconds: 2 * attempts));
          continue;
        }
        rethrow;
      }
    }
  } on GladiaApiException catch (e) {
    print('Gladia API Error: ${e.message}');
    if (e.statusCode != null) {
      print('Status code: ${e.statusCode}');
    }
    if (e.errorCode != null) {
      print('Error code: ${e.errorCode}');
    }
  } on SocketException catch (e) {
    print('Connection error: $e');
    print('Check internet connection');
  } on Exception catch (e) {
    print('Unhandled error: $e');
  }
} 