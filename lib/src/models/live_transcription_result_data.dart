import 'package:gladia/src/models/audio_to_llm.dart';
import 'package:gladia/src/models/result_data.dart';
import 'package:gladia/src/models/sentence.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'transcription.dart';
import 'transcription_metadata.dart';
import 'translation.dart';

part 'live_transcription_result_data.g.dart';

/// Transcription result data containing all functions
@immutable
@JsonSerializable()
class LiveTranscriptionResultData {
  /// Transcription metadata
  @JsonKey(name: 'metadata')
  final TranscriptionMetadata? metadata;

  /// Transcription result
  @JsonKey(name: 'transcription')
  final Transcription? transcription;

  /// Translation result
  @JsonKey(name: 'translation')
  final Translation? translation;

  /// Summarization result
  @JsonKey(name: 'summarization')
  final ResultData? summarization;

  /// Moderation result
  @JsonKey(name: 'moderation')
  final ResultData? moderation;

  /// Named entity recognition result
  @JsonKey(name: 'named_entity_recognition')
  final ResultData? namedEntityRecognition;

  /// Name consistency result
  @JsonKey(name: 'name_consistency')
  final ResultData? nameConsistency;

  /// Custom spelling result
  @JsonKey(name: 'custom_spelling')
  final ResultData? customSpelling;

  /// Speaker reidentification result
  @JsonKey(name: 'speaker_reidentification')
  final ResultData? speakerReidentification;

  /// Structured data extraction result
  @JsonKey(name: 'structured_data_extraction')
  final ResultData? structuredDataExtraction;

  /// Sentiment analysis result
  @JsonKey(name: 'sentiment_analysis')
  final ResultData? sentimentAnalysis;

  /// LLM processing result
  @JsonKey(name: 'audio_to_llm')
  final AudioToLLM? audioToLLM;

  /// Sentences result
  @JsonKey(name: 'sentences')
  final Sentence? sentences;

  /// Display mode result
  @JsonKey(name: 'display_mode')
  final ResultData? displayMode;

  /// Chapters result
  @JsonKey(name: 'chapters')
  final ResultData? chapters;

  /// Creates a new instance of [LiveTranscriptionResultData]
  const LiveTranscriptionResultData({
    this.metadata,
    this.transcription,
    this.translation,
    this.summarization,
    this.moderation,
    this.namedEntityRecognition,
    this.chapters,
    this.nameConsistency,
    this.customSpelling,
    this.speakerReidentification,
    this.structuredDataExtraction,
    this.sentimentAnalysis,
    this.audioToLLM,
    this.sentences,
    this.displayMode,
  });

  /// Creates [LiveTranscriptionResultData] from JSON data
  factory LiveTranscriptionResultData.fromJson(Map<String, dynamic> json) =>
      _$LiveTranscriptionResultDataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$LiveTranscriptionResultDataToJson(this);
}
