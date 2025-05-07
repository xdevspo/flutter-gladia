// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_vocabulary_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomVocabularyConfig _$CustomVocabularyConfigFromJson(
        Map<String, dynamic> json) =>
    CustomVocabularyConfig(
      vocabulary: CustomVocabularyConfigVocabulary.fromJson(
          json['vocabulary'] as Map<String, dynamic>),
      defaultIntensity: (json['default_intensity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CustomVocabularyConfigToJson(
        CustomVocabularyConfig instance) =>
    <String, dynamic>{
      'vocabulary': instance.vocabulary,
      'default_intensity': instance.defaultIntensity,
    };

CustomVocabularyConfigVocabulary _$CustomVocabularyConfigVocabularyFromJson(
        Map<String, dynamic> json) =>
    CustomVocabularyConfigVocabulary(
      value: json['value'] as String,
      pronunciations: (json['pronunciations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      intensity: (json['intensity'] as num?)?.toDouble(),
      language: json['language'] as String?,
    );

Map<String, dynamic> _$CustomVocabularyConfigVocabularyToJson(
        CustomVocabularyConfigVocabulary instance) =>
    <String, dynamic>{
      'value': instance.value,
      'intensity': instance.intensity,
      'pronunciations': instance.pronunciations,
      'language': instance.language,
    };
