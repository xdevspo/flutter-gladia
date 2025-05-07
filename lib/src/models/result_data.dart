import 'package:gladia/src/models/error_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'result_data.g.dart';

/// Base class for feature function results
@immutable
@JsonSerializable()
class ResultData {
  /// Success status
  @JsonKey(name: 'success')
  final bool? success;

  /// Empty result indicator
  @JsonKey(name: 'isEmpty')
  final bool? isEmpty;

  /// Execution time
  @JsonKey(name: 'execTime')
  final double? execTime;

  /// Error information if unsuccessful
  @JsonKey(name: 'error')
  final ErrorData? error;

  /// Results data
  @JsonKey(name: 'results')
  final String? results;

  /// Creates a new instance of [ResultData]
  const ResultData({
    this.success,
    this.isEmpty,
    this.execTime,
    this.error,
    this.results,
  });

  /// Creates [ResultData] from JSON data
  factory ResultData.fromJson(Map<String, dynamic> json) =>
      _$ResultDataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$ResultDataToJson(this);
}
