// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diarization_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiarizationConfig _$DiarizationConfigFromJson(Map<String, dynamic> json) =>
    DiarizationConfig(
      numberOfSpeakers: (json['number_of_speakers'] as num?)?.toInt(),
      minSpeakers: (json['min_speakers'] as num?)?.toInt(),
      maxSpeakers: (json['max_speakers'] as num?)?.toInt(),
      enhanced: json['enhanced'] as bool?,
    );

Map<String, dynamic> _$DiarizationConfigToJson(DiarizationConfig instance) =>
    <String, dynamic>{
      'number_of_speakers': instance.numberOfSpeakers,
      'min_speakers': instance.minSpeakers,
      'max_speakers': instance.maxSpeakers,
      'enhanced': instance.enhanced,
    };
