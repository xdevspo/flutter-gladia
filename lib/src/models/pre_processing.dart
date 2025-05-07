import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'pre_processing.g.dart';

/// Configuration for pre-processing
@immutable
@JsonSerializable()
class PreProcessing {
  /// Whether to apply audio quality enhancement
  @JsonKey(name: 'audio_enhancer')
  final bool? audioEnhancer;

  /// Speech detection sensitivity
  /// A value close to 1 makes the detection more strict
  /// Range: 0 <= x <= 1
  @JsonKey(name: 'speech_threshold')
  final double? speechThreshold;

  /// Creates a new instance of [PreProcessing]
  const PreProcessing({
    this.audioEnhancer,
    this.speechThreshold,
  });

  /// Creates [PreProcessing] from JSON data
  factory PreProcessing.fromJson(Map<String, dynamic> json) =>
      _$PreProcessingFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$PreProcessingToJson(this);
}
