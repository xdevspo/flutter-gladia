import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'diarization_config.g.dart';

/// Diarization data
@immutable
@JsonSerializable()
class DiarizationConfig {
  /// Exact number of speakers in the audio, can only be 1 or 2 if enhanced is true
  /// Required range: x >= 0
  @JsonKey(name: 'number_of_speakers')
  final int? numberOfSpeakers;

  /// Minimum number of speakers in the audio
  /// Required range: x >= 0
  @JsonKey(name: 'min_speakers')
  final int? minSpeakers;

  /// Maximum number of speakers in the audio
  /// Required range: x >= 0
  @JsonKey(name: 'max_speakers')
  final int? maxSpeakers;

  /// [Alpha] Use enhanced diarization for this audio
  /// Default: false
  @JsonKey(name: 'enhanced')
  final bool? enhanced;

  /// Creates a new instance of [DiarizationConfig]
  const DiarizationConfig({
    this.numberOfSpeakers,
    this.minSpeakers,
    this.maxSpeakers,
    this.enhanced,
  });

  /// Creates [DiarizationConfig] from JSON data
  factory DiarizationConfig.fromJson(Map<String, dynamic> json) =>
      _$DiarizationConfigFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$DiarizationConfigToJson(this);
}
