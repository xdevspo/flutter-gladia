// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sentence _$SentenceFromJson(Map<String, dynamic> json) => Sentence(
      success: json['success'] as bool,
      isEmpty: json['isEmpty'] as bool,
      execTime: (json['execTime'] as num).toInt(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      resultsList:
          (json['results'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SentenceToJson(Sentence instance) => <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.resultsList,
    };
