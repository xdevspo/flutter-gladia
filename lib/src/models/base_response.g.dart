// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      requestId: json['request_id'] as String?,
      version: (json['version'] as num?)?.toInt(),
      createdAt: BaseResponse.dateTimeFromJson(json['created_at']),
      completedAt: BaseResponse.dateTimeFromJson(json['completed_at']),
      customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
      errorCode: (json['error_code'] as num?)?.toInt(),
      kind: json['kind'] as String?,
    );

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
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
    };
