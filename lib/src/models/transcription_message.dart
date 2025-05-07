/// Class for messages received from API during real-time speech recognition
class TranscriptionMessage {
  /// Message type
  final String type;

  /// Session ID
  final String sessionId;

  /// Message creation time
  final DateTime createdAt;

  /// Message data
  final TranscriptionMessageData data;

  /// Creates a new instance of [TranscriptionMessage]
  const TranscriptionMessage({
    required this.type,
    required this.sessionId,
    required this.createdAt,
    required this.data,
  });

  /// Creates [TranscriptionMessage] from JSON data
  factory TranscriptionMessage.fromJson(Map<String, dynamic> json) {
    return TranscriptionMessage(
      type: json['type'] as String,
      sessionId: json['session_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: TranscriptionMessageData.fromJson(
          json['data'] as Map<String, dynamic>),
    );
  }

  /// Converts object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
      'data': data.toJson(),
    };
  }

  @override
  String toString() =>
      'TranscriptionMessage(type: $type, sessionId: $sessionId, createdAt: $createdAt, data: $data)';
}

/// Transcription message data
class TranscriptionMessageData {
  /// Utterance ID
  final String id;

  /// Final utterance indicator
  final bool isFinal;

  /// Utterance information
  final UtteranceInfo utterance;

  /// Creates a new instance of [TranscriptionMessageData]
  const TranscriptionMessageData({
    required this.id,
    required this.isFinal,
    required this.utterance,
  });

  /// Creates [TranscriptionMessageData] from JSON data
  factory TranscriptionMessageData.fromJson(Map<String, dynamic> json) {
    return TranscriptionMessageData(
      id: json['id'] as String,
      isFinal: json['is_final'] as bool,
      utterance:
          UtteranceInfo.fromJson(json['utterance'] as Map<String, dynamic>),
    );
  }

  /// Converts object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_final': isFinal,
      'utterance': utterance.toJson(),
    };
  }

  @override
  String toString() =>
      'TranscriptionMessageData(id: $id, isFinal: $isFinal, utterance: $utterance)';
}

/// Utterance information
class UtteranceInfo {
  /// Utterance text
  final String text;

  /// Utterance start time (in seconds)
  final double start;

  /// Utterance end time (in seconds)
  final double end;

  /// Utterance language (ISO code)
  final String language;

  /// Channel number (for multi-channel audio)
  final int? channel;

  /// Creates a new instance of [UtteranceInfo]
  const UtteranceInfo({
    required this.text,
    required this.start,
    required this.end,
    required this.language,
    this.channel,
  });

  /// Creates [UtteranceInfo] from JSON data
  factory UtteranceInfo.fromJson(Map<String, dynamic> json) {
    return UtteranceInfo(
      text: json['text'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      language: json['language'] as String,
      channel: json['channel'] as int?,
    );
  }

  /// Converts object to JSON data
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'text': text,
      'start': start,
      'end': end,
      'language': language,
    };
    if (channel != null) {
      data['channel'] = channel;
    }
    return data;
  }

  @override
  String toString() =>
      'UtteranceInfo(text: $text, start: $start, end: $end, language: $language, channel: $channel)';
}
