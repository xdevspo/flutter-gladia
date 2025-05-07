import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'transcription_init_result.g.dart';

/// Transcription initialization result from Gladia API
@immutable
@JsonSerializable()
class TranscriptionInitResult {
  /// Transcription identifier
  @JsonKey(name: 'id')
  final String id;

  /// Request identifier (in new API)
  @JsonKey(name: 'request_id')
  final String? requestId;

  /// URL for obtaining transcription result
  @JsonKey(name: 'result_url')
  final String resultUrl;

  /// Creates a new instance of [TranscriptionInitResult]
  const TranscriptionInitResult({
    required this.id,
    required this.resultUrl,
    this.requestId,
  });

  /// Creates [TranscriptionInitResult] from JSON data
  factory TranscriptionInitResult.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionInitResultFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionInitResultToJson(this);
}
