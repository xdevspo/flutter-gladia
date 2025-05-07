// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_init_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionInitResult _$TranscriptionInitResultFromJson(
        Map<String, dynamic> json) =>
    TranscriptionInitResult(
      id: json['id'] as String,
      resultUrl: json['result_url'] as String,
      requestId: json['request_id'] as String?,
    );

Map<String, dynamic> _$TranscriptionInitResultToJson(
        TranscriptionInitResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request_id': instance.requestId,
      'result_url': instance.resultUrl,
    };
