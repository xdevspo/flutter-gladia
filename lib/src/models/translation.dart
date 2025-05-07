import 'package:gladia/src/models/error_data.dart';
import 'package:gladia/src/models/translation_result.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'translation.g.dart';

@immutable
@JsonSerializable()
class Translation {
  @JsonKey(name: 'success')
  final bool? success;
  @JsonKey(name: 'isEmpty')
  final bool? isEmpty;
  @JsonKey(name: 'execTime')
  final double? execTime;
  @JsonKey(name: 'error')
  final ErrorData? error;
  @JsonKey(name: 'results')
  final List<TranslationResult>? translationResults;

  const Translation({
    this.success,
    this.isEmpty,
    this.execTime,
    this.error,
    this.translationResults,
  });

  /// Creates [Translation] from JSON data
  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}
