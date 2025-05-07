import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'translation_config.g.dart';

@immutable
@JsonSerializable()

/// Translation configuration
class TranslationConfig {
  /// The target language in iso639-1 format
  /// Example: ["en", "fr"]
  @JsonKey(name: 'target_languages')
  final List<String> targetLanguages;

  /// Model you want the translation model to use to translate
  /// Available options: base, enhanced
  /// Default: base
  @JsonKey(name: 'model')
  final String? model;

  /// Align translated utterances with the original ones
  /// Default: true
  @JsonKey(name: 'match_original_utterances')
  final bool? matchOriginalUtterances;

  const TranslationConfig({
    required this.targetLanguages,
    this.model,
    this.matchOriginalUtterances,
  });

  factory TranslationConfig.fromJson(Map<String, dynamic> json) =>
      _$TranslationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationConfigToJson(this);
}
