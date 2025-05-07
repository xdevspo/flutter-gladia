import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'custom_spelling_config.g.dart';

@immutable
@JsonSerializable()

/// Custom spelling configuration
class CustomSpellingConfig {
  /// The list of spelling applied on the audio transcription
  /// Example:
  /// {
  ///   "Gettleman": ["gettleman"],
  ///   "SQL": ["Sequel"]
  /// }
  @JsonKey(name: 'spelling_dictionary')
  final Map<String, dynamic> spellingDictionary;

  const CustomSpellingConfig({
    required this.spellingDictionary,
  });

  factory CustomSpellingConfig.fromJson(Map<String, dynamic> json) =>
      _$CustomSpellingConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CustomSpellingConfigToJson(this);
}
