# Gladia

Flutter SDK for working with Gladia API for audio, video, and text content processing.

[![pub package](https://img.shields.io/pub/v/gladia.svg)](https://pub.dev/packages/gladia)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- Audio transcription (both files and streaming)
- Support for various languages and transcription options
- API error handling
- File upload to Gladia server
- Two-stage transcription process (upload + transcription)
- Real-time audio streaming transcription

## Getting Started

### Prerequisites

To use this library, you need:
- A Gladia API key (get one from [Gladia Dashboard](https://app.gladia.io/))
- Flutter project with minimum SDK version 3.0.0

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  gladia: ^0.1.6
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Audio Transcription

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

void main() async {
  // Create client (get API key from Gladia dashboard)
  final client = GladiaClient(apiKey: 'YOUR_API_KEY');
  
  // Path to audio file
  final file = File('path/to/audio/file.mp3');
  
  // Transcribe audio
  final result = await client.transcribeFile(file: file);
  print(result.text);
  
  // Access segments with timestamps
  for (final segment in result.segments!) {
    print('${segment.start} - ${segment.end}: ${segment.text}');
  }
}
```

### Advanced Options

```dart
final result = await client.transcribeFile(
  file: file,
  language: 'ru',
  transcriptionHints: TranscriptionHints(
    speaker_count: 2,
    speaker_detection: true,
  ),
);
```

### Streaming Transcription

```dart
// Start streaming session
final streamingSession = client.startStreamingSession(
  language: 'en',
  onTranscript: (TranscriptionResult result) {
    print('Received: ${result.text}');
  },
  onError: (error) {
    print('Error: $error');
  },
);

// Send audio chunks
final audioChunk = await getAudioChunk(); // Your function to get audio data
await streamingSession.sendAudioChunk(audioChunk);

// When done
await streamingSession.close();
```

## Documentation

For complete API documentation, see the [API Reference](https://docs.gladia.io).

## Examples

The `example` directory contains examples of library usage:

- `main.dart` - basic transcription example
- `console_sync_example.dart` - console example with advanced options
- `live_audio_transcription_example.dart` - streaming transcription example

## Development

### Code Generation

This project uses [json_serializable](https://pub.dev/packages/json_serializable) for generating JSON serialization/deserialization code. After changing models, you need to run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details 