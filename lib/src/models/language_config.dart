import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'language_config.g.dart';

/// Language configuration for transcription
@immutable
@JsonSerializable()
class LanguageConfig {
  /// Languages for determination
  /// If a single language is set, it will be used for transcription
  /// Otherwise, the language will be determined automatically
  @JsonKey(name: 'languages')
  final List<String>? languages;

  /// If true, the language will be determined for each utterance
  /// Otherwise, the language will be determined for the first utterance and used for the rest
  /// Ignored if a single language is set
  /// Default: false
  @JsonKey(name: 'code_switching')
  final bool? codeSwitching;

  /// Creates a new instance of [LanguageConfig]
  const LanguageConfig({
    this.languages,
    this.codeSwitching,
  });

  /// Creates [LanguageConfig] from JSON data
  factory LanguageConfig.fromJson(Map<String, dynamic> json) =>
      _$LanguageConfigFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$LanguageConfigToJson(this);
}
