// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitles_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubtitlesConfig _$SubtitlesConfigFromJson(Map<String, dynamic> json) =>
    SubtitlesConfig(
      formats:
          (json['formats'] as List<dynamic>?)?.map((e) => e as String).toList(),
      minimumDuration: (json['minimum_duration'] as num?)?.toInt(),
      maximumDuration: (json['maximum_duration'] as num?)?.toInt(),
      maximumChartersPerRow:
          (json['maximum_charters_per_row'] as num?)?.toInt(),
      maximumRowsPerCaption:
          (json['maximum_rows_per_caption'] as num?)?.toInt(),
      style: json['style'] as String?,
    );

Map<String, dynamic> _$SubtitlesConfigToJson(SubtitlesConfig instance) =>
    <String, dynamic>{
      'formats': instance.formats,
      'minimum_duration': instance.minimumDuration,
      'maximum_duration': instance.maximumDuration,
      'maximum_charters_per_row': instance.maximumChartersPerRow,
      'maximum_rows_per_caption': instance.maximumRowsPerCaption,
      'style': instance.style,
    };
