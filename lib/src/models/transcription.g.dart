// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transcription _$TranscriptionFromJson(Map<String, dynamic> json) =>
    Transcription(
      fullTranscript: json['full_transcript'] as String,
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

Map<String, dynamic> _$TranscriptionToJson(Transcription instance) =>
    <String, dynamic>{
      'full_transcript': instance.fullTranscript,
      'languages': instance.languages,
      'sentences': instance.sentences,
      'subtitles': instance.subtitles,
      'utterances': instance.utterances,
    };
