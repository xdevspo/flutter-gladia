import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  print('=== Gladia SDK Error Diagnosis Tool ===');
  print('This tool will help diagnose the type casting error.\n');

  // Ask for API key
  stdout.write('Enter your Gladia API key: ');
  final apiKey = stdin.readLineSync() ?? '';

  if (apiKey.isEmpty) {
    print('ERROR: API key is required');
    exit(1);
  }

  try {
    print('\n1. Testing TranscriptionOptions serialization...');
    const options = TranscriptionOptions(
      language: 'en',
      diarization: true,
    );

    final json = options.toJson();
    print('✓ Options serialized successfully');
    print('   Type: ${json.runtimeType}');
    print('   Content: $json\n');

    print('2. Creating GladiaClient with detailed logging...');
    final client = GladiaClient(
      apiKey: apiKey,
      enableLogging: true,
    );
    print('✓ Client created successfully\n');

    print('3. Testing file upload with dummy file...');
    try {
      // Create a dummy file for testing
      final dummyFile = File('test.mp3');
      await dummyFile.writeAsBytes([0x49, 0x44, 0x33]); // Basic MP3 header

      await client.transcribeFile(
        file: dummyFile,
        options: options,
      );

      // Clean up
      if (dummyFile.existsSync()) {
        await dummyFile.delete();
      }
    } catch (e, stackTrace) {
      print('Expected error (test file): $e');

      // Check if this is the type casting error
      if (e.toString().contains(
          "type 'String' is not a subtype of type 'Map<String, dynamic>'")) {
        print('\n🔍 FOUND THE ERROR!');
        print('Location: ${_extractErrorLocation(stackTrace)}');
        print('Full stack trace:');
        print(stackTrace);
      } else {
        print(
            'This is a different error (expected since we used a dummy file)');
      }

      // Clean up
      final dummyFile = File('test.mp3');
      if (dummyFile.existsSync()) {
        await dummyFile.delete();
      }
    }
  } catch (e, stackTrace) {
    print('\n❌ UNEXPECTED ERROR: $e');
    print('Stack trace:');
    print(stackTrace);
  }

  print('\n=== Diagnosis Complete ===');
}

String _extractErrorLocation(StackTrace stackTrace) {
  final lines = stackTrace.toString().split('\n');
  for (final line in lines) {
    if (line.contains('.dart:') &&
        (line.contains('gladia') || line.contains('lib/'))) {
      return line.trim();
    }
  }
  return 'Location not found in stack trace';
}
