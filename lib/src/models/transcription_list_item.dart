import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_response.dart';
import 'file_info.dart';
import 'transcription_options.dart';
import 'transcription_result.dart';

part 'transcription_list_item.g.dart';

@immutable
@JsonSerializable()
class TranscriptionListItem extends BaseResponse {
  /// Audio file information
  @JsonKey(name: 'file')
  final FileInfo? file;

  /// Request parameters
  @JsonKey(name: 'request_params')
  final TranscriptionOptions? requestParams;

  /// Transcription results and additional functions
  @JsonKey(name: 'result')
  final TranscriptionResultData? result;

  /// Creates a new instance of [TranscriptionListItem]
  const TranscriptionListItem({
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

  /// Creates [TranscriptionListItem] from JSON data
  factory TranscriptionListItem.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionListItemFromJson(json);

  /// Converts to JSON
  @override
  Map<String, dynamic> toJson() => _$TranscriptionListItemToJson(this);
}
