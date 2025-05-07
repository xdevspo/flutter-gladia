import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'audio_to_llm_config.g.dart';

@immutable
@JsonSerializable()
class AudioToLLMConfig {
  /// The list of prompts applied on the audio transcription
  /// Example: ["Extract the key points from the transcription"]
  @JsonKey(name: 'prompts')
  final List<String>? prompts;

  const AudioToLLMConfig({
    this.prompts,
  });

  factory AudioToLLMConfig.fromJson(Map<String, dynamic> json) =>
      _$AudioToLLMConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AudioToLLMConfigToJson(this);
}
