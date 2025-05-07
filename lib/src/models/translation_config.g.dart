// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationConfig _$TranslationConfigFromJson(Map<String, dynamic> json) =>
    TranslationConfig(
      targetLanguages: (json['target_languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      model: json['model'] as String?,
      matchOriginalUtterances: json['match_original_utterances'] as bool?,
    );

Map<String, dynamic> _$TranslationConfigToJson(TranslationConfig instance) =>
    <String, dynamic>{
      'target_languages': instance.targetLanguages,
      'model': instance.model,
      'match_original_utterances': instance.matchOriginalUtterances,
    };
