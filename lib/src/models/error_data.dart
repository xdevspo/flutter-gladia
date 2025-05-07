import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'error_data.g.dart';

/// Error information in function result
@immutable
@JsonSerializable()
class ErrorData {
  /// Error status code
  @JsonKey(name: 'status_code')
  final int? statusCode;

  /// Exception type
  @JsonKey(name: 'exception')
  final String? exception;

  /// Error message
  @JsonKey(name: 'message')
  final String? message;

  /// Creates a new instance of [ErrorData]
  const ErrorData({
    this.statusCode,
    this.exception,
    this.message,
  });

  /// Creates [FeatureError] from JSON data
  factory ErrorData.fromJson(Map<String, dynamic> json) =>
      _$ErrorDataFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$ErrorDataToJson(this);
}
