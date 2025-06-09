import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  print('Testing TranscriptionOptions serialization...');

  try {
    // Test 1: Create TranscriptionOptions
    print('\n1. Creating TranscriptionOptions...');
    const options = TranscriptionOptions(
      language: 'en',
      diarization: true,
    );
    print('✓ TranscriptionOptions created successfully');

    // Test 2: Serialize to JSON
    print('\n2. Serializing to JSON...');
    final optionsJson = options.toJson();
    print('✓ Serialized successfully: $optionsJson');
    print('✓ Type: ${optionsJson.runtimeType}');

    // Test 3: Create GladiaClient (this might fail without API key)
    print('\n3. Creating GladiaClient...');
    final client = GladiaClient(apiKey: 'test-key', enableLogging: true);
    print('✓ GladiaClient created successfully');

    // Test 4: Try to create a file for testing (will fail but we can see the error)
    print('\n4. Testing transcription without real file...');
    try {
      final dummyFile = File('non-existent-file.mp3');
      await client.transcribeFile(
        file: dummyFile,
        options: options,
      );
    } catch (e, stackTrace) {
      print('Expected error (no file): $e');
      print('Stack trace:\n$stackTrace');
    }
  } catch (e, stackTrace) {
    print('ERROR: $e');
    print('Stack trace:\n$stackTrace');
    exit(1);
  }

  print('\nTest completed!');
}
