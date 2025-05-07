// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utterance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utterance _$UtteranceFromJson(Map<String, dynamic> json) => Utterance(
      text: json['text'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      speaker: json['speaker'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      language: json['language'] as String?,
      channel: (json['channel'] as num?)?.toInt(),
      words: (json['words'] as List<dynamic>?)
          ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UtteranceToJson(Utterance instance) => <String, dynamic>{
      'text': instance.text,
      'start': instance.start,
      'end': instance.end,
      'speaker': instance.speaker,
      'confidence': instance.confidence,
      'language': instance.language,
      'channel': instance.channel,
      'words': instance.words,
    };
