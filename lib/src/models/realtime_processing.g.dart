// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_processing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeProcessing _$RealtimeProcessingFromJson(Map<String, dynamic> json) =>
    RealtimeProcessing(
      wordsAccurateTimestamps: json['words_accurate_timestamps'] as bool?,
      customVocabulary: json['custom_vocabulary'] as bool?,
      customVocabularyConfig: json['custom_vocabulary_config'] == null
          ? null
          : CustomVocabularyConfig.fromJson(
              json['custom_vocabulary_config'] as Map<String, dynamic>),
      customSpelling: json['custom_spelling'] as bool?,
      customSpellingConfig: json['custom_spelling_config'] == null
          ? null
          : CustomSpellingConfig.fromJson(
              json['custom_spelling_config'] as Map<String, dynamic>),
      translation: json['translation'] as bool?,
      translationConfig: json['translation_config'] == null
          ? null
          : TranslationConfig.fromJson(
              json['translation_config'] as Map<String, dynamic>),
      namedEntityRecognition: json['named_entity_recognition'] as bool?,
      sentimentAnalysis: json['sentiment_analysis'] as bool?,
    );

Map<String, dynamic> _$RealtimeProcessingToJson(RealtimeProcessing instance) =>
    <String, dynamic>{
      'words_accurate_timestamps': instance.wordsAccurateTimestamps,
      'custom_vocabulary': instance.customVocabulary,
      'custom_vocabulary_config': instance.customVocabularyConfig,
      'custom_spelling': instance.customSpelling,
      'custom_spelling_config': instance.customSpellingConfig,
      'translation': instance.translation,
      'translation_config': instance.translationConfig,
      'named_entity_recognition': instance.namedEntityRecognition,
      'sentiment_analysis': instance.sentimentAnalysis,
    };
