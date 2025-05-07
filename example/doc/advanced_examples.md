# Advanced Usage Examples for Gladia API SDK

This document presents advanced examples of using the Gladia API SDK for various scenarios.

## Speaker Diarization Example (Speaker Identification)

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Setting options with diarization
    final options = TranscriptionOptions(
      diarize: true,       // Enable speaker identification
      speakerCount: 2,     // Expected number of speakers
      diarizationConfig: DiarizationConfig(
        minSpeakers: 1,    // Minimum number of speakers
        maxSpeakers: 3,    // Maximum number of speakers
      ),
    );
    
    // Transcribe file with options
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Output full text
    print('Full text: ${result.text}');
    
    // Output information by speakers
    if (result.utterances != null) {
      for (final utterance in result.utterances!) {
        print('Speaker ${utterance.speaker}: ${utterance.text}');
        print('Time: ${utterance.start} - ${utterance.end}');
        print('---');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Subtitle Generation Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final audioUrl = 'https://example.com/audio.mp3';
  
  try {
    // Configure options for subtitle generation
    final options = TranscriptionOptions(
      language: 'en',
      subtitles: true,            // Enable subtitle generation
      subtitlesFormat: 'srt',     // Subtitle format (srt, vtt)
      subtitlesConfig: SubtitlesConfig(
        maxLineLength: 40,        // Maximum line length
        maxLinesCount: 2,         // Maximum number of lines
        minDuration: 1,           // Minimum subtitle duration (in seconds)
        maxDuration: 7,           // Maximum subtitle duration (in seconds)
      ),
    );
    
    // Initiate transcription
    final initResult = await client.initiateTranscription(
      audioUrl: audioUrl,
      options: options,
    );
    
    // Get result
    final result = await client.getTranscriptionResult(taskId: initResult.id);
    
    // Get subtitle URL
    if (result.metadata?.subtitle != null) {
      final subtitlesUrl = result.metadata!.subtitle!.url;
      print('Subtitles URL: $subtitlesUrl');
      
      // Download subtitle file
      final response = await client.downloadFile(subtitlesUrl);
      final file = File('subtitles.srt');
      await file.writeAsBytes(response.data);
      
      print('Subtitles saved to file subtitles.srt');
      
      // Display subtitle content
      final content = await file.readAsString();
      print('\nExample content:\n');
      print(content.split('\n\n').take(3).join('\n\n'));
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Custom Vocabulary Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Configure custom vocabulary and pronunciation
    final options = TranscriptionOptions(
      language: 'en',
      // Custom vocabulary to improve recognition of specific terms
      customVocabularyConfig: CustomVocabularyConfig(
        terms: [
          'Flutter',
          'Dart',
          'Gladia',
          'SDK',
          'WebSocket',
          'API',
        ],
        phrases: [
          'Flutter Framework',
          'Dart Programming Language',
          'Gladia API',
        ],
      ),
      // Custom pronunciation for abbreviations
      customSpellingConfig: CustomSpellingConfig(
        dictionary: {
          'API': 'A-P-I',
          'SDK': 'S-D-K',
        },
      ),
    );
    
    // Transcribe file with options
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    print('Text: ${result.text}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Transcription with Translation Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Configure options with translation
    final options = TranscriptionOptions(
      language: 'fr',          // Source audio language
      directTranslation: true,
      translation: TranslationConfig(
        target: 'en',          // Target translation language
        model: 'base',         // Translation model
      ),
    );
    
    // Upload and transcribe file
    final uploadResult = await client.uploadAudioFile(file);
    final initResult = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );
    
    final result = await client.getTranscriptionResult(taskId: initResult.id);
    
    // Output original text
    print('Original text: ${result.text}');
    
    // Output translated text
    if (result.translation != null) {
      print('\nTranslated text (EN): ${result.translation!.text}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Callback Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Configure options with callback
    final options = TranscriptionOptions(
      language: 'en',
      callbackConfig: CallbackConfig(
        url: 'https://your-server.com/api/transcription-webhook',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer your-token',
          'Custom-Header': 'custom-value',
        },
      ),
    );
    
    // Upload file
    final uploadResult = await client.uploadAudioFile(file);
    
    // Initiate transcription with callback
    final initResult = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );
    
    print('Transcription started with ID: ${initResult.id}');
    print('Results will be sent to URL: ${options.callbackConfig!.url}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## LLM (Language Model) Integration Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Configure options for LLM integration
    final options = TranscriptionOptions(
      language: 'en',
      // Enable text processing with language model
      audioToLLM: true,
      audioToLLMConfig: AudioToLLMConfig(
        prompt: 'Create a brief summary of the following conversation:',
        model: 'gpt-3.5-turbo',
      ),
    );
    
    // Transcribe file with options
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Output original text
    print('Original text: ${result.text}');
    
    // Output LLM processing results
    if (result.audioToLLM != null) {
      print('\nLLM processing result:');
      print(result.audioToLLM!.result);
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Segmentation and Structured Data Extraction Example

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  final file = File('path/to/file.mp3');
  
  try {
    // Configure structured data extraction
    final options = TranscriptionOptions(
      language: 'en',
      // Enable structured data extraction
      structuredDataExtraction: true,
      structuredDataExtractionConfig: StructuredDataExtractionConfig(
        schema: {
          "type": "object",
          "properties": {
            "customer": {
              "type": "object",
              "properties": {
                "name": {"type": "string"},
                "phone": {"type": "string"},
                "email": {"type": "string"},
              },
              "required": ["name"]
            },
            "order": {
              "type": "object",
              "properties": {
                "number": {"type": "string"},
                "amount": {"type": "number"},
                "items": {
                  "type": "array",
                  "items": {"type": "string"}
                }
              }
            }
          },
          "required": ["customer"]
        },
      ),
    );
    
    // Transcribe file with options
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Output full text
    print('Full text: ${result.text}');
    
    // Output extracted structured data
    if (result.structuredData != null) {
      print('\nExtracted data:');
      print('Customer: ${result.structuredData?['customer']?['name']}');
      print('Phone: ${result.structuredData?['customer']?['phone']}');
      print('Email: ${result.structuredData?['customer']?['email']}');
      
      if (result.structuredData?['order'] != null) {
        print('Order number: ${result.structuredData?['order']?['number']}');
        print('Amount: ${result.structuredData?['order']?['amount']}');
        
        if (result.structuredData?['order']?['items'] is List) {
          print('Items:');
          for (final item in result.structuredData!['order']['items']) {
            print('- $item');
          }
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Real-time Transcription Results Processing

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  
  // Custom transcription results handler
  class TranscriptionHandler {
    String _fullText = '';
    final List<String> _keywords = ['important', 'urgent', 'problem', 'error'];
    
    void onTranscriptionResult(LiveTranscriptionResult result) {
      // Update full text only for final results
      if (result.metadata?.isFinal == true) {
        _fullText += ' ${result.text}';
        print('Final text added: ${result.text}');
        
        // Search for keywords
        for (final keyword in _keywords) {
          if (result.text.toLowerCase().contains(keyword)) {
            print('⚠️ KEYWORD DETECTED: $keyword');
          }
        }
        
        // Save full text to file
        File('transcription_output.txt').writeAsStringSync(_fullText);
      } else {
        // Interim result
        print('Interim: ${result.text}');
      }
    }
    
    String getFullText() => _fullText.trim();
  }
  
  final handler = TranscriptionHandler();
  LiveTranscriptionSocket? socket;
  
  try {
    final options = LiveTranscriptionOptions(
      encoding: 'pcm',
      sampleRate: 16000,
      language: 'en',
      interim: true,
    );
    
    final initResult = await client.initiateLiveTranscription(options: options);
    
    socket = client.createLiveTranscriptionSocket(
      websocketUrl: initResult.websocketUrl,
      onTranscriptionResult: handler.onTranscriptionResult,
      onError: (error) => print('Error: $error'),
      onDone: () => print('Connection closed'),
    );
    
    await socket.connect();
    
    // Read audio file and send data in chunks
    // (in a real application this could be a stream from a microphone)
    final audioFile = File('path/to/file.wav');
    final bytes = await audioFile.readAsBytes();
    
    const chunkSize = 4096; // Chunk size (4KB)
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      
      socket.sendAudioData(chunk);
      
      // Simulate streaming with delay
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // Send end of stream signal
    socket.sendEndOfStream();
    
    // Wait for processing of last data
    await Future.delayed(Duration(seconds: 3));
    
    print('\nFinal text:');
    print(handler.getFullText());
  } catch (e) {
    print('Error: $e');
  } finally {
    // Close connection
    await socket?.close();
  }
}
```

All of the examples above demonstrate the advanced capabilities of the Gladia API. For more information about the API and its parameters, see the [API reference](../doc/api_reference.md) and the [advanced usage guide](../doc/advanced_usage.md). 