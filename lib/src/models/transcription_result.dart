import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_response.dart';
import 'result_data.dart';
import 'file_info.dart';
import 'transcription_metadata.dart';
import 'transcription_options.dart';
import 'error_data.dart';

part 'transcription_result.g.dart';

/// Complete audio transcription result from Gladia API
@immutable
@JsonSerializable()
class TranscriptionResult extends BaseResponse {
  /// Audio file information
  final FileInfo? file;

  /// Request parameters
  @JsonKey(name: 'request_params', fromJson: _convertFromRequestParams)
  final TranscriptionOptions? requestParams;

  /// Transcription results and additional functions
  final TranscriptionResultData? result;

  /// Creates a new instance of [TranscriptionResult]
  const TranscriptionResult({
    required super.id,
    required super.status,
    super.requestId,
    super.version,
    super.createdAt,
    super.completedAt,
    super.customMetadata,
    super.errorCode,
    super.kind,
    this.file,
    this.requestParams,
    this.result,
  });

  /// Returns the full transcription text for compatibility with the old version
  String get text => result?.transcription?.fullTranscript ?? '';

  /// Returns the language for compatibility with the old version
  String? get language {
    final languages = result?.transcription?.languages;
    return languages != null && languages.isNotEmpty ? languages.first : null;
  }

  /// Returns the duration for compatibility with the old version
  double? get duration =>
      file?.audioDuration ?? result?.metadata?.audioDuration;

  /// Returns segments for compatibility with the old version
  List<TranscriptionSegment>? get segments => result?.transcription?.utterances;

  /// Creates [TranscriptionResult] from JSON data
  factory TranscriptionResult.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionResultFromJson(json);

  /// Converts to JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    final resultJson = _$TranscriptionResultToJson(this);
    return {...baseJson, ...resultJson};
  }

  /// Converts request parameters from snake_case to parameters object
  static TranscriptionOptions? _convertFromRequestParams(
      Map<String, dynamic>? params) {
    if (params == null) return null;

    final Map<String, dynamic> converted = {};

    for (final entry in params.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      if (key == 'audio_url') continue; // Skip audio URL

      // Convert snake_case to camelCase
      final String camelCaseKey = _snakeToCamel(key);
      converted[camelCaseKey] = value;
    }

    return TranscriptionOptions.fromJson(converted);
  }

  /// Converts snake_case to camelCase
  static String _snakeToCamel(String snake) {
    return snake.replaceAllMapped(
      RegExp(r'_([a-zA-Z])'),
      (Match match) => match.group(1)!.toUpperCase(),
    );
  }
}

/// Transcription result data containing all functions
@immutable
@JsonSerializable()
class TranscriptionResultData {
  /// Transcription metadata
  final TranscriptionMetadata? metadata;

  /// Transcription result
  final TranscriptionData? transcription;

  /// Translation result
  @JsonKey(fromJson: _resultDataFromJson, toJson: _resultDataToJson)
  final ResultData? translation;

  /// Summarization result
  final ResultData? summarization;

  /// Moderation result
  final ResultData? moderation;

  /// Named entity recognition result
  @JsonKey(name: 'named_entity_recognition')
  final ResultData? namedEntityRecognition;

  /// Chapters result
  final ResultData? chapters;

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
  final ResultData? audioToLLM;

  /// Sentences result
  final ResultData? sentences;

  /// Display mode result
  @JsonKey(name: 'display_mode')
  final ResultData? displayMode;

  /// Creates a new instance of [TranscriptionResultData]
  const TranscriptionResultData({
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

  /// Creates [TranscriptionResultData] from JSON data
  factory TranscriptionResultData.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionResultDataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionResultDataToJson(this);
}

/// Basic transcription data
@immutable
@JsonSerializable()
class TranscriptionData extends ResultData {
  /// Full transcription text
  @JsonKey(name: 'full_transcript')
  final String fullTranscript;

  /// Languages detected in audio
  final List<String>? languages;

  /// Transcription sentences
  final List<SentenceData>? sentences;

  /// Transcription subtitles
  final List<SubtitleData>? subtitles;

  /// Utterances with time stamps
  final List<TranscriptionSegment>? utterances;

  /// Creates a new instance of [TranscriptionData]
  const TranscriptionData({
    super.success,
    super.isEmpty,
    super.execTime,
    super.error,
    required this.fullTranscript,
    this.languages,
    this.sentences,
    this.subtitles,
    this.utterances,
  });

  /// Creates [TranscriptionData] from JSON data
  factory TranscriptionData.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionDataFromJson(json);

  /// Converts to JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    final dataJson = _$TranscriptionDataToJson(this);
    return {...baseJson, ...dataJson};
  }
}

/// Sentence data
@immutable
@JsonSerializable()
class SentenceData extends ResultData {
  /// Sentence results as a list of strings
  final List<String>? _resultsList;

  /// Creates a new instance of [SentenceData]
  const SentenceData({
    super.success,
    super.isEmpty,
    super.execTime,
    super.error,
    @JsonKey(name: 'results') List<String>? results,
  }) : _resultsList = results;

  /// Returns results
  @override
  String? get results => _resultsList?.join(' ');

  /// Creates [SentenceData] from JSON data
  factory SentenceData.fromJson(Map<String, dynamic> json) =>
      _$SentenceDataFromJson(json);

  /// Converts to JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    final dataJson = _$SentenceDataToJson(this);
    return {...baseJson, ...dataJson};
  }
}

/// Subtitle data
@immutable
@JsonSerializable()
class SubtitleData {
  /// Subtitle format
  final String format;

  /// Subtitle text
  final String subtitles;

  /// Creates a new instance of [SubtitleData]
  const SubtitleData({
    required this.format,
    required this.subtitles,
  });

  /// Creates [SubtitleData] from JSON data
  factory SubtitleData.fromJson(Map<String, dynamic> json) =>
      _$SubtitleDataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$SubtitleDataToJson(this);
}

/// Transcription segment with time stamps and additional information
@immutable
@JsonSerializable()
class TranscriptionSegment {
  /// Segment text
  final String text;

  /// Segment start time in seconds
  final double start;

  /// Segment end time in seconds
  final double end;

  /// Speaker identifier (if speaker diarization is available)
  final String? speaker;

  /// Confidence in identification (0 to 1)
  final double? confidence;

  /// Segment language (if available)
  final String? language;

  /// Audio channel
  final int? channel;

  /// Words in segment with time stamps
  final List<Word>? words;

  /// Creates a new instance of [TranscriptionSegment]
  const TranscriptionSegment({
    required this.text,
    required this.start,
    required this.end,
    this.speaker,
    this.confidence,
    this.language,
    this.channel,
    this.words,
  });

  /// Creates [TranscriptionSegment] from JSON data
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionSegmentFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionSegmentToJson(this);
}

/// Word with time stamp
@immutable
@JsonSerializable()
class Word {
  /// Word text
  @JsonKey(name: 'word')
  final String text;

  /// Word start time in seconds
  final double start;

  /// Word end time in seconds
  final double end;

  /// Confidence in identification (0 to 1)
  final double? confidence;

  /// Creates a new instance of [Word]
  const Word({
    required this.text,
    required this.start,
    required this.end,
    this.confidence,
  });

  /// Creates [Word] from JSON data
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$WordToJson(this);
}

/// Converts ResultData from JSON
ResultData? _resultDataFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return ResultData.fromJson(json);
}

/// Converts ResultData to JSON
Map<String, dynamic>? _resultDataToJson(ResultData? result) {
  if (result == null) return null;
  return result.toJson();
}
