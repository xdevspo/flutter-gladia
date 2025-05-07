// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorData _$ErrorDataFromJson(Map<String, dynamic> json) => ErrorData(
      statusCode: (json['status_code'] as num?)?.toInt(),
      exception: json['exception'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ErrorDataToJson(ErrorData instance) => <String, dynamic>{
      'status_code': instance.statusCode,
      'exception': instance.exception,
      'message': instance.message,
    };
