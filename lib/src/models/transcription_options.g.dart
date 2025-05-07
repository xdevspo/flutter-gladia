// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionOptions _$TranscriptionOptionsFromJson(
        Map<String, dynamic> json) =>
    TranscriptionOptions(
      contextPrompt: json['context_prompt'] as String?,
      customVocabulary: json['custom_vocabulary'] as bool?,
      customVocabularyConfig: json['custom_vocabulary_config'] == null
          ? null
          : CustomVocabularyConfig.fromJson(
              json['custom_vocabulary_config'] as Map<String, dynamic>),
      language: json['language'] as String?,
      callback: json['callback'] as bool?,
      callbackConfig: json['callback_config'] == null
          ? null
          : CallbackConfig.fromJson(
              json['callback_config'] as Map<String, dynamic>),
      subtitles: json['subtitles'] as bool?,
      subtitlesConfig: json['subtitles_config'] == null
          ? null
          : SubtitlesConfig.fromJson(
              json['subtitles_config'] as Map<String, dynamic>),
      diarization: json['diarization'] as bool?,
      diarizationConfig: json['diarizationConfig'] == null
          ? null
          : DiarizationConfig.fromJson(
              json['diarizationConfig'] as Map<String, dynamic>),
      translation: json['translation'] as bool?,
      translationConfig: json['translationConfig'] == null
          ? null
          : TranslationConfig.fromJson(
              json['translationConfig'] as Map<String, dynamic>),
      summarization: json['summarization'] as bool?,
      summarizationConfig: json['summarizationConfig'] == null
          ? null
          : SummarizationConfig.fromJson(
              json['summarizationConfig'] as Map<String, dynamic>),
      moderation: json['moderation'] as bool?,
      namedEntityRecognition: json['namedEntityRecognition'] as bool?,
      chapterization: json['chapterization'] as bool?,
      namesConsistency: json['namesConsistency'] as bool?,
      customSpelling: json['customSpelling'] as bool?,
      customSpellingConfig: json['customSpellingConfig'] == null
          ? null
          : CustomSpellingConfig.fromJson(
              json['customSpellingConfig'] as Map<String, dynamic>),
      structuredDataExtraction: json['structuredDataExtraction'] as bool?,
      structuredDataExtractionConfig: json['structuredDataExtractionConfig'] ==
              null
          ? null
          : StructuredDataExtractionConfig.fromJson(
              json['structuredDataExtractionConfig'] as Map<String, dynamic>),
      sentimentAnalysis: json['sentimentAnalysis'] as bool?,
      audioToLLM: json['audioToLLM'] as bool?,
      audioToLLMConfig: json['audioToLLMConfig'] == null
          ? null
          : AudioToLLMConfig.fromJson(
              json['audioToLLMConfig'] as Map<String, dynamic>),
      customMetadata: json['customMetadata'] as Map<String, dynamic>?,
      sentences: json['sentences'] as bool?,
      displayMode: json['displayMode'] as String?,
      enhancedPunctuation: json['enhancedPunctuation'] as bool?,
      languageConfig: json['languageConfig'] == null
          ? null
          : LanguageConfig.fromJson(
              json['languageConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranscriptionOptionsToJson(
        TranscriptionOptions instance) =>
    <String, dynamic>{
      'context_prompt': instance.contextPrompt,
      'custom_vocabulary': instance.customVocabulary,
      'custom_vocabulary_config': instance.customVocabularyConfig,
      'language': instance.language,
      'callback': instance.callback,
      'callback_config': instance.callbackConfig,
      'subtitles': instance.subtitles,
      'subtitles_config': instance.subtitlesConfig,
      'diarization': instance.diarization,
      'diarizationConfig': instance.diarizationConfig,
      'translation': instance.translation,
      'translationConfig': instance.translationConfig,
      'summarization': instance.summarization,
      'summarizationConfig': instance.summarizationConfig,
      'moderation': instance.moderation,
      'namedEntityRecognition': instance.namedEntityRecognition,
      'chapterization': instance.chapterization,
      'namesConsistency': instance.namesConsistency,
      'customSpelling': instance.customSpelling,
      'customSpellingConfig': instance.customSpellingConfig,
      'structuredDataExtraction': instance.structuredDataExtraction,
      'structuredDataExtractionConfig': instance.structuredDataExtractionConfig,
      'sentimentAnalysis': instance.sentimentAnalysis,
      'audioToLLM': instance.audioToLLM,
      'audioToLLMConfig': instance.audioToLLMConfig,
      'customMetadata': instance.customMetadata,
      'sentences': instance.sentences,
      'displayMode': instance.displayMode,
      'enhancedPunctuation': instance.enhancedPunctuation,
      'languageConfig': instance.languageConfig,
    };
