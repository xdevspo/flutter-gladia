import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'post_processing_summarization_config.g.dart';

@immutable
@JsonSerializable()

/// Summarization configuration
class PostProcessingSummarizationConfig {
  /// The type of summarization to apply
  /// Available options: general, bullet_points, concise
  /// Default: general
  @JsonKey(name: 'type')
  final String? type;

  PostProcessingSummarizationConfig({
    this.type,
  });

  factory PostProcessingSummarizationConfig.fromJson(
          Map<String, dynamic> json) =>
      _$PostProcessingSummarizationConfigFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PostProcessingSummarizationConfigToJson(this);
}
