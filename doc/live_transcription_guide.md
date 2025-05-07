# Real-time Transcription Guide with Gladia API

This guide details the process of implementing real-time speech transcription using the Flutter SDK for Gladia API.

## Contents

1. [Introduction](#introduction)
2. [Solution Architecture](#solution-architecture)
3. [Main Steps](#main-steps)
4. [Establishing a Connection](#establishing-a-connection)
5. [Capturing and Sending Audio](#capturing-and-sending-audio)
6. [Processing Results](#processing-results)
7. [Closing the Session](#closing-the-session)
8. [Troubleshooting](#troubleshooting)
9. [Complete Implementation Example](#complete-implementation-example)

## Introduction

Live Transcription is the process of recognizing speech and converting it to text as audio data arrives. Gladia API provides a powerful mechanism for implementing this functionality through a WebSocket connection.

### Key Benefits:

- Low recognition latency
- Multi-language support
- High transcription accuracy
- Support for interim and final results
- Ability to receive additional metadata (diarization, punctuation, etc.)

## Solution Architecture

Real-time transcription is based on the following architecture:

```
    +----------------+          +-------------------+
    |                |  Request |                   |
    | Your app       | -------> | Gladia REST API   |
    |                |          |                   |
    +----------------+          +-------------------+
            |                             |
            | Get URL                     | Create session
            | for WebSocket               |
            v                             v
    +----------------+          +-------------------+
    |                |  Audio   |                   |
    | WebSocket      | -------> | Gladia WebSocket  |
    | Client         |          | Server            |
    |                | <------- |                   |
    |                |  Text    |                   |
    +----------------+          +-------------------+
```

## Main Steps

The real-time transcription process includes the following stages:

1. Session initialization via REST API
2. Establishing a WebSocket connection
3. Recording and sending audio data
4. Receiving and processing transcription results
5. Properly ending the session

## Establishing a Connection

### 1. Session Initialization

The first step is to initialize a session through the Gladia REST API:

```dart
final sessionResult = await gladiaClient.initLiveTranscription(
  sampleRate: 16000,  // Sampling rate in Hz
  bitDepth: 16,       // Sample depth in bits
  channels: 1,        // Number of audio channels (1 = mono)
  encoding: 'wav/pcm', // Audio encoding format
);

// Get session ID and WebSocket URL
final sessionId = sessionResult.id;
final webSocketUrl = sessionResult.url;
```

### 2. Creating a WebSocket Connection

After initializing the session, you need to establish a WebSocket connection:

```dart
final socket = gladiaClient.createLiveTranscriptionSocket(
  sessionUrl: sessionResult.url,
  onMessage: handleTranscriptionMessage,
  onDone: handleConnectionClosed,
  onError: handleConnectionError,
);
```

## Capturing and Sending Audio

### 1. Setting Up Audio Capture

For capturing audio, you can use the `record` package:

```dart
final audioRecorder = AudioRecorder();

// Start recording
await audioRecorder.start(
  RecordConfig(
    encoder: AudioEncoder.wav,
    bitRate: 256000,
    sampleRate: 16000,
    numChannels: 1,
  ),
  path: tempFilePath,
);
```

### 2. Sending Audio Data

Audio is sent through WebSocket. For this, you need to periodically read audio data and send it to the server:

```dart
// Example of periodic audio sending
Timer.periodic(Duration(milliseconds: 300), (timer) async {
  if (!isRecording || socket == null || !socket.isConnected) {
    timer.cancel();
    return;
  }

  try {
    // Read audio data from file
    final file = File(tempFilePath);
    final fileLength = await file.length();
    
    // Skip WAV header (44 bytes)
    final wavHeaderSize = 44;
    
    if (fileLength > wavHeaderSize) {
      final raf = await file.open(mode: FileMode.read);
      await raf.setPosition(wavHeaderSize);
      
      final audioBytes = await raf.read(fileLength - wavHeaderSize);
      await raf.close();
      
      // Send audio data
      socket.sendAudioData(audioBytes);
    }
  } catch (e) {
    print('Error sending audio: $e');
  }
});
```

### 3. Audio Sending Formats

Gladia API supports several formats for sending audio:

- **Binary data** - direct sending of PCM audio via `sendAudioData()`
- **Base64** - encoded audio via `sendBase64AudioData()`

```dart
// Sending binary data
socket.sendAudioData(audioBytes);

// Sending in base64 format
socket.sendBase64AudioData(audioBytes);
```

## Processing Results

### 1. Message Types

The Gladia server sends several types of messages:

- `transcript` - transcription results
- `ready` - server is ready to receive audio
- `error` - error during processing

### 2. Processing Transcription Messages

```dart
void handleTranscriptionMessage(dynamic message) {
  // Processing a transcription message
  if (message is Map<String, dynamic> && message['type'] == 'transcript') {
    final transcriptionMessage = TranscriptionMessage.fromJson(message);
    final text = transcriptionMessage.data.utterance.text;
    final isFinal = transcriptionMessage.data.isFinal;

    if (text.isNotEmpty) {
      if (isFinal) {
        // Processing the final result
        print('Final transcription: $text');
      } else {
        // Processing interim result
        print('Interim transcription: $text');
      }
    }
  } 
  // Processing a ready message
  else if (message is Map<String, dynamic> && message['type'] == 'ready') {
    print('Session ready to receive audio');
  }
  // Processing errors
  else if (message is Map<String, dynamic> && message['type'] == 'error') {
    print('Error from server: ${message['data']}');
  }
}
```

### 3. End-of-Stream Signal

When you finish sending audio, you need to send an end-of-stream signal to the server:

```dart
// Send end-of-stream signal
socket.sendEndOfStream();
```

## Closing the Session

After completing the transcription, close the WebSocket and session:

```dart
// Close WebSocket
await socket.close();

// Close session on server
try {
  await dio.delete('v2/live/$sessionId');
  print('Session successfully closed');
} catch (e) {
  print('Error closing session: $e');
}
```

## Troubleshooting

### Common Problems and Solutions

1. **Connection Issues**

   - Check your internet connection
   - Verify your API key is valid
   - Try resetting all active sessions
   
   ```dart
   await dio.delete('v2/live/reset');
   ```

2. **No Transcription Results**

   - Check audio format and parameters
   - Verify audio data is being sent properly
   - Check audio volume levels

3. **High Latency**

   - Adjust audio chunk size
   - Optimize sending frequency
   - Check your internet connection quality

## Complete Implementation Example

Here's a complete example of implementing real-time transcription in a Flutter application:

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveTranscriptionExample extends StatefulWidget {
  @override
  _LiveTranscriptionExampleState createState() => _LiveTranscriptionExampleState();
}

class _LiveTranscriptionExampleState extends State<LiveTranscriptionExample> {
  // API key
  final String apiKey = 'your_api_key';
  
  // Client and socket
  late GladiaClient gladiaClient;
  LiveTranscriptionSocket? socket;
  
  // Recording
  final record = AudioRecorder();
  String tempFilePath = '';
  bool isRecording = false;
  
  // Transcription
  String transcription = '';
  Timer? sendingTimer;
  
  @override
  void initState() {
    super.initState();
    gladiaClient = GladiaClient(apiKey: apiKey);
    _prepareTempFile();
  }
  
  @override
  void dispose() {
    _stopRecording();
    sendingTimer?.cancel();
    socket?.close();
    super.dispose();
  }
  
  // Prepare temp file for recording
  Future<void> _prepareTempFile() async {
    final tempDir = await getTemporaryDirectory();
    tempFilePath = '${tempDir.path}/temp_audio.wav';
  }
  
  // Start recording and transcription
  Future<void> _startRecording() async {
    // Check microphone permission
    if (await Permission.microphone.request().isGranted) {
      try {
        // 1. Initialize transcription session
        final sessionResult = await gladiaClient.initLiveTranscription(
          options: LiveTranscriptionOptions(
            encoding: 'pcm',
            sampleRate: 16000,
            language: 'en',
          ),
        );
        
        // 2. Create WebSocket
        socket = gladiaClient.createLiveTranscriptionSocket(
          sessionUrl: sessionResult.url,
          onMessage: _handleMessage,
          onDone: () {
            print('Connection closed');
            _reconnectWebSocket(sessionResult.url);
          },
          onError: (error) {
            print('WebSocket error: $error');
            _reconnectWebSocket(sessionResult.url);
          },
        );
        
        // 3. Connect WebSocket
        await socket!.connect();
        
        // 4. Start recording
        await record.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 256000,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: tempFilePath,
        );
        
        // 5. Update state
        setState(() {
          isRecording = true;
          transcription = '';
        });
        
        // 6. Start sending audio data
        sendingTimer = Timer.periodic(Duration(milliseconds: 300), _sendAudioChunk);
        
      } catch (e) {
        print('Error starting recording: $e');
      }
    } else {
      print('Microphone permission denied');
    }
  }
  
  // Stop recording and transcription
  Future<void> _stopRecording() async {
    // Cancel timer
    sendingTimer?.cancel();
    sendingTimer = null;
    
    if (isRecording) {
      // Stop recording
      await record.stop();
      
      // End stream
      socket?.sendEndOfStream();
      
      // Close connection
      await socket?.close();
      socket = null;
      
      // Update state
      setState(() {
        isRecording = false;
      });
    }
  }
  
  // Send audio data
  void _sendAudioChunk(Timer timer) async {
    if (!isRecording || socket == null) {
      timer.cancel();
      return;
    }
    
    try {
      final file = File(tempFilePath);
      if (await file.exists()) {
        final fileLength = await file.length();
        
        // Skip WAV header
        if (fileLength > 44) {
          final raf = await file.open(mode: FileMode.read);
          await raf.setPosition(44);
          
          final audioBytes = await raf.read(fileLength - 44);
          await raf.close();
          
          // Send audio data
          socket!.sendAudioData(audioBytes);
        }
      }
    } catch (e) {
      print('Error sending audio: $e');
    }
  }
  
  // Handle WebSocket messages
  void _handleMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      if (message['type'] == 'transcript') {
        final data = message['data'];
        if (data != null && data['utterance'] != null) {
          final text = data['utterance']['text'];
          final isFinal = data['is_final'] ?? false;
          
          if (text != null && text.isNotEmpty) {
            setState(() {
              if (isFinal) {
                // Add new line for final results
                transcription += text + '\n';
              } else {
                // Replace last line for interim results
                final lines = transcription.split('\n');
                if (lines.isNotEmpty) {
                  lines.removeLast();
                  lines.add(text);
                  transcription = lines.join('\n');
                } else {
                  transcription = text;
                }
              }
            });
          }
        }
      }
    }
  }
  
  // Reconnect WebSocket
  Future<void> _reconnectWebSocket(String url) async {
    if (!isRecording) return;
    
    try {
      print('Attempting to reconnect...');
      socket = gladiaClient.createLiveTranscriptionSocket(
        sessionUrl: url,
        onMessage: _handleMessage,
        onDone: () => _reconnectWebSocket(url),
        onError: (error) => _reconnectWebSocket(url),
      );
      
      await socket!.connect();
      print('Successfully reconnected');
    } catch (e) {
      print('Reconnection error: $e');
      
      // Try again later
      Future.delayed(Duration(seconds: 3), () => _reconnectWebSocket(url));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Transcription'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    transcription.isEmpty ? 'Transcription will appear here' : transcription,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Text(
                isRecording ? 'Stop Recording' : 'Start Recording',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

## Ограничения и рекомендации

1. **Качество сети**: Для стабильной работы транскрипции в реальном времени требуется хорошее интернет-соединение

2. **Формат аудио**: Рекомендуется использовать следующие параметры:
   - Sample rate: 16000 Hz
   - Bit depth: 16 bit
   - Channels: 1 (mono)
   - Encoding: wav/pcm

3. **Управление ресурсами**: Не забывайте закрывать сессии после использования

4. **Размер пакетов**: Оптимальный размер аудио пакетов для отправки - от 4 до 10 Кб

5. **Интервалы отправки**: Рекомендуемый интервал между отправками - от 200 до 500 мс

---

Дополнительную информацию можно найти в официальной документации Gladia API и в исходном коде Flutter SDK.

## См. также

- [Официальная документация Gladia API](https://docs.gladia.io/)
- [Примеры использования Flutter SDK](https://github.com/your-repo/gladia-flutter/tree/main/example)
- [LiveTranscriptionSocket API Reference](https://pub.dev/documentation/gladia/latest/gladia/LiveTranscriptionSocket-class.html) 