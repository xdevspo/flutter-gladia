# Live Transcription Example

This document describes an example of using the Gladia API SDK for real-time audio transcription.

## Overview

Real-time transcription allows you to convert speech to text as audio data is received. This is useful for applications that require instant speech processing, such as:

- Live subtitles in video conferences
- Voice control
- Assistive technologies
- Real-time transcription of interviews and meetings

## Example Code (live_audio_transcription_example.dart)

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gladia/gladia.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const LiveTranscriptionApp());
}

class LiveTranscriptionApp extends StatelessWidget {
  const LiveTranscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia Live Transcription Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LiveTranscriptionScreen(),
    );
  }
}

class LiveTranscriptionScreen extends StatefulWidget {
  const LiveTranscriptionScreen({super.key});

  @override
  State<LiveTranscriptionScreen> createState() => _LiveTranscriptionScreenState();
}

class _LiveTranscriptionScreenState extends State<LiveTranscriptionScreen> {
  final GladiaClient _client = GladiaClient(
    apiKey: dotenv.env['GLADIA_API_KEY'] ?? '',
    enableLogging: true,
  );

  LiveTranscriptionSocket? _socket;
  final _recorder = Record();
  bool _isRecording = false;
  String _transcriptionText = '';
  String _status = 'Ready to start';
  String _errorMessage = '';

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _errorMessage = 'Microphone access is required for this app to work';
      });
      return;
    }
  }

  Future<void> _startRecording() async {
    try {
      // Request permissions
      await _requestPermissions();
      if (_errorMessage.isNotEmpty) return;

      setState(() {
        _status = 'Initializing session...';
        _transcriptionText = '';
      });

      // 1. Initialize transcription session
      final options = LiveTranscriptionOptions(
        encoding: 'pcm',
        sampleRate: 16000,
        bitDepth: 16,
        language: 'en',
        diarize: true,
        speakerCount: 2,
        interim: true, // Get interim results
      );

      final initResult = await _client.initiateLiveTranscription(
        options: options,
      );

      setState(() {
        _status = 'Connecting to WebSocket...';
      });

      // 2. Create WebSocket connection
      _socket = _client.createLiveTranscriptionSocket(
        websocketUrl: initResult.websocketUrl,
        onTranscriptionResult: (result) {
          setState(() {
            _transcriptionText = result.text;
            
            if (result.metadata?.isFinal == true) {
              _status = 'Final result received';
            } else {
              _status = 'Transcription in progress...';
            }
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'WebSocket error: $error';
            _isRecording = false;
          });
        },
        onDone: () {
          setState(() {
            _status = 'Connection closed';
            _isRecording = false;
          });
        },
      );

      // 3. Start connection
      await _socket!.connect();

      setState(() {
        _status = 'Starting audio recording...';
      });

      // 4. Configure audio recording
      await _recorder.start(
        encoder: AudioEncoder.pcm16bits,
        samplingRate: 16000,
        numChannels: 1,
      );

      setState(() {
        _isRecording = true;
        _status = 'Recording and transcription active';
      });

      // 5. Start periodic audio data retrieval and sending
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amp) async {
        if (_isRecording && _socket != null) {
          try {
            final buffer = await _recorder.getCurrent();
            if (buffer != null) {
              _socket!.sendAudioData(buffer);
            }
          } catch (e) {
            print('Error getting audio data: $e');
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting recording: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      setState(() {
        _status = 'Finishing recording...';
      });

      // Stop recording
      await _recorder.stop();

      // Send end of stream signal
      _socket?.sendEndOfStream();

      // Wait for final processing
      await Future.delayed(const Duration(seconds: 2));

      // Close connection
      await _socket?.close();
      _socket = null;

      setState(() {
        _isRecording = false;
        _status = 'Recording completed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $_status',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Record button
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Text(
                _isRecording ? 'Stop Recording' : 'Start Recording',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            
            // Transcription area
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _transcriptionText.isEmpty
                          ? 'Speak after pressing the record button...'
                          : _transcriptionText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## How It Works

The real-time transcription process consists of the following steps:

1. **Session Initialization**:
   ```dart
   final options = LiveTranscriptionOptions(
     encoding: 'pcm',
     sampleRate: 16000,
     bitDepth: 16,
     language: 'en',
     diarize: true,
     speakerCount: 2,
     interim: true, // Get interim results
   );
   
   final initResult = await _client.initiateLiveTranscription(options: options);
   ```

2. **WebSocket Connection Creation**:
   ```dart
   _socket = _client.createLiveTranscriptionSocket(
     websocketUrl: initResult.websocketUrl,
     onTranscriptionResult: (result) {
       // Process result
     },
     onError: (error) {
       // Handle errors
     },
     onDone: () {
       // Handle completion
     },
   );
   
   // Start connection
   await _socket!.connect();
   ```

3. **Microphone Audio Recording**:
   ```dart
   await _recorder.start(
     encoder: AudioEncoder.pcm16bits,
     samplingRate: 16000,
     numChannels: 1,
   );
   ```

4. **Sending Audio Data**:
   ```dart
   _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amp) async {
     if (_isRecording && _socket != null) {
       final buffer = await _recorder.getCurrent();
       if (buffer != null) {
         _socket!.sendAudioData(buffer);
       }
     }
   });
   ```

5. **Receiving Transcription Results**:
   ```dart
   onTranscriptionResult: (result) {
     setState(() {
       _transcriptionText = result.text;
       
       if (result.metadata?.isFinal == true) {
         _status = 'Final result received';
       } else {
         _status = 'Transcription in progress...';
       }
     });
   },
   ```

6. **Ending the Session**:
   ```dart
   // Stop recording
   await _recorder.stop();
   
   // Send end of stream signal
   _socket?.sendEndOfStream();
   
   // Close connection
   await _socket?.close();
   ```

## Setup

To run this example, you'll need:

1. **Gladia API key** — Add it to a `.env` file:
   ```
   GLADIA_API_KEY=your_api_key
   ```

2. **Dependencies** — Add the following packages to your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     gladia: ^0.1.0
     record: ^5.0.0
     permission_handler: ^10.0.0
     flutter_dotenv: ^5.0.2
   ```

3. **Permissions** — Add microphone access permission:
   - Android (`android/app/src/main/AndroidManifest.xml`):
     ```xml
     <uses-permission android:name="android.permission.RECORD_AUDIO" />
     <uses-permission android:name="android.permission.INTERNET" />
     ```
   
   - iOS (`ios/Runner/Info.plist`):
     ```xml
     <key>NSMicrophoneUsageDescription</key>
     <string>This app needs microphone access for speech transcription</string>
     ```

## Important Parameters

When configuring real-time transcription, pay attention to the following parameters:

1. **encoding** — Audio encoding format (`pcm`, `opus`, `wav`)
2. **sampleRate** — Sampling rate (usually 16000 Hz)
3. **bitDepth** — Bit depth (16 bit for PCM)
4. **interim** — Receiving interim results
5. **language** — Audio language
6. **diarize** — Speaker identification

## Common Issues and Solutions

1. **Issue**: Cannot access microphone  
   **Solution**: Check permission settings in the manifest and add permission request in code

2. **Issue**: WebSocket connection error  
   **Solution**: Check internet connection and verify API key correctness

3. **Issue**: Poor recognition quality  
   **Solution**: Set the correct language and check input audio quality

4. **Issue**: High latency  
   **Solution**: Reduce the size of audio chunks being sent or their frequency

## Additional Information

- [Live Transcription Guide](../../doc/live_transcription_guide.md)
- [API Reference](../../doc/api_reference.md)
- [Error Handling](../../doc/error_handling.md) 