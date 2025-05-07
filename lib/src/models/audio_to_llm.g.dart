// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_to_llm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioToLLM _$AudioToLLMFromJson(Map<String, dynamic> json) => AudioToLLM(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      resultsList: json['results'] == null
          ? null
          : AudioToLLMResult.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AudioToLLMToJson(AudioToLLM instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.resultsList,
    };

AudioToLLMResult _$AudioToLLMResultFromJson(Map<String, dynamic> json) =>
    AudioToLLMResult(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      resultsItem: json['results'] == null
          ? null
          : ResultItem.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AudioToLLMResultToJson(AudioToLLMResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.resultsItem,
    };

ResultItem _$ResultItemFromJson(Map<String, dynamic> json) => ResultItem(
      prompt: json['prompt'] as String?,
      response: json['response'] as String?,
    );

Map<String, dynamic> _$ResultItemToJson(ResultItem instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'response': instance.response,
    };
