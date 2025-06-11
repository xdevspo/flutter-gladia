import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gladia/gladia.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const GladiaExampleApp());
}

class GladiaExampleApp extends StatelessWidget {
  const GladiaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia SDK Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TranscriptionScreen(),
    );
  }
}

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  TranscriptionScreenState createState() => TranscriptionScreenState();
}

class TranscriptionScreenState extends State<TranscriptionScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  File? _audioFile;
  bool _isTranscribing = false;
  String? _transcriptionError;
  List<TranscriptionSegment>? _segments;

  @override
  void initState() {
    super.initState();
    // Initialize with the audio file from assets or file system
    _initializeAudioFile();
  }

  Future<void> _initializeAudioFile() async {
    try {
      // First, try to load from assets and copy to temp directory
      print('Trying to load audio file from assets...');
      final ByteData data = await rootBundle.load('assets/audio_file.mp3');
      final List<int> bytes = data.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/audio_file.mp3';

      // Write file to temp directory
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      print('Successfully copied audio file to: $tempPath');
      setState(() {
        _audioFile = tempFile;
      });
      return;
    } catch (e) {
      print('Failed to load from assets: $e');
    }

    // Fallback: try to find file in file system
    final currentDir = Directory.current.path;

    final possiblePaths = [
      'audio_file.mp3', // Current working directory
      'lib/audio_file.mp3', // Relative to example directory
      'assets/audio_file.mp3', // In assets folder
      'example/lib/audio_file.mp3', // From project root
      '$currentDir/lib/audio_file.mp3', // Absolute path to lib folder
      '$currentDir/assets/audio_file.mp3', // Absolute path to assets folder
      '$currentDir/../example/lib/audio_file.mp3', // From gladia root
    ];

    print('Searching for audio file in current directory: $currentDir');

    for (final path in possiblePaths) {
      final file = File(path);
      print('Trying path: $path - exists: ${file.existsSync()}');
      if (file.existsSync()) {
        print('Found audio file at: ${file.absolute.path}');
        setState(() {
          _audioFile = file;
        });
        return;
      }
    }

    print('Audio file not found in any of the expected paths');
    // Set to null if not found
    setState(() {
      _audioFile = null;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _transcribeAudio() async {
    if (_audioFile == null || !_audioFile!.existsSync()) {
      setState(() {
        _transcriptionError = 'Audio file not found: audio_file.mp3';
      });
      return;
    }

    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _transcriptionError = 'API key is required';
      });
      return;
    }

    setState(() {
      _isTranscribing = true;
      _transcriptionError = null;
      _resultController.clear();
      _segments = null;
    });

    try {
      final client = GladiaClient(
        apiKey: apiKey,
        enableLogging: true, // Enable logging to see API requests
      );

      final result = await client.transcribeFile(
        file: _audioFile!,
        options: const TranscriptionOptions(
          language: 'ru',
          diarization: true,
          sentimentAnalysis: true,
          sentences: true,
        ),
      );

      setState(() {
        _resultController.text = result.text;
        _segments = result.segments;
        _isTranscribing = false;
      });
    } catch (e) {
      setState(() {
        _transcriptionError = 'Error: ${e.toString()}';
        _isTranscribing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gladia Audio Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Gladia API Key',
                  hintText: 'Enter your API key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _audioFile != null
                                ? 'Audio file: ${_audioFile!.path.split('/').last}'
                                : 'Audio file: audio_file.mp3',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _audioFile != null
                                ? 'Path: ${_audioFile!.path}'
                                : 'Status: Not found in expected locations',
                            style: TextStyle(
                              fontSize: 12,
                              color: _audioFile?.existsSync() == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            _audioFile?.existsSync() == true
                                ? 'Status: ✓ Found'
                                : 'Status: ✗ Not found',
                            style: TextStyle(
                              fontSize: 12,
                              color: _audioFile?.existsSync() == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_audioFile == null || !_audioFile!.existsSync()) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _initializeAudioFile,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Search for audio file again',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isTranscribing ? null : _transcribeAudio,
                child: _isTranscribing
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Transcribing...'),
                        ],
                      )
                    : const Text('Transcribe Audio'),
              ),
              if (_transcriptionError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _transcriptionError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Transcription Result:'),
              const SizedBox(height: 8),
              TextField(
                controller: _resultController,
                maxLines: 8,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Transcription will appear here',
                ),
              ),
              if (_segments != null && _segments!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Segments with Timestamps:'),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _segments!.length,
                  itemBuilder: (context, index) {
                    final segment = _segments![index];
                    return Card(
                      child: ListTile(
                        title: Text(segment.text),
                        subtitle: Text(
                          'Time: ${segment.start.toStringAsFixed(2)}s - ${segment.end.toStringAsFixed(2)}s',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
