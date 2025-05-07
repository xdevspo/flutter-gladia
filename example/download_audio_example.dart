import 'dart:io';
import 'package:gladia/gladia.dart';
import 'package:args/args.dart';

/// Simple example of a console command for downloading audio files from Gladia API
void main(List<String> arguments) async {
  // Create arguments parser
  final parser = ArgParser()
    ..addOption('api-key', abbr: 'k', help: 'Gladia API key', mandatory: false)
    ..addOption('record-id',
        abbr: 'r', help: 'Record ID to download', mandatory: true)
    ..addOption('output', abbr: 'o', help: 'Path to save the file')
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false)
    ..addFlag('verbose',
        abbr: 'v', help: 'Detailed logging', defaultsTo: false);

  try {
    // Parse arguments
    final results = parser.parse(arguments);

    // Check for help request
    if (results['help'] == true) {
      _printUsage(parser);
      return;
    }

    // Get API key from environment variables or arguments
    final apiKey = results['api-key'] as String? ??
        Platform.environment['GLADIA_API_KEY'] ??
        '';

    if (apiKey.isEmpty) {
      throw ArgumentError(
          'API key not specified. Use --api-key or GLADIA_API_KEY environment variable');
    }

    final recordId = results['record-id'] as String;
    final outputPath = results['output'] as String?;
    final verbose = results['verbose'] as bool;

    // Create Gladia client
    final gladiaClient = GladiaClient(apiKey: apiKey, enableLogging: verbose);

    // Display startup information
    stdout.writeln('🚀 Starting audio file download from Gladia API...');
    stdout.writeln(
        '  API key: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}');
    stdout.writeln('  Record ID: $recordId');
    stdout.writeln('  Save path: ${outputPath ?? 'Default'}');
    stdout.writeln('  Logging: ${verbose ? "enabled" : "disabled"}');

    // Start downloading
    stdout.writeln('\n📥 Downloading audio file with ID: $recordId...');

    // Download file
    final savedPath = await gladiaClient.downloadFile(
      recordId: recordId,
      outputPath: outputPath,
    );

    // Check if downloaded file exists
    final savedFile = File(savedPath);
    if (!savedFile.existsSync()) {
      throw Exception('File downloaded but not found at path: $savedPath');
    }

    // Get file size
    final fileSize = await savedFile.length();

    // Display result
    stdout.writeln('\n✅ File successfully downloaded!');
    stdout.writeln('📂 File path: $savedPath');
    stdout.writeln('📊 File size: ${_formatFileSize(fileSize)}');

    stdout.writeln('\n🎉 Operation completed successfully!');
  } catch (e) {
    // Handle errors
    stderr.writeln('\n❌ Error: ${e.toString()}');

    if (e is GladiaApiException) {
      if (e.statusCode != null) {
        stderr.writeln('📊 Status code: ${e.statusCode}');
      }

      // Display validation error details if present
      if (e.validationErrors != null && e.validationErrors!.isNotEmpty) {
        stderr.writeln('🚫 Validation error details:');
        for (final error in e.validationErrors!) {
          final field = error['field'] ?? 'unknown field';
          final message = error['message'] ?? 'unknown error';
          stderr.writeln('  - $field: $message');
        }
      }

      // Display debug information if present
      if (e.debugInfo != null) {
        stderr.writeln('\n🔍 Additional debug information:');
        stderr.writeln(e.debugInfo);
      }
    }

    stderr.writeln('\nUsage:');
    _printUsage(parser);
    exit(1);
  }
}

// Helper function for formatting file size
String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

// Helper function for displaying help
void _printUsage(ArgParser parser) {
  stdout.writeln('Usage:');
  stdout.writeln(
      'dart download_audio_example.dart --api-key=<API_KEY> --record-id=RECORD_ID [--output=OUTPUT_PATH] [--verbose]');
  stdout.writeln();
  stdout.writeln('Parameters:');
  stdout.writeln(parser.usage);
  stdout.writeln();
  stdout.writeln('Examples:');
  stdout.writeln(
      'dart download_audio_example.dart -k <API_KEY> -r rec_xyz789 -o audio/my_file.mp3');
  stdout.writeln(
      'GLADIA_API_KEY=<API_KEY> dart download_audio_example.dart -r rec_xyz789 -v');
}
