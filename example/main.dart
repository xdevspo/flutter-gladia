import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';

void main() async {
  // API key must be obtained from Gladia website and passed via
  // environment variable or app settings
  final apiKey = Platform.environment['GLADIA_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
    if (kDebugMode) {
      debugPrint(
          '❌ API key not specified. Set the GLADIA_API_KEY environment variable');
      return;
    }
  }

  // Create client with API key
  final client = GladiaClient(apiKey: apiKey);

  try {
    // Example of uploading and transcribing a local audio file
    final file = File('audio_file.mp3');

    if (kDebugMode) {
      debugPrint('Uploading audio file to Gladia server...');
    }

    // 1. Upload file to server
    final uploadResult = await client.uploadAudioFile(file);

    if (kDebugMode) {
      debugPrint('File successfully uploaded. URL: ${uploadResult.audioUrl}');
      if (uploadResult.audioMetadata != null) {
        debugPrint(
            'Duration: ${uploadResult.audioMetadata!.audioDuration} sec.');
      }
    }

    // 2. Initialize transcription
    if (kDebugMode) {
      debugPrint('Sending transcription request...');
    }

    final transcriptionInit = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: const TranscriptionOptions(
        diarization: true,
      ),
    );

    if (kDebugMode) {
      debugPrint('Request accepted. ID: ${transcriptionInit.id}');
      debugPrint('Waiting for transcription results...');
    }

    // 3. Get transcription results
    int attempts = 0;
    while (attempts < 30) {
      // Maximum 30 attempts with 2 second interval
      try {
        final result =
            await client.getTranscriptionResult(transcriptionInit.resultUrl);

        // Print full text
        if (kDebugMode) {
          debugPrint('Full transcription text:');
          debugPrint(result.text);
          debugPrint('------------------------');
        }

        // Print segments with timestamps
        if (result.segments != null && result.segments!.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('Segments:');
          }
          for (final segment in result.segments!) {
            final start = segment.start.toStringAsFixed(2);
            final end = segment.end.toStringAsFixed(2);
            if (kDebugMode) {
              debugPrint('[$start - $end]: ${segment.text}');
            }
          }
        }

        break; // Exit loop if we got the result
      } on GladiaApiException catch (e) {
        if (e.statusCode == 202) {
          // Transcription not yet complete, wait and try again
          if (kDebugMode) {
            debugPrint('Waiting... (attempt ${attempts + 1})');
          }
          await Future.delayed(const Duration(seconds: 2));
          attempts++;
        } else {
          // Another error occurred
          if (kDebugMode) {
            debugPrint('Error executing request: ${e.message}');
            if (e.statusCode != null) {
              debugPrint('Status code: ${e.statusCode}');
            }
          }
          break;
        }
      }
    }

    // Alternative approach - using the transcribeFile method that combines all steps
    if (kDebugMode) {
      debugPrint('\nAlternative method (all-in-one):');
    }

    final result = await client.transcribeFile(
      file: file,
      options: const TranscriptionOptions(
        diarization: true,
      ),
    );

    if (kDebugMode) {
      debugPrint('Result: ${(result as TranscriptionResult).text}');
    }
  } on GladiaApiException catch (e) {
    if (kDebugMode) {
      debugPrint('Error executing request: ${e.message}');
      if (e.statusCode != null) {
        debugPrint('Status code: ${e.statusCode}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Unknown error: $e');
    }
  }
}
