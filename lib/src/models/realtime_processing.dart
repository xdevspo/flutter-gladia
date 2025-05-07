import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'structures.dart';

part 'realtime_processing.g.dart';

/// Configuration for real-time processing
@immutable
@JsonSerializable()
class RealtimeProcessing {
  /// Provide accurate timestamps for each word
  @JsonKey(name: 'words_accurate_timestamps')
  final bool? wordsAccurateTimestamps;

  /// Use custom vocabulary
  @JsonKey(name: 'custom_vocabulary')
  final bool? customVocabulary;

  /// Custom vocabulary configuration, if custom_vocabulary is enabled
  @JsonKey(name: 'custom_vocabulary_config')
  final CustomVocabularyConfig? customVocabularyConfig;

  /// If true, enable custom spelling for the transcription.
  @JsonKey(name: 'custom_spelling')
  final bool? customSpelling;

  /// Custom spelling configuration, if custom_spelling is enabled
  @JsonKey(name: 'custom_spelling_config')
  final CustomSpellingConfig? customSpellingConfig;

  /// If true, enable translation for the transcription
  @JsonKey(name: 'translation')
  final bool? translation;

  /// Translation configuration, if translation is enabled
  @JsonKey(name: 'translation_config')
  final TranslationConfig? translationConfig;

  /// If true, enable named entity recognition for the transcription.
  @JsonKey(name: 'named_entity_recognition')
  final bool? namedEntityRecognition;

  /// If true, enable sentiment analysis for the transcription.
  @JsonKey(name: 'sentiment_analysis')
  final bool? sentimentAnalysis;

  /// Creates a new instance of [RealtimeProcessing]
  const RealtimeProcessing({
    this.wordsAccurateTimestamps,
    this.customVocabulary,
    this.customVocabularyConfig,
    this.customSpelling,
    this.customSpellingConfig,
    this.translation,
    this.translationConfig,
    this.namedEntityRecognition,
    this.sentimentAnalysis,
  });

  factory RealtimeProcessing.fromJson(Map<String, dynamic> json) =>
      _$RealtimeProcessingFromJson(json);

  Map<String, dynamic> toJson() => _$RealtimeProcessingToJson(this);
}
