// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultData _$ResultDataFromJson(Map<String, dynamic> json) => ResultData(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      results: json['results'] as String?,
    );

Map<String, dynamic> _$ResultDataToJson(ResultData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.results,
    };
