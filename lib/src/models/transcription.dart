import 'utterance.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'sentence.dart';
import 'subtitle.dart';

part 'transcription.g.dart';

@immutable
@JsonSerializable()

/// Basic transcription data
class Transcription {
  /// Full transcription text
  @JsonKey(name: 'full_transcript')
  final String fullTranscript;

  /// Languages detected in audio
  @JsonKey(name: 'languages')
  final List<String>? languages;

  /// Transcription sentences
  @JsonKey(name: 'sentences')
  final List<Sentence>? sentences;

  /// Transcription subtitles
  @JsonKey(name: 'subtitles')
  final List<Subtitle>? subtitles;

  /// Expressions with time stamps
  final List<Utterance>? utterances;

  /// Creates a new instance of [Transcription]
  const Transcription({
    required this.fullTranscript,
    this.languages,
    this.sentences,
    this.subtitles,
    this.utterances,
  });

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionToJson(this);

  /// Creates [Transcription] from JSON data
  factory Transcription.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionFromJson(json);
}
