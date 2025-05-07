import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// Base class for Gladia API response
@immutable
@JsonSerializable()
class BaseResponse {
  /// Transcription identifier
  final String id;

  /// Request identifier
  @JsonKey(name: 'request_id')
  final String? requestId;

  /// API version
  final int? version;

  /// Request status
  final String status;

  /// Request creation time
  @JsonKey(
      name: 'created_at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime? createdAt;

  /// Request completion time
  @JsonKey(
      name: 'completed_at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime? completedAt;

  /// Custom metadata
  @JsonKey(name: 'custom_metadata')
  final Map<String, dynamic>? customMetadata;

  /// Error code, if any
  @JsonKey(name: 'error_code')
  final int? errorCode;

  /// Request type
  final String? kind;

  /// Creates a new instance of [BaseResponse]
  const BaseResponse({
    required this.id,
    required this.status,
    this.requestId,
    this.version,
    this.createdAt,
    this.completedAt,
    this.customMetadata,
    this.errorCode,
    this.kind,
  });

  /// Creates [BaseResponse] from JSON data
  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);

  /// Converts string to DateTime
  static DateTime? dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Converts DateTime to ISO 8601 string
  static String? dateTimeToJson(DateTime? date) {
    return date?.toIso8601String();
  }
}
