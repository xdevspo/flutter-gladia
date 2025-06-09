import 'package:test/test.dart';
import 'package:gladia/gladia.dart';

void main() {
  group('Serialization Tests', () {
    test('TranscriptionOptions.toJson() should return Map<String, dynamic>',
        () {
      const options = TranscriptionOptions(
        language: 'en',
        diarization: true,
      );

      print('DEBUG: Creating TranscriptionOptions...');
      final json = options.toJson();
      print('DEBUG: toJson() result: $json');
      print('DEBUG: Type: ${json.runtimeType}');

      expect(json, isA<Map<String, dynamic>>());
      expect(json['language'], equals('en'));
      expect(json['diarization'], equals(true));
    });

    test('TranscriptionOptions with all options should serialize correctly',
        () {
      const options = TranscriptionOptions(
        language: 'en',
        diarization: true,
        translation: true,
        summarization: false,
        sentences: true,
      );

      print('DEBUG: Creating complex TranscriptionOptions...');
      final json = options.toJson();
      print('DEBUG: Complex toJson() result: $json');
      print('DEBUG: Type: ${json.runtimeType}');

      expect(json, isA<Map<String, dynamic>>());
      expect(json['language'], equals('en'));
      expect(json['diarization'], equals(true));
      expect(json['translation'], equals(true));
      expect(json['summarization'], equals(false));
      expect(json['sentences'], equals(true));
    });
  });
}
