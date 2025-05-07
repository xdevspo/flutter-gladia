# Usage Examples

This section presents examples of using the Gladia API SDK for various scenarios.

## Basic File Transcription

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  // Initialize client
  final client = GladiaClient(apiKey: 'your_api_key');
  
  // Path to audio file
  final file = File('path/to/file.mp3');
  
  try {
    // Complete file transcription process
    final result = await client.transcribeFile(file: file);
    
    // Output text
    print('Transcription text: ${result.text}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Step-by-Step Transcription with Custom Options

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // 1. Upload file
    final uploadResult = await client.uploadAudioFile(file);
    print('File uploaded: ${uploadResult.audioUrl}');
    
    // 2. Configure transcription options
    final options = TranscriptionOptions(
      language: 'en',  // Audio language
      diarize: true,   // Speaker identification
      speakerCount: 2, // Expected number of speakers
      paragraphizeSentences: true, // Break into paragraphs
      // Additional settings for diarization
      diarizationConfig: DiarizationConfig(
        minSpeakers: 1,
        maxSpeakers: 3,
      ),
    );
    
    // 3. Initiate transcription
    final initResult = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );
    
    // 4. Get result
    final result = await client.getTranscriptionResult(
      taskId: initResult.id,
    );
    
    // 5. Work with results
    print('Full text: ${result.text}');
    
    // Access speaker information
    if (result.utterances != null) {
      for (final utterance in result.utterances!) {
        print('Speaker ${utterance.speaker}: ${utterance.text}');
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

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final audioUrl = 'https://example.com/audio.mp3';
  
  try {
    // Configure transcription options
    final options = TranscriptionOptions(
      language: 'en',
      subtitles: true,
      subtitlesFormat: 'srt',
    );
    
    // Initiate transcription by URL
    final initResult = await client.initiateTranscription(
      audioUrl: audioUrl,
      options: options,
    );
    
    // Get result
    final result = await client.getTranscriptionResult(
      taskId: initResult.id,
    );
    
    // Work with subtitles
    if (result.metadata?.subtitle != null) {
      print('Subtitles path: ${result.metadata!.subtitle!.url}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Error Handling

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  
  try {
    // Attempt to transcribe non-existent file
    final file = File('non_existent_file.mp3');
    await client.transcribeFile(file: file);
  } on GladiaApiException catch (e) {
    // Handle API errors
    print('API Error: ${e.message}');
    if (e.statusCode != null) {
      print('Status code: ${e.statusCode}');
    }
    if (e.errorCode != null) {
      print('Error code: ${e.errorCode}');
    }
  } catch (e) {
    // Handle other errors
    print('General error: $e');
  }
}
```

## Getting Transcription List

```dart
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  
  try {
    // Get list of all transcriptions
    final transcriptions = await client.getTranscriptionList();
    
    // Output information about transcriptions
    for (final item in transcriptions.items) {
      print('ID: ${item.id}');
      print('Status: ${item.status}');
      print('Created: ${item.createdAt}');
      if (item.resultUrl != null) {
        print('Result URL: ${item.resultUrl}');
      }
      print('---');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Cancel Transcription

```dart
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final audioUrl = 'https://example.com/audio.mp3';
  
  try {
    // Initiate transcription
    final initResult = await client.initiateTranscription(
      audioUrl: audioUrl,
    );
    
    // Cancel transcription
    await client.cancelTranscription(taskId: initResult.id);
    print('Transcription successfully canceled');
  } catch (e) {
    print('Error: $e');
  }
}
```

More complex usage examples, including real-time transcription, are available in the [Advanced Usage](advanced_usage.md) section. 