import 'package:gladia/src/models/error_data.dart';
import 'package:gladia/src/models/sentence.dart';
import 'package:gladia/src/models/utterance.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'subtitle.dart';

part 'translation_result.g.dart';

@immutable
@JsonSerializable()
class TranslationResult {
  final ErrorData? error;
  final String? fullTranscript;
  final List<String>? languages;
  final List<Sentence>? sentences;
  final List<Subtitle>? subtitles;
  final List<Utterance>? utterances;

  const TranslationResult({
    this.error,
    this.fullTranscript,
    this.languages,
    this.sentences,
    this.subtitles,
    this.utterances,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      _$TranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationResultToJson(this);
}
