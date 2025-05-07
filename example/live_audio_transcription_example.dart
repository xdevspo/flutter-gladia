import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// Class for handling application lifecycle events
class LifecycleObserver extends WidgetsBindingObserver {
  final Future<void> Function()? onDetached;

  LifecycleObserver({this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached && onDetached != null) {
      onDetached!();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia Live Transcription Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LiveTranscriptionPage(),
    );
  }
}

class LiveTranscriptionPage extends StatefulWidget {
  const LiveTranscriptionPage({Key? key}) : super(key: key);

  @override
  State<LiveTranscriptionPage> createState() => _LiveTranscriptionPageState();
}

class _LiveTranscriptionPageState extends State<LiveTranscriptionPage> {
  // Gladia client instance
  GladiaClient? _gladiaClient;

  // Recorder for capturing audio from microphone
  final _audioRecorder = AudioRecorder();

  // WebSocket connection for audio data transmission
  LiveTranscriptionSocket? _socket;

  // UI status flags
  bool _isInitializing = false;
  bool _isRecording = false;
  bool _isTranscribing = false;

  // Microphone activity indicator
  double _currentAmplitude = 0.0;

  // Transcription buffer
  final List<String> _transcriptions = [];

  // Controller for API key text field
  final TextEditingController _apiKeyController = TextEditingController();

  // Audio data stream
  StreamSubscription? _amplitudeSubscription;
  Timer? _sendAudioTimer;
  String? _tempFilePath;

  // Session data
  String? _sessionId;

  // Enable detailed logging
  final bool _enableLogging = true;

  // Lifecycle observer
  late LifecycleObserver _lifecycleObserver;

  // SharedPreferences keys
  static const _apiKeyPrefKey = 'gladia_api_key';

  @override
  void initState() {
    super.initState();
    _loadApiKey();

    // Register handler for proper session closure when exiting the app
    _lifecycleObserver = LifecycleObserver(
      onDetached: () async {
        // Clean up resources when closing the app
        await _stopRecordingAndTranscription();
        await _closeGladiaSession();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // Clear active sessions when starting the app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetActiveSessions();
    });
  }

