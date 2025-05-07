import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'subtitle.g.dart';

/// Subtitle data
@immutable
@JsonSerializable()
class Subtitle {
  /// Format of subtitles
  @JsonKey(name: 'format')
  final String format;

  /// Text of subtitles
  @JsonKey(name: 'subtitles')
  final String subtitles;

  /// Creates a new instance of [SubtitleData]
  const Subtitle({
    required this.format,
    required this.subtitles,
  });

  /// Creates [Subtitle] from JSON data
  factory Subtitle.fromJson(Map<String, dynamic> json) =>
      _$SubtitleFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$SubtitleToJson(this);
}
