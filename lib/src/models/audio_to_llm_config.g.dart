// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_to_llm_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioToLLMConfig _$AudioToLLMConfigFromJson(Map<String, dynamic> json) =>
    AudioToLLMConfig(
      prompts:
          (json['prompts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AudioToLLMConfigToJson(AudioToLLMConfig instance) =>
    <String, dynamic>{
      'prompts': instance.prompts,
    };
