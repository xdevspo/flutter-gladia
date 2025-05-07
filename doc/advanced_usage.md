# Advanced Usage

This section covers advanced features of the Gladia API SDK.

## Real-time Transcription

The SDK supports real-time audio transcription via WebSocket connection.

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'your_api_key');
  LiveTranscriptionSocket? socket;
  
  try {
    // 1. Setup transcription parameters
    final options = LiveTranscriptionOptions(
      encoding: 'pcm',
      sampleRate: 16000,
      language: 'en',
      diarize: true,
      speakerCount: 2,
    );
    
    // 2. Initialize session
    final initResult = await client.initiateLiveTranscription(
      options: options,
    );
    
    // 3. Create WebSocket connection
    socket = client.createLiveTranscriptionSocket(
      websocketUrl: initResult.websocketUrl,
      onTranscriptionResult: (result) {
        // Process received results
        print('Intermediate result: ${result.text}');
        
        if (result.metadata?.isFinal == true) {
          print('Final result: ${result.text}');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('Connection closed');
      },
    );
    
    // 4. Start connection
    await socket.connect();
    
    // 5. Send audio data
    // Example of reading and sending data from a file in chunks
    final audioFile = File('path/to/file.wav');
    final bytes = await audioFile.readAsBytes();
    
    // Send audio in 4096 byte chunks
    final chunkSize = 4096;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      
      // Send audio data to server
      socket.sendAudioData(chunk);
      
      // Simulate streaming with delay
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // 6. End session
    socket.sendEndOfStream();
    
    // Wait for processing of last data
    await Future.delayed(Duration(seconds: 2));
  } catch (e) {
    print('Error: $e');
  } finally {
    // Close connection
    await socket?.close();
  }
}
```

## Capturing and Transcribing Audio from Microphone

For Flutter applications, you can implement capturing and transcribing audio from the microphone:

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class LiveTranscriptionDemo extends StatefulWidget {
  @override
  _LiveTranscriptionDemoState createState() => _LiveTranscriptionDemoState();
}

class _LiveTranscriptionDemoState extends State<LiveTranscriptionDemo> {
  final GladiaClient _client = GladiaClient(apiKey: 'your_api_key');
  final _record = Record();
  
  LiveTranscriptionSocket? _socket;
  bool _isRecording = false;
  String _transcription = '';
  
  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }
  
  Future<void> _startRecording() async {
    // Request permissions
    if (await Permission.microphone.request().isGranted) {
      try {
        // 1. Initialize transcription session
        final initResult = await _client.initiateLiveTranscription(
          options: LiveTranscriptionOptions(
            encoding: 'pcm',
            sampleRate: 16000,
            language: 'en',
          ),
        );
        
        // 2. Create WebSocket connection
        _socket = _client.createLiveTranscriptionSocket(
          websocketUrl: initResult.websocketUrl,
          onTranscriptionResult: (result) {
            setState(() {
              _transcription = result.text;
            });
          },
          onError: (error) {
            print('Error: $error');
          },
        );
        
        // 3. Connect to WebSocket
        await _socket!.connect();
        
        // 4. Configure audio recording
        await _record.start(
          encoder: AudioEncoder.pcm16bits,
          samplingRate: 16000,
          numChannels: 1,
        );
        
        // 5. Start recording and transmitting audio
        setState(() {
          _isRecording = true;
        });
        
        // 6. Start periodic sending of audio data
        _record.onAmplitudeChanged(Duration(milliseconds: 200)).listen((amp) async {
          if (_isRecording && _socket != null) {
            final bytes = await _record.getCurrent();
            if (bytes != null) {
              _socket!.sendAudioData(bytes);
            }
          }
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }
  
  Future<void> _stopRecording() async {
    if (_isRecording) {
      // Stop recording
      await _record.stop();
      
      // Send end of stream signal
      _socket?.sendEndOfStream();
      
      // Close connection
      await _socket?.close();
      _socket = null;
      
      setState(() {
        _isRecording = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-time Transcription')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _transcription.isEmpty ? 'Transcription will appear here...' : _transcription,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isRecording ? null : _startRecording,
                    child: Text('Start Recording'),
                  ),
                  ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : null,
                    child: Text('Stop Recording'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Custom Transcription Options

The SDK supports various transcription options:

```dart
final options = TranscriptionOptions(
  language: 'en',                // Language code (e.g., 'en', 'fr', 'es')
  diarization: true,             // Speaker diarization
  numSpeakers: 2,                // Number of speakers
  interim: true,                 // Return interim results
  punctuate: true,               // Add punctuation
  profanityFilter: false,        // Filter profanity
  smartFormat: true,             // Smart formatting for numbers, dates, etc.
  speakerLabels: true,           // Assign speaker labels
  customVocabulary: [            // Custom vocabulary for better recognition
    'Gladia',
    'API',
    'WebSocket',
    'SDK',
  ],
);

