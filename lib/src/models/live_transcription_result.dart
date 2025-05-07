import 'package:gladia/src/models/live_transcription_result_data.dart';
import 'package:gladia/src/models/utterance.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_response.dart';
import 'file_info.dart';
import 'live_transcription_options.dart';

part 'live_transcription_result.g.dart';

/// Complete audio transcription result from Gladia API
@immutable
@JsonSerializable()
class LiveTranscriptionResult extends BaseResponse {
  /// Audio file information
  @JsonKey(name: 'file')
  final FileInfo? file;

  /// Request parameters
  @JsonKey(name: 'request_params')
  final LiveTranscriptionOptions? requestParams;

  /// Transcription results and additional functions
  @JsonKey(name: 'result')
  final LiveTranscriptionResultData? result;

  /// Creates a new instance of [LiveTranscriptionResult]
  const LiveTranscriptionResult({
    required super.id,
    required super.status,
    super.requestId,
    super.version,
    super.createdAt,
    super.completedAt,
    super.customMetadata,
    super.errorCode,
    super.kind,
    this.file,
    this.requestParams,
    this.result,
  });

  /// Returns the full transcription text for compatibility with the old version
  String get text => result?.transcription?.fullTranscript ?? '';

  /// Returns the language for compatibility with the old version
  String? get language {
    final languages = result?.transcription?.languages;
    return languages != null && languages.isNotEmpty ? languages.first : null;
  }

  /// Returns segments for compatibility with the old version
  List<Utterance>? get utterances => result?.transcription?.utterances;

  /// Creates [LiveTranscriptionResult] from JSON data
  factory LiveTranscriptionResult.fromJson(Map<String, dynamic> json) =>
      _$LiveTranscriptionResultFromJson(json);

  /// Converts to JSON
  @override
  Map<String, dynamic> toJson() => _$LiveTranscriptionResultToJson(this);
}
