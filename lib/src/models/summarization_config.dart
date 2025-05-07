import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'summarization_config.g.dart';

@immutable
@JsonSerializable()
class SummarizationConfig {
  /// The type of summarization to apply
  /// Available options: general, bullet_points, concise
  @JsonKey(name: 'type')
  final String? type;

  const SummarizationConfig({
    this.type,
  });

  factory SummarizationConfig.fromJson(Map<String, dynamic> json) =>
      _$SummarizationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SummarizationConfigToJson(this);
}
