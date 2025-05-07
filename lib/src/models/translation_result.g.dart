// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationResult _$TranslationResultFromJson(Map<String, dynamic> json) =>
    TranslationResult(
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      fullTranscript: json['fullTranscript'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sentences: (json['sentences'] as List<dynamic>?)
          ?.map((e) => Sentence.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => Subtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      utterances: (json['utterances'] as List<dynamic>?)
          ?.map((e) => Utterance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationResultToJson(TranslationResult instance) =>
    <String, dynamic>{
      'error': instance.error,
      'fullTranscript': instance.fullTranscript,
      'languages': instance.languages,
      'sentences': instance.sentences,
      'subtitles': instance.subtitles,
      'utterances': instance.utterances,
    };
