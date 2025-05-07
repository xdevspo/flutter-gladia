// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_processing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostProcessing _$PostProcessingFromJson(Map<String, dynamic> json) =>
    PostProcessing(
      summarization: json['summarization'] as bool?,
      summarizationConfig: json['summarization_config'] == null
          ? null
          : PostProcessingSummarizationConfig.fromJson(
              json['summarization_config'] as Map<String, dynamic>),
      chapterization: json['chapterization'] as bool?,
    );

Map<String, dynamic> _$PostProcessingToJson(PostProcessing instance) =>
    <String, dynamic>{
      'summarization': instance.summarization,
      'summarization_config': instance.summarizationConfig,
      'chapterization': instance.chapterization,
    };
