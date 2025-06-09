import 'package:gladia/src/models/audio_to_llm_config.dart';
import 'package:gladia/src/models/diarization_config.dart';
import 'package:gladia/src/models/structured_data_extarction_config.dart';
import 'package:gladia/src/models/structures.dart';
import 'package:gladia/src/models/subtitles_config.dart';
import 'package:gladia/src/models/summarization_config.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'transcription_options.g.dart';

/// Options for transcription process
@immutable
@JsonSerializable()
class TranscriptionOptions {
  /// [Alpha] Context to feed the transcription model with for possible better accuracy
  @JsonKey(name: 'context_prompt')
  final String? contextPrompt;

  /// [Beta] Can be either boolean to enable custom_vocabulary for this audio or an array with specific vocabulary list to feed the transcription model with
  @JsonKey(name: 'custom_vocabulary')
  final bool? customVocabulary;

  /// [Beta] Custom vocabulary configuration, if custom_vocabulary is enabled
  @JsonKey(name: 'custom_vocabulary_config')
  final CustomVocabularyConfig? customVocabularyConfig;

  /// The original language in iso639-1 format
  @JsonKey(name: 'language')
  final String? language;

  /// Enable callback for this transcription. If true, the callback_config property will be used to customize the callback behaviour
  @JsonKey(name: 'callback')
  final bool? callback;

  /// Customize the callback behaviour (url and http method)
  @JsonKey(name: 'callback_config')
  final CallbackConfig? callbackConfig;

  /// Enable subtitles generation for this transcription
  @JsonKey(name: 'subtitles')
  final bool? subtitles;

  /// Configuration for subtitles generation if subtitles is enabled
  @JsonKey(name: 'subtitles_config')
  final SubtitlesConfig? subtitlesConfig;

  /// Enable speaker recognition (diarization) for this audio
  @JsonKey(name: 'diarization')
  final bool? diarization;

  /// Speaker recognition configuration, if diarization is enabled
  @JsonKey(name: 'diarization_config')
  final DiarizationConfig? diarizationConfig;

  /// [Beta] Enable translation for this audio
  @JsonKey(name: 'translation')
  final bool? translation;

  /// [Beta] Translation configuration, if translation is enabled
  @JsonKey(name: 'translation_config')
  final TranslationConfig? translationConfig;

  /// [Beta] Enable summarization for this audio
  @JsonKey(name: 'summarization')
  final bool? summarization;

  /// [Beta] Summarization configuration, if summarization is enabled
  @JsonKey(name: 'summarization_config')
  final SummarizationConfig? summarizationConfig;

  /// [Alpha] Enable moderation for this audio
  @JsonKey(name: 'moderation')
  final bool? moderation;

  /// [Alpha] Enable named entity recognition for this audio
  @JsonKey(name: 'named_entity_recognition')
  final bool? namedEntityRecognition;

  /// [Alpha] Enable chapterization for this audio
  @JsonKey(name: 'chapterization')
  final bool? chapterization;

  /// [Alpha] Enable names consistency for this audio
  @JsonKey(name: 'names_consistency')
  final bool? namesConsistency;

  /// [Alpha] Enable custom spelling for this audio
  @JsonKey(name: 'custom_spelling')
  final bool? customSpelling;

  /// [Alpha] Custom spelling configuration, if custom_spelling is enabled
  @JsonKey(name: 'custom_spelling_config')
  final CustomSpellingConfig? customSpellingConfig;

  /// [Alpha] Enable structured data extraction for this audio
  @JsonKey(name: 'structured_data_extraction')
  final bool? structuredDataExtraction;

  /// [Alpha] Structured data extraction configuration, if structured_data_extraction is enabled
  @JsonKey(name: 'structured_data_extraction_config')
  final StructuredDataExtractionConfig? structuredDataExtractionConfig;

  /// [Alpha] Enable sentiment analysis for this audio
  @JsonKey(name: 'sentiment_analysis')
  final bool? sentimentAnalysis;

  /// [Alpha] Enable audio to llm processing for this audio
  @JsonKey(name: 'audio_to_llm')
  final bool? audioToLLM;

  /// [Alpha] Audio to llm configuration, if audio_to_llm is enabled
  @JsonKey(name: 'audio_to_llm_config')
  final AudioToLLMConfig? audioToLLMConfig;

  /// Custom metadata you can attach to this transcription
  @JsonKey(name: 'custom_metadata')
  final Map<String, dynamic>? customMetadata;

  /// Enable sentences for this audio
  /// Default: false
  @JsonKey(name: 'sentences')
  final bool? sentences;

  /// [Alpha] Allows to change the output display_mode for this audio. The output will be reordered, creating new utterances when speakers overlapped
  /// Default: false
  @JsonKey(name: 'display_mode')
  final String? displayMode;

  /// [Alpha] Use enhanced punctuation for this audio
  /// Default: false
  @JsonKey(name: 'enhanced_punctuation')
  final bool? enhancedPunctuation;

  /// Specify the language configuration
  @JsonKey(name: 'language_config')
  final LanguageConfig? languageConfig;

  /// Creates a new instance of [TranscriptionOptions]
  const TranscriptionOptions({
    this.contextPrompt,
    this.customVocabulary,
    this.customVocabularyConfig,
    this.language,
    this.callback,
    this.callbackConfig,
    this.subtitles,
    this.subtitlesConfig,
    this.diarization,
    this.diarizationConfig,
    this.translation,
    this.translationConfig,
    this.summarization,
    this.summarizationConfig,
    this.moderation,
    this.namedEntityRecognition,
    this.chapterization,
    this.namesConsistency,
    this.customSpelling,
    this.customSpellingConfig,
    this.structuredDataExtraction,
    this.structuredDataExtractionConfig,
    this.sentimentAnalysis,
    this.audioToLLM,
    this.audioToLLMConfig,
    this.customMetadata,
    this.sentences,
    this.displayMode,
    this.enhancedPunctuation,
    this.languageConfig,
  });

  factory TranscriptionOptions.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TranscriptionOptionsToJson(this);
}
