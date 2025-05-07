# Gladia

Flutter SDK for working with Gladia API for audio, video, and text content processing.

## Features

- Audio transcription (both files and streaming)
- Support for various languages and transcription options
- API error handling
- File upload to Gladia server
- Two-stage transcription process (upload + transcription)

## Installation

```yaml
dependencies:
  gladia: ^0.1.0
```

## Usage

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

void main() async {
  // Create client (get API key from Gladia dashboard)
  final client = GladiaClient(apiKey: apiKey);
  
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

## Development

### Code Generation

This project uses [json_serializable](https://pub.dev/packages/json_serializable) for generating JSON serialization/deserialization code. After changing models, you need to run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## API Documentation

### Main Methods

- `uploadAudioFile` - upload audio file to Gladia server
- `initiateTranscription` - request transcription by URL
- `getTranscriptionResult` - get transcription result
- `transcribeFile` - complete file transcription process (all stages)

## Examples

The `example` directory contains examples of library usage:

- `main.dart` - basic transcription example
- `console_sync_example.dart` - console example with advanced options
- `live_audio_transcription_example.dart` - streaming transcription example

## License

MIT 