import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'word.g.dart';

/// Word with time stamp
@immutable
@JsonSerializable()
class Word {
  /// Word text
  @JsonKey(name: 'word')
  final String text;

  /// Word start time in seconds
  @JsonKey(name: 'start')
  final double start;

  /// Word end time in seconds
  @JsonKey(name: 'end')
  final double end;

  /// Confidence in identification (0 to 1)
  @JsonKey(name: 'confidence')
  final double? confidence;

  /// Creates a new instance of [Word]
  const Word({
    required this.text,
    required this.start,
    required this.end,
    this.confidence,
  });

  /// Creates [Word] from JSON data
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
