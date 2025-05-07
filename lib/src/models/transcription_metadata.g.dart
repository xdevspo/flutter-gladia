// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionMetadata _$TranscriptionMetadataFromJson(
        Map<String, dynamic> json) =>
    TranscriptionMetadata(
      audioDuration: (json['audio_duration'] as num?)?.toDouble(),
      numberOfDistinctChannels:
          (json['number_of_distinct_channels'] as num?)?.toInt(),
      billingTime: (json['billing_time'] as num?)?.toDouble(),
      transcriptionTime: (json['transcription_time'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TranscriptionMetadataToJson(
        TranscriptionMetadata instance) =>
    <String, dynamic>{
      'audio_duration': instance.audioDuration,
      'number_of_distinct_channels': instance.numberOfDistinctChannels,
      'billing_time': instance.billingTime,
      'transcription_time': instance.transcriptionTime,
    };