  // Load API key from settings
  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_apiKeyPrefKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        setState(() {
          _apiKeyController.text = savedKey;
        });
        _log('API key loaded from cache');
      }
    } catch (e) {
      _log('Error loading API key: $e');
    }
  }

  // Save API key to settings
  Future<void> _saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPrefKey, apiKey);
      _log('API key saved to cache');
    } catch (e) {
      _log('Error saving API key: $e');
    }
  }

  // Logging for debugging
  void _log(String message) {
    if (_enableLogging) {
      debugPrint('[Gladia] $message');
    }
  }

  // Initialize Gladia client
  void _initGladiaClient() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showError('Please enter an API key');
      return;
    }

    // Save API key for next launch
    _saveApiKey(apiKey);

    _gladiaClient = GladiaClient(
      apiKey: apiKey,
      enableLogging: _enableLogging,
    );
  }

  // Request audio recording permissions
  Future<bool> _requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Prepare temporary file for audio recording
  Future<String> _prepareAudioFile() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/gladia_live_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  // Start recording and transcription
  Future<void> _startRecordingAndTranscription() async {
    if (_isRecording || _isTranscribing) return;

    setState(() {
      _isInitializing = true;
    });

    // Initialize client
    _initGladiaClient();

    // Check permissions
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showError('No permission to record audio');
      setState(() {
        _isInitializing = false;
      });
      return;
    }

    try {
      // Prepare file for recording
      _tempFilePath = await _prepareAudioFile();
      _log('Temporary file prepared: $_tempFilePath');

      // Initialize real-time speech recognition session
      final sessionResult = await _gladiaClient!.initLiveTranscription(
        sampleRate: 16000,
        bitDepth: 16,
        channels: 1,
        encoding: 'wav/pcm',
      );
      _sessionId = sessionResult.id;
      _log('Session initialized: ${sessionResult.id}');

      // Create WebSocket connection
      _socket = _gladiaClient!.createLiveTranscriptionSocket(
        sessionUrl: sessionResult.url,
        onMessage: _handleTranscriptionMessage,
        onDone: () {
          _log('WebSocket connection closed');
          _stopRecordingAndTranscription();
        },
        onError: (error) {
          _showError('WebSocket error: $error');
          _log('WebSocket error: $error');
          _stopRecordingAndTranscription();
        },
      );
      _log('WebSocket connection established');

      // Clear previous transcriptions
      setState(() {
        _transcriptions.clear();
      });

      try {
        // Start audio recording with settings
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 256000,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _tempFilePath!,
        );
        _log('Audio recording started to file: $_tempFilePath');

        // Setup microphone activity monitoring
        _startAudioMonitoring();

        // Start periodic audio data sending
        _startPeriodicAudioSending();

        // Update UI
        setState(() {
          _isInitializing = false;
          _isRecording = true;
          _isTranscribing = true;
        });
      } catch (recordError) {
        _showError('Error starting recording: $recordError');
        _log('Error starting recording: $recordError');

        // Close connection if recording failed
        if (_socket != null && _socket!.isConnected) {
          _socket!.close();
          _socket = null;
        }

        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      _showError('Initialization error: $e');
      _log('Initialization error: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // Reset stuck active sessions
  Future<void> _resetActiveSessions() async {
    if (_apiKeyController.text.trim().isEmpty) {
      return; // API key not set, cannot continue
    }

    try {
      _log('Attempting to reset active sessions...');

      // Send request to get list of active sessions
      final dio = Dio()
        ..options.baseUrl = 'https://api.gladia.io/'
        ..options.headers = {
          'x-gladia-key': _apiKeyController.text.trim(),
          'Content-Type': 'application/json',
        };

      // Try to reset sessions by sending a DELETE request to special endpoint
      await dio.delete('v2/live/reset').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Timeout when resetting sessions');
          return Response(
            requestOptions: RequestOptions(path: 'v2/live/reset'),
            statusCode: 408,
          );
        },
      );

      _log('Active sessions reset successful');
    } catch (e) {
      _log('Failed to reset active sessions: $e');
      // Don't show error to user, this is a background process
    }
  }

  // Close session on API side
  Future<void> _closeGladiaSession() async {
    if (_sessionId != null && _apiKeyController.text.trim().isNotEmpty) {
      try {
        _log('Closing Gladia API session: $_sessionId');
        // Send DELETE request to close session on API side
        final dio = Dio()
          ..options.baseUrl = 'https://api.gladia.io/'
          ..options.headers = {
            'x-gladia-key': _apiKeyController.text.trim(),
            'Content-Type': 'application/json',
          };

        await dio.delete('v2/live/$_sessionId').timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _log('Timeout when closing session');
            // In case of timeout, try to reset all sessions
            dio.delete('v2/live/reset').catchError((e) {
              _log('Error resetting sessions: $e');
              return Response(
                requestOptions: RequestOptions(path: 'v2/live/reset'),
                statusCode: 500,
              );
            });
            return Response(
              requestOptions: RequestOptions(path: 'v2/live/$_sessionId'),
              statusCode: 408,
            );
          },
        );
        _log('Session successfully closed');
      } catch (e) {
        _log('Error closing session: $e');
        // Try to reset all sessions on error
        try {
          final dio = Dio()
            ..options.baseUrl = 'https://api.gladia.io/'
            ..options.headers = {
              'x-gladia-key': _apiKeyController.text.trim(),
              'Content-Type': 'application/json',
            };

          await dio.delete('v2/live/reset').timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              _log('Timeout when resetting sessions after error');
              return Response(
                requestOptions: RequestOptions(path: 'v2/live/reset'),
                statusCode: 408,
              );
            },
          );
          _log('All sessions reset after close error');
        } catch (resetError) {
          _log('Failed to reset sessions: $resetError');
        }
      }
      _sessionId = null;
    }
  }

  // Stop recording and transcription
  Future<void> _stopRecordingAndTranscription() async {
    if (!_isRecording && !_isTranscribing) return;

    // Cancel subscriptions and timers
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    _sendAudioTimer?.cancel();
    _sendAudioTimer = null;

    // Stop recording
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        _log('Audio recording stopped: $path');
      } catch (e) {
        _log('Error stopping recording: $e');
        // Try to forcibly cancel recording
        try {
          await _audioRecorder.cancel();
          _log('Audio recording forcibly canceled');
        } catch (ce) {
          _log('Error cancelling recording: $ce');
        }
      }
    }

    // Send stop recording signal
    if (_socket != null && _socket!.isConnected) {
      try {
        _socket!.sendStopRecording();
        _log('Stop recording signal sent');
      } catch (e) {
        _log('Error sending stop signal: $e');
      } finally {
        _socket!.close();
        _socket = null;
        _log('WebSocket connection closed');
      }
    }

    // Close session on Gladia server
    await _closeGladiaSession();

    // Clean up temporary file
    if (_tempFilePath != null) {
      try {
        final tempFile = File(_tempFilePath!);
        if (await tempFile.exists()) {
          await tempFile.delete();
          _log('Temporary file deleted: $_tempFilePath');
        }
      } catch (e) {
        _log('Error deleting temporary file: $e');
      }
      _tempFilePath = null;
    }

    // Update UI
    setState(() {
      _currentAmplitude = 0.0;
      _isRecording = false;
      _isTranscribing = false;
    });
  }

  // Monitor microphone sound level
  void _startAudioMonitoring() {
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      setState(() {
        // Protection from incorrect amplitude values
        if (!amp.current.isNaN && !amp.current.isInfinite) {
          _currentAmplitude = amp.current;
        } else {
          _currentAmplitude = 0.0;
        }
      });
    });
  }

  // Periodic audio data sending
  void _startPeriodicAudioSending() {
    // Interval between audio file readings (ms)
    const sendInterval = 300;

    // Size of sections for reading audio (44 bytes - WAV header size)
    const wavHeaderSize = 44;

    // First send flag (for WAV header sending)
    bool isFirstSend = true;

    // Start periodic reading and sending of audio data
    _sendAudioTimer = Timer.periodic(
      const Duration(milliseconds: sendInterval),
      (timer) async {
        if (!_isRecording || _socket == null || !_socket!.isConnected) {
          timer.cancel();
          return;
        }

        try {
          // Create buffer for audio data
          final file = File(_tempFilePath!);

          // Check if file exists
          if (await file.exists()) {
            final fileLength = await file.length();

            // Check if there is data to read
            if (fileLength > wavHeaderSize) {
              final raf = await file.open(mode: FileMode.read);

              if (isFirstSend) {
                // On first send, skip WAV header first
                isFirstSend = false;
                await raf.setPosition(wavHeaderSize);
              } else {
                // Read the last chunk of audio data, skipping header
                const chunkSize = 8 * 1024; // 8KB
                final endPos = fileLength;
                final startPos = fileLength > chunkSize + wavHeaderSize
                    ? fileLength - chunkSize
                    : wavHeaderSize;

                await raf.setPosition(startPos);

                final audioBytes = await raf.read(endPos - startPos);
                await raf.close();

                // Send audio data via WebSocket
                if (_socket != null &&
                    _socket!.isConnected &&
                    audioBytes.isNotEmpty) {
                  try {
                    // Send raw PCM data
                    _socket!.sendAudioData(audioBytes);

                    // Alternatively, data can be sent in base64 format
                    // Uncomment the following line if you need to send in base64
                    // _socket!.sendBase64AudioData(audioBytes);

                    _log('Sent ${audioBytes.length} bytes of audio data');
                  } catch (e) {
                    _log('Error sending audio data: $e');
                  }
                }
              }
            } else if (fileLength > 0 && fileLength <= wavHeaderSize) {
              _log('Audio file contains only WAV header');
            } else {
              _log('Audio recording file is empty');
            }
          } else {
            _log('Audio recording file does not exist');
          }
        } catch (e) {
          _log('Error reading audio data: $e');
        }
      },
    );
  }

  // Handle messages from transcription server
  void _handleTranscriptionMessage(dynamic message) {
    _log('Message received from server: $message');

    // Process transcription message
    if (message is Map<String, dynamic> && message['type'] == 'transcript') {
      try {
        final transcriptionMessage = TranscriptionMessage.fromJson(message);
        final text = transcriptionMessage.data.utterance.text;
        final isFinal = transcriptionMessage.data.isFinal;

        if (text.isNotEmpty) {
          setState(() {
            if (isFinal) {
              // If this is a final transcription, add it to the list
              _transcriptions.add(text);
              _log('Final transcription received: $text');

              // Limit the number of transcriptions to avoid memory overflow
              if (_transcriptions.length > 50) {
                _transcriptions.removeAt(0);
              }
            } else {
              // For intermediate results, update the last element
              if (_transcriptions.isEmpty) {
                _transcriptions.add('(partial) $text');
              } else {
                _transcriptions[_transcriptions.length - 1] = '(partial) $text';
              }
              _log('Partial transcription received: $text');
            }
          });
        }
      } catch (e) {
        _log('Error processing message: $e');
      }
    }
    // Process session ready message
    else if (message is Map<String, dynamic> && message['type'] == 'ready') {
      _log('Session ready to receive audio data');
    }
    // Process error message
    else if (message is Map<String, dynamic> && message['type'] == 'error') {
      final errorMessage = message['data']?['message'] ?? 'Unknown error';
      _log('Error from server: $errorMessage');
      _showError('Error from server: $errorMessage');
    }
  }

  // Display error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _stopRecordingAndTranscription();
    _closeGladiaSession();
    _audioRecorder.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gladia Live Transcription'),
        actions: [
          // Reset sessions button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset active sessions',
            onPressed: _isInitializing
                ? null
                : () async {
                    setState(() {
                      _isInitializing = true;
                    });
                    await _resetActiveSessions();
                    setState(() {
                      _isInitializing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Active sessions reset'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API key
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Gladia API Key',
                hintText: 'Enter your Gladia API key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !_isRecording && !_isTranscribing,
            ),
            const SizedBox(height: 16),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isInitializing || _isRecording || _isTranscribing
                            ? null
                            : _startRecordingAndTranscription,
                    child: _isInitializing
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Start'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!_isRecording && !_isTranscribing)
                        ? null
                        : _stopRecordingAndTranscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status
            Center(
              child: Text(
                _isRecording
                    ? 'Recording and transcribing...'
                    : _isTranscribing
                        ? 'Transcribing...'
                        : 'Ready to record',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recording and amplitude indicator
            if (_isRecording)
              Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recording in progress...',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Sound level indicator
                  LinearProgressIndicator(
                    value:
                        _currentAmplitude.isNaN || _currentAmplitude.isInfinite
                            ? 0.0
                            : (_currentAmplitude / 100)
                                .clamp(0.0, 1.0), // Normalize and limit value
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentAmplitude > 50
                          ? Colors.red
                          : _currentAmplitude > 20
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sound level: ${_currentAmplitude.isNaN || _currentAmplitude.isInfinite ? "0.0" : _currentAmplitude.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Heading for transcriptions
            const Text(
              'Transcription:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Transcription list
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _transcriptions.isEmpty
                    ? const Center(
                        child: Text(
                          'Transcriptions will appear here',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transcriptions.length,
                        shrinkWrap: true, // Add to prevent overflow
                        physics:
                            const ClampingScrollPhysics(), // Improve scrolling
                        itemBuilder: (context, index) {
                          final text = _transcriptions[index];
                          final isPartial = text.startsWith('(partial)');
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isPartial
                                    ? Colors.grey.shade100
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPartial
                                      ? Colors.grey.shade300
                                      : Colors.blue.shade200,
                                ),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontStyle: isPartial
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isPartial
                                      ? Colors.grey.shade700
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
