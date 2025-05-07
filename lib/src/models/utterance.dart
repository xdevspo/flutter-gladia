import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'word.dart';

part 'utterance.g.dart';

/// Transcription segment with time stamps and additional information
@immutable
@JsonSerializable()
class Utterance {
  /// Segment text
  @JsonKey(name: 'text')
  final String text;

  /// Segment start time in seconds
  @JsonKey(name: 'start')
  final double start;

  /// Segment end time in seconds
  @JsonKey(name: 'end')
  final double end;

  /// Speaker identifier (if diarization is available)
  @JsonKey(name: 'speaker')
  final String? speaker;

  /// Confidence in identification (0 to 1)
  @JsonKey(name: 'confidence')
  final double? confidence;

  /// Segment language (if available)
  @JsonKey(name: 'language')
  final String? language;

  /// Audio channel
  @JsonKey(name: 'channel')
  final int? channel;

  /// Words in segment with time stamps
  @JsonKey(name: 'words')
  final List<Word>? words;

  /// Creates a new instance of [Utterance]
  const Utterance({
    required this.text,
    required this.start,
    required this.end,
    this.speaker,
    this.confidence,
    this.language,
    this.channel,
    this.words,
  });

  /// Creates [Utterance] from JSON data
  factory Utterance.fromJson(Map<String, dynamic> json) =>
      _$UtteranceFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$UtteranceToJson(this);
}
