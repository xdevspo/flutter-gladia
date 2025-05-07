# Getting Started with Gladia API SDK

This guide will help you get started with the Gladia API SDK for Dart and Flutter.

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  gladia: ^0.1.0
```

Then run:

```bash
flutter pub get
```

or for Dart projects:

```bash
dart pub get
```

## API Key Setup

To use the Gladia API, you need an API key. Get it from the [Gladia dashboard](https://app.gladia.io/).

## Client Initialization

```dart
import 'package:gladia/gladia.dart';

// Create a client with API key
final client = GladiaClient(
  apiKey: 'your_api_key',
  enableLogging: true, // Optional for debugging
);
```

## Basic File Transcription Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> transcribeAudioFile() async {
  // Initialize client
  final client = GladiaClient(apiKey: 'your_api_key');
  
  // Path to audio file
  final file = File('path/to/audio/file.mp3');
  
  try {
    // Transcribe file (combines all stages in one call)
    final result = await client.transcribeFile(file: file);
    
    // Get full text
    print('Full text: ${result.text}');
    
    // Access segments with timestamps
    if (result.segments != null) {
      for (final segment in result.segments!) {
        print('${segment.start} - ${segment.end}: ${segment.text}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Audio Transcription by URL

```dart
import 'package:gladia/gladia.dart';

Future<void> transcribeAudioUrl() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final audioUrl = 'https://example.com/audio.mp3';
  
  try {
    // Initiate transcription by URL
    final initResult = await client.initiateTranscription(audioUrl: audioUrl);
    
    // Get transcription result
    final result = await client.getTranscriptionResult(taskId: initResult.id);
    
    print('Text: ${result.text}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Next Steps

- Explore [usage examples](usage_examples.md) for more complex scenarios
- Check the [API reference](api_reference.md) for detailed description of all methods
- Learn to work with [live transcription](advanced_usage.md#live-transcription) for real-time audio processing 