import 'dart:io';
import 'dart:convert';
import 'package:gladia/gladia.dart';
import 'package:dio/dio.dart';

/// Example of getting live transcription results using Gladia API
///
/// This example demonstrates how to:
/// - Connect to Gladia API
/// - Retrieve a live transcription result by ID
/// - Display detailed information about the live transcription
///
/// Usage:
///   dart run live_transcription_result_example.dart --api-key=<API_KEY> --id=<ID>
///
/// Options:
///   --api-key=<API_KEY>          Gladia API key (can also be obtained from GLADIA_API_KEY environment variable)
///   --id=<ID>                    ID of the live transcription result
///   --verbose=true               Detailed logging of requests and responses

/// Parse command line arguments
Map<String, String> parseArgs(List<String> args) {
  final result = <String, String>{};

  print("📌 DEBUG: Received command line args: $args");

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

  print("📌 DEBUG: Parsed arguments: $result");

  return result;
}

void main(List<String> args) async {
  print("🔍 DEBUG: Starting program...");
  print(
      "🔍 DEBUG: Environment variables: GLADIA_API_KEY exists: ${Platform.environment.containsKey('GLADIA_API_KEY')}");

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

  // Get live transcription session ID from arguments
  final id = arguments['id'];
  if (id == null) {
    print('❌ ID not specified. Use:');
    print('--id=<ID>');
    return;
  }

  // Enable detailed logging on request
  final enableLogging = arguments['verbose'] == 'true';

  print('🚀 Starting Gladia API live transcription result retrieval...');
  print(
      '  API key: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}');
  print('  ID: $id');
  print('  Logging: ${enableLogging ? "enabled" : "disabled"}');

  // Create client with API key and logging settings
  final client = GladiaClient(
    apiKey: apiKey,
    enableLogging: enableLogging,
  );

  // Create a direct Dio instance for raw data access
  final dio = Dio();
  dio.options.headers = {
    'x-gladia-key': apiKey,
    'Content-Type': 'application/json',
  };

  try {
    print('📥 Retrieving live transcription result...');

    // Try to get raw JSON first to display in case of model parsing errors
    try {
      final rawResponse = await dio.get('https://api.gladia.io/v2/live/$id');
      print('✅ Raw JSON result received!');
      print('\n===========================================================');
      print('📋 RAW JSON RESULTS');
      print('===========================================================');
      final jsonString = JsonEncoder.withIndent('  ').convert(rawResponse.data);
      print(jsonString);
    } catch (e) {
      print('❌ Error getting raw JSON: $e');
    }

    // Now try the model-based approach
    try {
      // Get live transcription result by ID
      final result = await client.getLiveTranscriptionResult(
        id: id,
      );

      print('✅ Live transcription result received!');
      _printLiveTranscriptionResult(result);
    } catch (e, stackTrace) {
      print('❌ Error parsing live transcription result: $e');
      print('Stack trace: $stackTrace');
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

/// Prints formatted live transcription result
void _printLiveTranscriptionResult(LiveTranscriptionResult result) {
  print('\n===========================================================');
  print('📋 LIVE TRANSCRIPTION RESULTS');
  print('===========================================================');

  // Basic information
  print('\n📝 Full text:');
  print(result.text);

  // Metadata
  print('\n📊 Metadata:');
  if (result.language != null) {
    print('  🌐 Language: ${result.language}');
  }
  if (result.result?.metadata?.audioDuration != null) {
    print('  ⏱️ Duration: ${result.result!.metadata!.audioDuration} sec.');
  }
  if (result.result?.metadata?.billingTime != null) {
    print('  💰 Billing time: ${result.result!.metadata!.billingTime} sec.');
  }
  if (result.result?.metadata?.transcriptionTime != null) {
    print(
        '  🕒 Transcription time: ${result.result!.metadata!.transcriptionTime} sec.');
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

  // Request parameters
  if (result.requestParams != null) {
    print('\n⚙️ Request parameters:');

    // Language configuration
    if (result.requestParams!.languageConfig?.languages != null &&
        result.requestParams!.languageConfig!.languages!.isNotEmpty) {
      print(
          '  🌐 Languages: ${result.requestParams!.languageConfig!.languages!.join(", ")}');
    }

    // Encoding and audio parameters
    if (result.requestParams!.encoding != null) {
      print('  🔡 Encoding: ${result.requestParams!.encoding!.toApiValue()}');
    }
    if (result.requestParams!.bitDepth != null) {
      print('  🎚️ Bit depth: ${result.requestParams!.bitDepth!.value}');
    }
    if (result.requestParams!.sampleRate != null) {
      print('  🎵 Sample rate: ${result.requestParams!.sampleRate!.value} Hz');
    }
    if (result.requestParams!.channels != null) {
      print('  🔊 Channels: ${result.requestParams!.channels}');
    }
    if (result.requestParams!.model != null) {
      print('  🤖 Model: ${result.requestParams!.model}');
    }
    if (result.requestParams!.endpointing != null) {
      print('  📏 Endpointing: ${result.requestParams!.endpointing} sec.');
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

  // Utterances (if available)
  if (result.utterances != null && result.utterances!.isNotEmpty) {
    print('\n🗣️ Utterances:');
    for (int i = 0; i < result.utterances!.length; i++) {
      final utterance = result.utterances![i];
      print(
          '  ${i + 1}. [${utterance.start.toStringAsFixed(1)} - ${utterance.end.toStringAsFixed(1)}] ${utterance.text}');
      if (utterance.language != null) {
        print('     🌐 Language: ${utterance.language}');
      }
      if (utterance.speaker != null) {
        print('     👤 Speaker: ${utterance.speaker}');
      }
      if (utterance.channel != null) {
        print('     🎧 Channel: ${utterance.channel}');
      }
    }
  }
}
