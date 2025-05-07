import 'dart:io';
import 'package:gladia/gladia.dart';

/// Console example of using Gladia API v2
///
/// This example demonstrates how to:
/// - Upload an audio file to Gladia server
/// - Initiate transcription with various options
/// - Get transcription result with the new API v2 structure
/// - Display extended information about transcription and metadata
///
/// Usage:
///   dart run console_sync_example.dart --api-key=<API_KEY> --audio-file=path/to/audio.mp3
///
/// Options:
///   --api-key=<API_KEY>          Gladia API key (can also be obtained from GLADIA_API_KEY environment variable)
///   --audio-file=path/to/audio   Path to audio file (default: audio_file.mp3)
///   --verbose=true               Detailed logging of requests and responses
///   --diarization=true           Enable diarization (speaker identification)
///   --sentiment=true             Enable text sentiment analysis

/// Parse command line arguments
Map<String, String> parseArgs(List<String> args) {
  final result = <String, String>{};

  for (final arg in args) {
    if (arg.startsWith('--')) {
      final parts = arg.substring(2).split('=');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      } else {
        result[parts[0]] = 'true';
      }
    }
  }

  return result;
}

void main(List<String> args) async {
  // Parse command line arguments
  final arguments = parseArgs(args);

  // Get API key from environment variables or arguments
  final apiKey =
      Platform.environment['GLADIA_API_KEY'] ?? arguments['api-key'] ?? null;

  if (apiKey == null) {
    print('❌ API key not specified. Use:');
    print('1. Command line parameter: --api-key=<API_KEY>');
    print('2. Environment variable: GLADIA_API_KEY=<API_KEY>');
    return;
  }

  // Get path to audio file from arguments
  final audioFilePath = arguments['audio-file'] ?? 'audio_file.mp3';

  // Enable detailed logging on request
  final enableLogging = arguments['verbose'] == 'true';

  print('🚀 Starting Gladia API test...');
  print(
      '  API key: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}');
  print('  Audio file: $audioFilePath');
  print('  Logging: ${enableLogging ? "enabled" : "disabled"}');

  // Create client with API key and logging settings
  final client = GladiaClient(
    apiKey: apiKey,
    enableLogging: enableLogging,
  );

  try {
    // Check if file exists
    final file = File(audioFilePath);

    if (!file.existsSync()) {
      print('❌ File not found: ${file.path}');
      print('Make sure the file exists or specify the correct path.');
      return;
    }

    print('📤 Uploading audio file to Gladia server...');

    // 1. Upload file to server
    final uploadResult = await client.uploadAudioFile(file);

    print('✅ File successfully uploaded. URL: ${uploadResult.audioUrl}');
    if (uploadResult.audioMetadata != null) {
      print('🕒 Duration: ${uploadResult.audioMetadata!.audioDuration} sec.');
    }

    // 2. Initialize transcription
    print('🔄 Sending transcription request...');

    // Create options with various settings
    final options = TranscriptionOptions(
      // Enable diarization (speaker identification)
      diarization: arguments['diarization'] == 'true',

      // Add main parameters for demonstration
      sentimentAnalysis: arguments['sentiment'] == 'true',
    );

    final transcriptionInit = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );

    print('✅ Request accepted. ID: ${transcriptionInit.id}');
    print('🔗 Result URL: ${transcriptionInit.resultUrl}');
    print('⏳ Waiting for transcription results...');

    // 3. Get transcription results
    int attempts = 0;
    TranscriptionResult? finalResult;

    while (attempts < 30) {
      // Maximum 30 attempts with 2 second interval
      try {
        finalResult =
            await client.getTranscriptionResult(transcriptionInit.resultUrl);
        print('✅ Transcription successfully received!');
        break; // Exit loop if we got the result
      } on GladiaApiException catch (e) {
        if (e.statusCode == 202) {
          // Transcription not yet complete, wait and try again
          print('⏳ Waiting... (attempt ${attempts + 1})');
          await Future.delayed(const Duration(seconds: 2));
          attempts++;
        } else {
          // Another error occurred
          print('❌ Error executing request: ${e.message}');
          if (e.statusCode != null) {
            print('📊 Status code: ${e.statusCode}');
          }

          // Display validation error details if present
          if (e.validationErrors != null && e.validationErrors!.isNotEmpty) {
            print('🚫 Validation error details:');
            for (final error in e.validationErrors!) {
              final field = error['field'] ?? 'unknown field';
              final message = error['message'] ?? 'unknown error';
              print('  - $field: $message');
            }
          }

          // Display debug information if present
          if (e.debugInfo != null) {
            print('\n🔍 Additional debug information:');
            print(e.debugInfo);
          }

          break;
        }
      }
    }

    // Display specialized information about the result
    if (finalResult != null) {
      _printTranscriptionResult(finalResult);
    }

    print('\n🎉 Testing completed!');
  } on GladiaApiException catch (e) {
    print('❌ Error executing request: ${e.message}');
    if (e.statusCode != null) {
      print('📊 Status code: ${e.statusCode}');
    }

    // Display validation error details if present
    if (e.validationErrors != null && e.validationErrors!.isNotEmpty) {
      print('🚫 Validation error details:');
      for (final error in e.validationErrors!) {
        final field = error['field'] ?? 'unknown field';
        final message = error['message'] ?? 'unknown error';
        print('  - $field: $message');
      }
    }

    // Display debug information if present
    if (e.debugInfo != null) {
      print('\n🔍 Additional debug information:');
      print(e.debugInfo);
    }
  } catch (e, stackTrace) {
    print('❌ Unknown error: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Prints formatted transcription result
void _printTranscriptionResult(TranscriptionResult result) {
  print('\n===========================================================');
  print('📋 TRANSCRIPTION RESULTS');
  print('===========================================================');

  // Basic information
  print('\n📝 Full text:');
  print(result.text);

  // Metadata
  print('\n📊 Metadata:');
  if (result.language != null) {
    print('  🌐 Language: ${result.language}');
  }
  if (result.duration != null) {
    print('  ⏱️ Duration: ${result.duration} sec.');
  }

  // Display file information
  if (result.file != null) {
    print('\n📁 File information:');
    if (result.file!.filename != null) {
      print('  📄 Filename: ${result.file!.filename}');
    }
    if (result.file!.source != null) {
      print('  🔄 Source: ${result.file!.source}');
    }
    if (result.file!.audioDuration != null) {
      print('  ⏱️ Duration: ${result.file!.audioDuration} sec.');
    }
    if (result.file!.numberOfChannels != null) {
      print('  🔊 Number of channels: ${result.file!.numberOfChannels}');
    }
  }

  // Additional request information
  print('\n📊 Request information:');
  print('  🆔 Request ID: ${result.id}');
  print('  📊 Status: ${result.status}');
  if (result.requestId != null) {
    print('  🔖 Request ID: ${result.requestId}');
  }
  if (result.version != null) {
    print('  🔢 API Version: ${result.version}');
  }
  if (result.createdAt != null) {
    print('  🕒 Created: ${result.createdAt!.toIso8601String()}');
  }
  if (result.completedAt != null) {
    print('  ✅ Completed: ${result.completedAt!.toIso8601String()}');
  }

  // Additional result metadata
  if (result.result?.metadata != null) {
    final metadata = result.result!.metadata!;
    print('\n📈 Detailed metadata:');
    if (metadata.audioDuration != null) {
      print('  ⏱️ Audio duration: ${metadata.audioDuration} sec.');
    }
    if (metadata.numberOfDistinctChannels != null) {
      print('  🔊 Channels: ${metadata.numberOfDistinctChannels}');
    }
    if (metadata.billingTime != null) {
      print('  💰 Billing time: ${metadata.billingTime} sec.');
    }
    if (metadata.transcriptionTime != null) {
      print('  ⏲️ Transcription time: ${metadata.transcriptionTime} sec.');
    }
  }

  // Segments
  if (result.segments != null && result.segments!.isNotEmpty) {
    print('\n🔊 Segments with timestamps and speakers:');
    for (int i = 0; i < result.segments!.length; i++) {
      final segment = result.segments![i];
      final start = segment.start.toStringAsFixed(2);
      final end = segment.end.toStringAsFixed(2);
      final speaker = segment.speaker != null ? '👤 ${segment.speaker}' : '';
      final channel =
          segment.channel != null ? '🔊 Channel ${segment.channel}' : '';

      print('${i + 1}. [$start - $end] $speaker $channel');
      print('   ${segment.text}');

      // Display words with text if present
      if (segment.words != null && segment.words!.isNotEmpty) {
        print('   Words:');
        for (final word in segment.words!) {
          final wordStart = word.start.toStringAsFixed(2);
          final wordEnd = word.end.toStringAsFixed(2);
          final wordText = word.text.isNotEmpty ? word.text : '[empty]';
          print('   [$wordStart - $wordEnd]: $wordText');
        }
      }
    }
  }

  // Sentiment analysis results
  if (result.result?.sentimentAnalysis != null) {
    final sentimentResult = result.result!.sentimentAnalysis!;
    print('\n😀 Sentiment analysis:');

    if (sentimentResult.success == true) {
      if (sentimentResult.results != null) {
        try {
          // Processing depending on results format
          final resultsData = sentimentResult.results;
          if (resultsData is String) {
            print('  Result: $resultsData');

            // Try to parse JSON if it's a string in JSON format
            try {
              final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
                  Map.castFrom(sentimentResult.toJson()['results']));

              final sentiment = jsonData['sentiment'] as String?;
              if (sentiment != null) {
                print('  Overall sentiment: $sentiment');
              }

              final segments = jsonData['segments'] as List<dynamic>?;
              if (segments != null && segments.isNotEmpty) {
                print('  Sentiment by segments:');
                for (final segment in segments) {
                  if (segment is Map<String, dynamic>) {
                    final text = segment['text'] as String?;
                    final sentimentValue = segment['sentiment'] as String?;
                    if (text != null && sentimentValue != null) {
                      print('  - $sentimentValue: "$text"');
                    }
                  }
                }
              }
            } catch (parseError) {
              // If JSON parsing fails, just display the string
            }
          }
        } catch (e) {
          print('  Error processing sentiment analysis result: $e');
          print('  Raw data: ${sentimentResult.results}');
        }
      } else {
        print('  No sentiment data');
      }
    } else {
      print('  Sentiment analysis not performed or completed with an error');
      if (sentimentResult.error != null) {
        print('  Error: ${sentimentResult.error!.message}');
      }
    }
  }

  // Translation results
  if (result.result?.translation != null) {
    final translationResult = result.result!.translation!;
    print('\n🌐 Translations:');

    if (translationResult.success == true &&
        translationResult.results != null) {
      try {
        final resultData = translationResult.results;
        if (resultData is List) {
          final items = resultData as List<dynamic>;
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final fullTranscript = item['full_transcript'] as String?;
              if (fullTranscript != null) {
                print(
                    '  ${fullTranscript.substring(0, min(50, fullTranscript.length))}...');
              }
            }
          }
        } else if (resultData is Map<String, dynamic>) {
          final map = resultData as Map<String, dynamic>;
          map.forEach((key, value) {
            if (value is String) {
              print(
                  '  $key: "${value.substring(0, min(50, value.length))}..."');
            }
          });
        }
      } catch (e) {
        print('  Error processing translation results: $e');
      }
    } else {
      print('  Translation not performed or completed with an error');
      if (translationResult.error != null) {
        print('  Error: ${translationResult.error!.message}');
      }
    }
  }

  // LLM results
  if (result.result?.audioToLLM != null) {
    final llmResult = result.result!.audioToLLM!;
    print('\n🧠 LLM processing results:');

    if (llmResult.success == true && llmResult.results != null) {
      try {
        final resultData = llmResult.results;
        if (resultData is List) {
          final items = resultData as List<dynamic>;
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final itemResults = item['results'] as Map<String, dynamic>?;
              if (itemResults != null) {
                final prompt = itemResults['prompt'] as String?;
                final response = itemResults['response'] as String?;
                if (prompt != null && response != null) {
                  print('  📌 Prompt: "$prompt"');
                  print(
                      '  🔹 Response: "${response.substring(0, min(50, response.length))}..."');
                }
              }
            }
          }
        } else if (resultData is Map<String, dynamic>) {
          final map = resultData as Map<String, dynamic>;
          final prompts = map['prompts'] as List<dynamic>?;
          if (prompts != null) {
            for (final promptItem in prompts) {
              if (promptItem is Map<String, dynamic>) {
                final prompt = promptItem['prompt'] as String?;
                final response = promptItem['response'] as String?;
                if (prompt != null && response != null) {
                  print('  📌 Prompt: "$prompt"');
                  print(
                      '  🔹 Response: "${response.substring(0, min(50, response.length))}..."');
                }
              }
            }
          }
        }
      } catch (e) {
        print('  Error processing LLM result: $e');
        print('  Raw data: $llmResult');
      }
    } else {
      print('  LLM processing not performed or completed with an error');
      if (llmResult.error != null) {
        print('  Error: ${llmResult.error!.message}');
      }
    }
  }

  // Request parameters
  if (result.requestParams != null) {
    print('\n⚙️ Request parameters used:');
    final params = result.requestParams!.toJson();
    params.forEach((key, value) {
      if (value is Map || value is List) {
        print(
            '  $key: ${value.toString().substring(0, min(30, value.toString().length))}...');
      } else {
        print('  $key: $value');
      }
    });
  }

  print('===========================================================');
}

/// Returns the minimum of two numbers
int min(int a, int b) => a < b ? a : b;
