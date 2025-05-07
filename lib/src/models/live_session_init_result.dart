import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'live_session_init_result.g.dart';

/// Model of real-time speech recognition session initialization result
@immutable
@JsonSerializable()
class LiveSessionInitResult {
  /// Session identifier
  @JsonKey(name: 'id')
  final String id;

  /// URL for WebSocket connection
  @JsonKey(name: 'url')
  final String url;

  /// Creates a new instance of [LiveSessionInitResult]
  const LiveSessionInitResult({
    required this.id,
    required this.url,
  });

  /// Creates [LiveSessionInitResult] from JSON data
  factory LiveSessionInitResult.fromJson(Map<String, dynamic> json) =>
      _$LiveSessionInitResultFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$LiveSessionInitResultToJson(this);
}
