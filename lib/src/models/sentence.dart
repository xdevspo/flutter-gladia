import 'package:gladia/src/models/error_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'sentence.g.dart';

/// Sentence data
@immutable
@JsonSerializable()
class Sentence {
  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'isEmpty')
  final bool isEmpty;
  @JsonKey(name: 'execTime')
  final int execTime;
  @JsonKey(name: 'error')
  final ErrorData? error;
  @JsonKey(name: 'results')
  final List<String>? resultsList;

  /// Creates a new instance of [Sentence]
  const Sentence({
    required this.success,
    required this.isEmpty,
    required this.execTime,
    this.error,
    this.resultsList,
  });

  /// Returns results
  List<String>? get results => resultsList;

  /// Creates [Sentence] from JSON data
  factory Sentence.fromJson(Map<String, dynamic> json) =>
      _$SentenceFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$SentenceToJson(this);
}
