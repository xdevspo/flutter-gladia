import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'file_info.g.dart';

/// File information from Gladia API
@immutable
@JsonSerializable()
class FileInfo {
  /// File identifier
  @JsonKey(name: 'id')
  final String? id;

  /// Filename
  @JsonKey(name: 'filename')
  final String? filename;

  /// File source
  @JsonKey(name: 'source')
  final String? source;

  /// Audio duration in seconds
  @JsonKey(name: 'audio_duration')
  final double? audioDuration;

  /// Number of audio channels
  @JsonKey(name: 'number_of_channels')
  final int? numberOfChannels;

  /// Creates a new instance of [FileInfo]
  const FileInfo({
    this.id,
    this.filename,
    this.source,
    this.audioDuration,
    this.numberOfChannels,
  });

  /// Creates [FileInfo] from JSON data
  factory FileInfo.fromJson(Map<String, dynamic> json) =>
      _$FileInfoFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$FileInfoToJson(this);
}
