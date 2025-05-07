import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Class for managing WebSocket connection for real-time speech recognition
class LiveTranscriptionSocket {
  /// URL for WebSocket connection
  final String url;

  /// WebSocket channel
  late IOWebSocketChannel _channel;

  /// Handler for messages from server
  final void Function(dynamic)? onMessage;

  /// Handler for connection closure
  final void Function()? onDone;

  /// Error handler
  final Function? onError;

  /// Connection status
  bool _isConnected = false;

  /// Checks if connection is established
  bool get isConnected => _isConnected;

  /// Creates a new instance of [LiveTranscriptionSocket]
  ///
  /// [url] - URL for WebSocket connection
  /// [onMessage] - handler for messages from server
  /// [onDone] - handler for connection closure
  /// [onError] - error handler
  LiveTranscriptionSocket({
    required this.url,
    this.onMessage,
    this.onDone,
    this.onError,
  }) {
    _connect();
  }

  /// Establishes WebSocket connection
  void _connect() {
    _channel = IOWebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    _channel.stream.listen(
      (message) {
        if (onMessage != null) {
          // Convert raw message to Map
          if (message is String) {
            try {
              final jsonData = jsonDecode(message);
              onMessage!(jsonData);
            } catch (e) {
              onMessage!(message);
            }
          } else {
            onMessage!(message);
          }
        }
      },
      onDone: () {
        _isConnected = false;
        if (onDone != null) {
          onDone!();
        }
      },
      onError: (error) {
        _isConnected = false;
        if (onError != null) {
          onError!(error);
        }
      },
    );
  }

  /// Sends audio data to the server
  ///
  /// [audioData] - audio data as a list of integers
  void sendAudioData(List<int> audioData) {
    if (!_isConnected) {
      throw Exception('WebSocket connection not established');
    }

    // Send audio data directly as binary data
    _channel.sink.add(Uint8List.fromList(audioData));
  }

  /// Sends audio data to the server in base64 format
  ///
  /// [audioData] - audio data as a list of integers
  void sendBase64AudioData(List<int> audioData) {
    if (!_isConnected) {
      throw Exception('WebSocket connection not established');
    }

    final base64Data = base64Encode(audioData);
    final message = jsonEncode({
      'type': 'audio_chunk',
      'data': {
        'chunk': base64Data,
      },
    });

    _channel.sink.add(message);
  }

  /// Sends a message about stopping recording
  void sendStopRecording() {
    if (!_isConnected) {
      throw Exception('WebSocket connection not established');
    }

    final message = jsonEncode({
      'type': 'stop_recording',
    });

    _channel.sink.add(message);
  }

  /// Sends arbitrary message
  ///
  /// [message] - message as Map
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      throw Exception('WebSocket connection not established');
    }

    _channel.sink.add(jsonEncode(message));
  }

  /// Closes WebSocket connection
  void close() {
    if (_isConnected) {
      _channel.sink.close(status.normalClosure);
      _isConnected = false;
    }
  }
}
