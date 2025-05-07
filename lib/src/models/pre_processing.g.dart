// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_processing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreProcessing _$PreProcessingFromJson(Map<String, dynamic> json) =>
    PreProcessing(
      audioEnhancer: json['audio_enhancer'] as bool?,
      speechThreshold: (json['speech_threshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PreProcessingToJson(PreProcessing instance) =>
    <String, dynamic>{
      'audio_enhancer': instance.audioEnhancer,
      'speech_threshold': instance.speechThreshold,
    };
