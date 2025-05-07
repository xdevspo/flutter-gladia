// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Translation _$TranslationFromJson(Map<String, dynamic> json) => Translation(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      translationResults: (json['results'] as List<dynamic>?)
          ?.map((e) => TranslationResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.translationResults,
    };
