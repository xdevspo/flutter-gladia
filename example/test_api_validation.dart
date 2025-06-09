import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  print('=== API Validation Test ===');

  // Ask for API key
  stdout.write('Enter your Gladia API key: ');
  final apiKey = stdin.readLineSync() ?? '';

  if (apiKey.isEmpty) {
    print('ERROR: API key is required');
    exit(1);
  }

  try {
    final client = GladiaClient(
      apiKey: apiKey,
      enableLogging: true,
    );

    // Create a minimal dummy file
    final dummyFile = File('test_audio.mp3');
    await dummyFile.writeAsBytes([
      // Minimal MP3 header
      0xFF, 0xFB, 0x90, 0x00, // MP3 frame header
      ...List.filled(100, 0x00), // Some dummy data
    ]);

    print('\nTesting with minimal options...');
    try {
      await client.transcribeFile(
        file: dummyFile,
        options: const TranscriptionOptions(
          language: 'en',
        ),
      );
    } catch (e) {
      print('Minimal options error: $e\n');
    }

    print('Testing with diarization...');
    try {
      await client.transcribeFile(
        file: dummyFile,
        options: const TranscriptionOptions(
          language: 'en',
          diarization: true,
        ),
      );
    } catch (e) {
      print('Diarization error: $e\n');
    }

    print('Testing with empty options...');
    try {
      await client.transcribeFile(
        file: dummyFile,
        options: const TranscriptionOptions(),
      );
    } catch (e) {
      print('Empty options error: $e\n');
    }

    // Clean up
    if (dummyFile.existsSync()) {
      await dummyFile.delete();
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
