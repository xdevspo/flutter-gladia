// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageConfig _$LanguageConfigFromJson(Map<String, dynamic> json) =>
    LanguageConfig(
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      codeSwitching: json['code_switching'] as bool?,
    );

Map<String, dynamic> _$LanguageConfigToJson(LanguageConfig instance) =>
    <String, dynamic>{
      'languages': instance.languages,
      'code_switching': instance.codeSwitching,
    };
