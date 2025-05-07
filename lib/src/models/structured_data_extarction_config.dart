import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'structured_data_extarction_config.g.dart';

@immutable
@JsonSerializable()
class StructuredDataExtractionConfig {
  /// The list of classes to extract from the audio transcription
  /// Example: ["Persons", "Organizations"]
  @JsonKey(name: 'classes')
  final List<String>? classes;

  const StructuredDataExtractionConfig({
    this.classes,
  });

  factory StructuredDataExtractionConfig.fromJson(Map<String, dynamic> json) =>
      _$StructuredDataExtractionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$StructuredDataExtractionConfigToJson(this);
}
