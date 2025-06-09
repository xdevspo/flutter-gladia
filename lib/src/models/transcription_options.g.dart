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
      diarizationConfig: json['diarization_config'] == null
          ? null
          : DiarizationConfig.fromJson(
              json['diarization_config'] as Map<String, dynamic>),
      translation: json['translation'] as bool?,
      translationConfig: json['translation_config'] == null
          ? null
          : TranslationConfig.fromJson(
              json['translation_config'] as Map<String, dynamic>),
      summarization: json['summarization'] as bool?,
      summarizationConfig: json['summarization_config'] == null
          ? null
          : SummarizationConfig.fromJson(
              json['summarization_config'] as Map<String, dynamic>),
      moderation: json['moderation'] as bool?,
      namedEntityRecognition: json['named_entity_recognition'] as bool?,
      chapterization: json['chapterization'] as bool?,
      namesConsistency: json['names_consistency'] as bool?,
      customSpelling: json['custom_spelling'] as bool?,
      customSpellingConfig: json['custom_spelling_config'] == null
          ? null
          : CustomSpellingConfig.fromJson(
              json['custom_spelling_config'] as Map<String, dynamic>),
      structuredDataExtraction: json['structured_data_extraction'] as bool?,
      structuredDataExtractionConfig:
          json['structured_data_extraction_config'] == null
              ? null
              : StructuredDataExtractionConfig.fromJson(
                  json['structured_data_extraction_config']
                      as Map<String, dynamic>),
      sentimentAnalysis: json['sentiment_analysis'] as bool?,
      audioToLLM: json['audio_to_llm'] as bool?,
      audioToLLMConfig: json['audio_to_llm_config'] == null
          ? null
          : AudioToLLMConfig.fromJson(
              json['audio_to_llm_config'] as Map<String, dynamic>),
      customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
      sentences: json['sentences'] as bool?,
      displayMode: json['display_mode'] as String?,
      enhancedPunctuation: json['enhanced_punctuation'] as bool?,
      languageConfig: json['language_config'] == null
          ? null
          : LanguageConfig.fromJson(
              json['language_config'] as Map<String, dynamic>),
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
      'diarization_config': instance.diarizationConfig,
      'translation': instance.translation,
      'translation_config': instance.translationConfig,
      'summarization': instance.summarization,
      'summarization_config': instance.summarizationConfig,
      'moderation': instance.moderation,
      'named_entity_recognition': instance.namedEntityRecognition,
      'chapterization': instance.chapterization,
      'names_consistency': instance.namesConsistency,
      'custom_spelling': instance.customSpelling,
      'custom_spelling_config': instance.customSpellingConfig,
      'structured_data_extraction': instance.structuredDataExtraction,
      'structured_data_extraction_config':
          instance.structuredDataExtractionConfig,
      'sentiment_analysis': instance.sentimentAnalysis,
      'audio_to_llm': instance.audioToLLM,
      'audio_to_llm_config': instance.audioToLLMConfig,
      'custom_metadata': instance.customMetadata,
      'sentences': instance.sentences,
      'display_mode': instance.displayMode,
      'enhanced_punctuation': instance.enhancedPunctuation,
      'language_config': instance.languageConfig,
    };
