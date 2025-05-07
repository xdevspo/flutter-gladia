// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfo _$FileInfoFromJson(Map<String, dynamic> json) => FileInfo(
      id: json['id'] as String?,
      filename: json['filename'] as String?,
      source: json['source'] as String?,
      audioDuration: (json['audio_duration'] as num?)?.toDouble(),
      numberOfChannels: (json['number_of_channels'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FileInfoToJson(FileInfo instance) => <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'source': instance.source,
      'audio_duration': instance.audioDuration,
      'number_of_channels': instance.numberOfChannels,
    };
