import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'subtitles_config.g.dart';

/// Subtitle data
@immutable
@JsonSerializable()
class SubtitlesConfig {
  /// Subtitles formats you want your transcription to be formatted to
  /// Available options: srt, vtt
  @JsonKey(name: 'formats')
  final List<String>? formats;

  /// Minimum duration of a subtitle in seconds
  /// Required range: x >= 0
  @JsonKey(name: 'minimum_duration')
  final int? minimumDuration;

  /// Maximum duration of a subtitle in seconds
  /// Required range: 1 <= x <= 30
  @JsonKey(name: 'maximum_duration')
  final int? maximumDuration;

  /// Maximum number of characters per row in a subtitle
  /// Required range: x >= 1
  @JsonKey(name: 'maximum_charters_per_row')
  final int? maximumChartersPerRow;

  /// Maximum number of rows per caption
  /// Required range: 1 <= x <= 5
  @JsonKey(name: 'maximum_rows_per_caption')
  final int? maximumRowsPerCaption;

  /// Style of the subtitles
  /// Available options: default, compliance
  @JsonKey(name: 'style')
  final String? style;

  /// Creates a new instance of [SubtitleData]
  const SubtitlesConfig({
    this.formats,
    this.minimumDuration,
    this.maximumDuration,
    this.maximumChartersPerRow,
    this.maximumRowsPerCaption,
    this.style,
  });

  /// Creates [SubtitlesConfig] from JSON data
  factory SubtitlesConfig.fromJson(Map<String, dynamic> json) =>
      _$SubtitlesConfigFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$SubtitlesConfigToJson(this);
}
