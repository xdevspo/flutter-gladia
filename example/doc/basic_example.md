# Basic Gladia API SDK Usage Example

This example demonstrates the basic process of transcribing an audio file using the Gladia API SDK.

## Example Code

File `main.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gladia Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GladiaClient client = GladiaClient(
    apiKey: dotenv.env['GLADIA_API_KEY'] ?? '',
    enableLogging: true,
  );

  String _transcriptionResult = '';
  bool _isLoading = false;

  Future<void> _transcribeAudio() async {
    setState(() {
      _isLoading = true;
      _transcriptionResult = '';
    });

    try {
      // Use the provided test audio file
      final file = File('audio_file.mp3');
      
      // Simple API call for file transcription
      final result = await client.transcribeFile(
        file: file,
        language: 'en', // Specify audio language
      );
      
      setState(() {
        _transcriptionResult = result.text;
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _transcribeAudio,
                  child: const Text('Transcribe Audio'),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _transcriptionResult.isEmpty
                        ? 'Press the button to transcribe audio'
                        : _transcriptionResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Explanation

The example demonstrates the process of audio file transcription using the Gladia API. Here are the main steps:

1. **Initialize the Gladia API client**:
   ```dart
   final GladiaClient client = GladiaClient(
     apiKey: dotenv.env['GLADIA_API_KEY'] ?? '',
     enableLogging: true,
   );
   ```

2. **Create a file instance**:
   ```dart
   final file = File('audio_file.mp3');
   ```

3. **Start transcription**:
   ```dart
   final result = await client.transcribeFile(
     file: file,
     language: 'en', // Specify audio language
   );
   ```

4. **Display the result**:
   ```dart
   setState(() {
     _transcriptionResult = result.text;
   });
   ```

## Project Setup

1. **Get an API key** from the [Gladia dashboard](https://app.gladia.io/)

2. **Create a `.env` file** in the project root with the following content:
   ```
   GLADIA_API_KEY=your_api_key
   ```

3. **Add dependencies** to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     gladia: ^0.1.0
     flutter_dotenv: ^5.0.2
   ```

4. **Prepare the audio file**:
   - Place an audio file named `audio_file.mp3` in the project root directory, or
   - Change the file path in the code

5. **Run the application**:
   ```bash
   flutter run
   ```

## Execution Result

When the transcription is successful, you will see the transcribed audio text in the application interface.

## Additional Possibilities

This simple example can be extended:

- Add a **file picker** to select files
- Configure **additional transcription parameters**, such as:
  ```dart
  final options = TranscriptionOptions(
    diarize: true,        // Speaker identification
    speakerCount: 2,      // Number of speakers
    paragraphizeSentences: true,  // Break into paragraphs
  );
  
  final result = await client.transcribeFile(
    file: file,
    language: 'en',
    options: options,
  );
  ```
- Display **transcription metadata**, such as segments with timestamps

## Possible Errors

- **Invalid API key**: Check the API key in the `.env` file
- **File not found**: Make sure the path to the audio file is correct
- **Unsupported format**: Make sure the file has a supported format (mp3, wav, ogg, flac, m4a)
- **Network issues**: Check internet connection

## Useful Links

- [Gladia API Documentation](../doc/api_reference.md)
- [Error Handling](../doc/error_handling.md)
- [Advanced Examples](advanced_examples.md) 