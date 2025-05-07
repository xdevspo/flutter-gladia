import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';
import 'package:file_picker/file_picker.dart';
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

  File? _selectedFile;
  bool _isTranscribing = false;
  String? _transcriptionError;
  List<TranscriptionSegment>? _segments;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      setState(() {
        _selectedFile = file;
        _resultController.clear();
        _transcriptionError = null;
        _segments = null;
      });
    }
  }

  Future<void> _transcribeAudio() async {
    if (_selectedFile == null) {
      setState(() {
        _transcriptionError = 'Please select an audio file first';
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
      final client = GladiaClient(apiKey: apiKey);

      final result = await client.transcribeFile(
        file: _selectedFile!,
        options: const TranscriptionOptions(
          language: 'en',
          diarization: true,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedFile != null
                          ? 'Selected: ${_selectedFile!.path.split('/').last}'
                          : 'No file selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _selectFile,
                    child: const Text('Select Audio File'),
                  ),
                ],
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
