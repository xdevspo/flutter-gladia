# Gladia API Limitations and Limits

This document contains information about existing limitations when working with the Gladia API, as well as recommendations for working around them.

## Basic Limits

### Free Tier

| Parameter | Limitation |
|-----------|------------|
| Number of concurrent sessions | 1 |
| Monthly request limit | Limited |
| Audio duration | Up to 2 hours |
| File size | Up to 100 MB |

### Paid Plans

On paid plans, the limitations are significantly higher. Exact limits can be seen on the [Gladia pricing page](https://app.gladia.io/pricing).

## Real-time Transcription Limitations

### Maximum Number of Sessions

In the free Gladia API tier, only **one** active real-time transcription session is allowed. When attempting to create a second session, you will receive an error:

```
GladiaApiException: Maximum number of concurrent sessions reached. Your Free Trial plan allows only up to 1 sessions. Please visit https://app.gladia.io/ to upgrade your plan. (Status: 429)
```

#### Solutions

1. **Explicitly Close Sessions**

   Make sure you properly close the session after use:

   ```dart
   // Close WebSocket
   socket.close();
   
   // Close session on the server
   await dio.delete('v2/live/$sessionId');
   ```

2. **Reset All Active Sessions**

   If you encounter an error exceeding the limit, you can reset all active sessions:

   ```dart
   final dio = Dio()
     ..options.baseUrl = 'https://api.gladia.io/'
     ..options.headers = {
       'x-gladia-key': apiKey,
       'Content-Type': 'application/json',
     };
   
   await dio.delete('v2/live/reset');
   ```

3. **Automatic Reset on Application Start**

   It is recommended to add an automatic session reset when starting the application:

   ```dart
   Future<void> resetActiveSessions() async {
     try {
       // Send request to reset all active sessions
       await dio.delete('v2/live/reset');
       print('Active sessions reset');
     } catch (e) {
       print('Error when resetting sessions: $e');
     }
   }
   ```

### Inactivity Duration

If the session does not receive audio data for a certain period (usually 30-60 seconds), it may be automatically closed by the server.

#### Solution

1. **Send Ping Signals**

   During recording pauses, send empty audio frames or special ping messages to maintain the connection.

2. **Reconnect When Disconnected**

   Implement logic for automatic reconnection when a connection break is detected.

### Audio Formats

Not all audio formats are equally well supported by the API. The best results are given by:

- WAV/PCM (16-bit, 16kHz, mono)
- RAW PCM (without headers)

#### Solutions for Audio Format Issues

1. **Use Recommended Parameters**

   ```dart
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

2. **Skip WAV Headers When Reading**

   If you use WAV format, skip the first 44 bytes (WAV header) when sending audio:

   ```dart
   final raf = await file.open(mode: FileMode.read);
   await raf.setPosition(44); // Skip WAV header
   
   final audioBytes = await raf.read(fileLength - 44);
   await raf.close();
   ```

## Network Error Handling

### Request Timeouts

When working with the API, request timeouts can occur, especially with unstable connections.

#### Solution

1. **Set Timeouts for Requests**

   ```dart
   final dio = Dio()
     ..options.baseUrl = 'https://api.gladia.io/'
     ..options.connectTimeout = const Duration(seconds: 10)
     ..options.receiveTimeout = const Duration(seconds: 10)
     ..options.headers = {
       'x-gladia-key': apiKey,
       'Content-Type': 'application/json',
     };
   ```

2. **Handle Timeouts**

   ```dart
   try {
     await dio.delete('v2/live/$sessionId').timeout(
       const Duration(seconds: 5),
       onTimeout: () {
         print('Timeout when closing session');
         return Response(
           requestOptions: RequestOptions(path: 'v2/live/$sessionId'),
           statusCode: 408,
         );
       },
     );
   } catch (e) {
     print('Error when closing session: $e');
   }
   ```

### WebSocket Connection Breaks

WebSocket connections can break for various reasons: network issues, API server restarts, etc.

#### Solution

1. **Handle Connection Close Events**

   ```dart
   socket = gladiaClient.createLiveTranscriptionSocket(
     sessionUrl: sessionResult.url,
     onMessage: handleMessage,
     onDone: () {
       print('Connection closed');
       reconnectWebSocket();
     },
     onError: (error) {
       print('WebSocket error: $error');
       reconnectWebSocket();
     },
   );
   ```

2. **Reconnection Function**

   ```dart
   Future<void> reconnectWebSocket() async {
     if (!shouldReconnect) return;
     
     try {
       print('Attempting to reconnect...');
       socket = gladiaClient.createLiveTranscriptionSocket(
         sessionUrl: sessionResult.url,
         onMessage: handleMessage,
         onDone: () => reconnectWebSocket(),
         onError: (error) => reconnectWebSocket(),
       );
       
       await socket.connect();
       print('Successfully reconnected');
     } catch (e) {
       print('Reconnection error: $e');
       
       // Try again after a delay
       await Future.delayed(Duration(seconds: 3));
       reconnectWebSocket();
     }
   }
   ```

## Processing Large Files

### File Size Limitations

There is a file size limit for uploading to the Gladia API (100MB in the free tier).

#### Solution

1. **Split Large Files**

   For large files, split them into smaller parts and process sequentially:

   ```dart
   Future<String> processLargeFile(File file) async {
     final totalSize = await file.length();
     final partSize = 95 * 1024 * 1024; // 95 MB chunks
     final partsCount = (totalSize / partSize).ceil();
     
     // Create temporary directory for parts
     final tempDir = await Directory.systemTemp.createTemp('gladia_parts');
     
     // Result builder
     final fullTranscription = StringBuffer();
     
     try {
       // Split and process parts
       for (int i = 0; i < partsCount; i++) {
         final partStart = i * partSize;
         final partEnd = min((i + 1) * partSize, totalSize);
         
         print('Processing part ${i + 1} of $partsCount...');
         
         // Create part file
         final partFile = File('${tempDir.path}/part_$i.mp3');
         final partData = await file.openRead(partStart, partEnd).toList();
         await partFile.writeAsBytes(partData.expand((x) => x).toList());
         
         // Process part
         final result = await client.transcribeFile(file: partFile);
         fullTranscription.writeln(result.text);
         
         // Clean up
         await partFile.delete();
       }
       
       return fullTranscription.toString();
     } finally {
       // Delete temporary directory
       await tempDir.delete(recursive: true);
     }
   }
   ```

## Conclusion

When encountering API limitations, always refer to the latest [Gladia API documentation](https://docs.gladia.io/) for the most up-to-date information on limits and best practices. 