// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionListItem _$TranscriptionListItemFromJson(
        Map<String, dynamic> json) =>
    TranscriptionListItem(
      id: json['id'] as String,
      status: json['status'] as String,
      requestId: json['request_id'] as String?,
      version: (json['version'] as num?)?.toInt(),
      createdAt: BaseResponse.dateTimeFromJson(json['created_at']),
      completedAt: BaseResponse.dateTimeFromJson(json['completed_at']),
      customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
      errorCode: (json['error_code'] as num?)?.toInt(),
      kind: json['kind'] as String?,
      file: json['file'] == null
          ? null
          : FileInfo.fromJson(json['file'] as Map<String, dynamic>),
      requestParams: json['request_params'] == null
          ? null
          : TranscriptionOptions.fromJson(
              json['request_params'] as Map<String, dynamic>),
      result: json['result'] == null
          ? null
          : TranscriptionResultData.fromJson(
              json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranscriptionListItemToJson(
        TranscriptionListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request_id': instance.requestId,
      'version': instance.version,
      'status': instance.status,
      'created_at': BaseResponse.dateTimeToJson(instance.createdAt),
      'completed_at': BaseResponse.dateTimeToJson(instance.completedAt),
      'custom_metadata': instance.customMetadata,
      'error_code': instance.errorCode,
      'kind': instance.kind,
      'file': instance.file,
      'request_params': instance.requestParams,
      'result': instance.result,
    };