final result = await client.transcribeFile(
  file: file,
  options: options,
);
```

## Creating Multi-language Transcription

For transcribing content with multiple languages:

```dart
// Option 1: Automatic language detection
final result = await client.transcribeFile(
  file: file,
  options: TranscriptionOptions(
    language: 'auto',
    diarization: true,
  ),
);

// Option 2: Specify multiple languages
final result = await client.transcribeFile(
  file: file,
  options: TranscriptionOptions(
    language: 'en,fr,es',  // Priority order
    diarization: true,
  ),
);
```

## Working with Long Files

For long audio files, the SDK provides methods to monitor progress:

```dart
// 1. Upload the file first
final uploadResult = await client.uploadAudioFile(file);

// 2. Initiate transcription with callback
final initResult = await client.initiateTranscription(
  audioUrl: uploadResult.audioUrl,
  options: const TranscriptionOptions(
    diarization: true,
  ),
);

// 3. Poll for results with progress tracking
print('Transcription initiated. Task ID: ${initResult.id}');
print('Waiting for results...');

bool isComplete = false;
int pollCount = 0;

while (!isComplete && pollCount < 60) {  // Limit polling attempts
  pollCount++;
  
  try {
    final result = await client.getTranscriptionResult(
      taskId: initResult.id,
    );
    
    // Success - we have the result
    print('Transcription complete!');
    print('Full text: ${result.text}');
    isComplete = true;
    
  } on GladiaApiException catch (e) {
    if (e.statusCode == 202) {
      // Still processing
      final progress = e.data?['progress'] as double? ?? 0.0;
      print('Processing: ${(progress * 100).toStringAsFixed(1)}%');
      await Future.delayed(Duration(seconds: 3));
    } else {
      // Other error
      print('Error: ${e.message}');
      isComplete = true;  // Exit loop on error
    }
  }
}
```

## Handling Large Segments Output

For long transcriptions, you may need to process segments efficiently:

```dart
final result = await client.transcribeFile(file: file);

// Process segments in batches
final segments = result.segments ?? [];
const batchSize = 50;

for (var i = 0; i < segments.length; i += batchSize) {
  final end = (i + batchSize < segments.length) ? i + batchSize : segments.length;
  final batch = segments.sublist(i, end);
  
  print('Processing batch ${i ~/ batchSize + 1}');
  
  for (final segment in batch) {
    // Process each segment
    final start = segment.start.toStringAsFixed(2);
    final end = segment.end.toStringAsFixed(2);
    final text = segment.text;
    
    print('[$start - $end]: $text');
    
    // Other processing...
  }
}
```

## Customizing HTTP Options

You can customize the HTTP client for special needs:

```dart
import 'package:dio/dio.dart';

// Create a custom Dio instance
final dio = Dio()
  ..options.connectTimeout = Duration(seconds: 30)
  ..options.receiveTimeout = Duration(seconds: 60)
  ..options.headers = {
    'User-Agent': 'MyApp/1.0',
  };

// Add interceptors if needed
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));

// Create client with custom Dio
final client = GladiaClient(
  apiKey: 'your_api_key',
  dio: dio,
);
```

## Optimizing for Mobile Devices

When using the SDK in Flutter mobile apps, consider the following optimizations:

```dart
// 1. Compress audio files before sending
Future<File> compressAudioFile(File inputFile) async {
  // Implementation depends on platform and available libraries
  // This is a placeholder for the actual implementation
  return inputFile;
}

// 2. Monitor network conditions
bool _isNetworkStable() {
  // Implementation depends on network connectivity monitoring
  return true;
}

// 3. Manage API usage
Future<void> transcribeWithBandwidthConsideration(File file) async {
  if (!_isNetworkStable()) {
    print('Network unstable. Consider waiting or using lower quality settings.');
    return;
  }
  
  // Compress if on mobile data
  if (_isOnMobileData()) {
    file = await compressAudioFile(file);
  }
  
  final client = GladiaClient(apiKey: 'your_api_key');
  final result = await client.transcribeFile(file: file);
  print('Transcription: ${result.text}');
}
``` 