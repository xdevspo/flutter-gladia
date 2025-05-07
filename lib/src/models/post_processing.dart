import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'post_processing_summarization_config.dart';

part 'post_processing.g.dart';

@immutable
@JsonSerializable()
class PostProcessing {
  /// If true, generates summarization for the whole transcription.
  /// Default: false
  @JsonKey(name: 'summarization')
  final bool? summarization;

  /// Summarization configuration, if summarization is enabled
  @JsonKey(name: 'summarization_config')
  final PostProcessingSummarizationConfig? summarizationConfig;

  /// If true, generates chapters for the whole transcription
  /// Default: false
  @JsonKey(name: 'chapterization')
  final bool? chapterization;

  const PostProcessing({
    this.summarization,
    this.summarizationConfig,
    this.chapterization,
  });

  factory PostProcessing.fromJson(Map<String, dynamic> json) =>
      _$PostProcessingFromJson(json);
  Map<String, dynamic> toJson() => _$PostProcessingToJson(this);
}
