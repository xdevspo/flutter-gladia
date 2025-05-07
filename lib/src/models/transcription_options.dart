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
  final bool? diarization;

  /// Speaker recognition configuration, if diarization is enabled
  final DiarizationConfig? diarizationConfig;

  /// [Beta] Enable translation for this audio
  final bool? translation;

  /// [Beta] Translation configuration, if translation is enabled
  final TranslationConfig? translationConfig;

  /// [Beta] Enable summarization for this audio
  final bool? summarization;

  /// [Beta] Summarization configuration, if summarization is enabled
  final SummarizationConfig? summarizationConfig;

  /// [Alpha] Enable moderation for this audio
  final bool? moderation;

  /// [Alpha] Enable named entity recognition for this audio
  final bool? namedEntityRecognition;

  /// [Alpha] Enable chapterization for this audio
  final bool? chapterization;

  /// [Alpha] Enable names consistency for this audio
  final bool? namesConsistency;

  /// [Alpha] Enable custom spelling for this audio
  final bool? customSpelling;

  /// [Alpha] Custom spelling configuration, if custom_spelling is enabled
  final CustomSpellingConfig? customSpellingConfig;

  /// [Alpha] Enable structured data extraction for this audio
  final bool? structuredDataExtraction;

  /// [Alpha] Structured data extraction configuration, if structured_data_extraction is enabled
  final StructuredDataExtractionConfig? structuredDataExtractionConfig;

  /// [Alpha] Enable sentiment analysis for this audio
  final bool? sentimentAnalysis;

  /// [Alpha] Enable audio to llm processing for this audio
  final bool? audioToLLM;

  /// [Alpha] Audio to llm configuration, if audio_to_llm is enabled
  final AudioToLLMConfig? audioToLLMConfig;

  /// Custom metadata you can attach to this transcription
  final Map<String, dynamic>? customMetadata;

  /// Enable sentences for this audio
  /// Default: false
  final bool? sentences;

  /// [Alpha] Allows to change the output display_mode for this audio. The output will be reordered, creating new utterances when speakers overlapped
  /// Default: false
  final String? displayMode;

  /// [Alpha] Use enhanced punctuation for this audio
  /// Default: false
  final bool? enhancedPunctuation;

  /// Specify the language configuration
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
