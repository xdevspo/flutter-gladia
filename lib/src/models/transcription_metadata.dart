import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'transcription_metadata.g.dart';

/// Transcription result metadata
@immutable
@JsonSerializable()
class TranscriptionMetadata {
  /// Audio duration in seconds
  @JsonKey(name: 'audio_duration')
  final double? audioDuration;

  /// Number of distinct audio channels
  @JsonKey(name: 'number_of_distinct_channels')
  final int? numberOfDistinctChannels;

  /// Billing time
  @JsonKey(name: 'billing_time')
  final double? billingTime;

  /// Transcription processing time in seconds
  @JsonKey(name: 'transcription_time')
  final double? transcriptionTime;

  /// Creates a new instance of [TranscriptionMetadata]
  const TranscriptionMetadata({
    this.audioDuration,
    this.numberOfDistinctChannels,
    this.billingTime,
    this.transcriptionTime,
  });

  /// Creates [TranscriptionMetadata] from JSON data
  factory TranscriptionMetadata.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionMetadataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionMetadataToJson(this);
}
