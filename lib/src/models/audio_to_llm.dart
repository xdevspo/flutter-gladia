import 'package:gladia/src/models/result_data.dart';
import 'package:gladia/src/models/error_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'audio_to_llm.g.dart';

@immutable
@JsonSerializable()
class AudioToLLM extends ResultData {
  @JsonKey(name: 'results')
  final AudioToLLMResult? resultsList;

  const AudioToLLM({
    super.success,
    super.isEmpty,
    super.execTime,
    super.error,
    this.resultsList,
  });

  factory AudioToLLM.fromJson(Map<String, dynamic> json) =>
      _$AudioToLLMFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AudioToLLMToJson(this);
}

@immutable
@JsonSerializable()
class AudioToLLMResult extends ResultData {
  @JsonKey(name: 'results')
  final ResultItem? resultsItem;

  const AudioToLLMResult({
    super.success,
    super.isEmpty,
    super.execTime,
    super.error,
    this.resultsItem,
  });

  factory AudioToLLMResult.fromJson(Map<String, dynamic> json) =>
      _$AudioToLLMResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AudioToLLMResultToJson(this);
}

@immutable
@JsonSerializable()
class ResultItem {
  @JsonKey(name: 'prompt')
  final String? prompt;
  @JsonKey(name: 'response')
  final String? response;

  const ResultItem({
    this.prompt,
    this.response,
  });

  factory ResultItem.fromJson(Map<String, dynamic> json) =>
      _$ResultItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResultItemToJson(this);
}
