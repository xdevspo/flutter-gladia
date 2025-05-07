// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_transcription_result_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveTranscriptionResultData _$LiveTranscriptionResultDataFromJson(
        Map<String, dynamic> json) =>
    LiveTranscriptionResultData(
      metadata: json['metadata'] == null
          ? null
          : TranscriptionMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>),
      transcription: json['transcription'] == null
          ? null
          : Transcription.fromJson(
              json['transcription'] as Map<String, dynamic>),
      translation: json['translation'] == null
          ? null
          : Translation.fromJson(json['translation'] as Map<String, dynamic>),
      summarization: json['summarization'] == null
          ? null
          : ResultData.fromJson(json['summarization'] as Map<String, dynamic>),
      moderation: json['moderation'] == null
          ? null
          : ResultData.fromJson(json['moderation'] as Map<String, dynamic>),
      namedEntityRecognition: json['named_entity_recognition'] == null
          ? null
          : ResultData.fromJson(
              json['named_entity_recognition'] as Map<String, dynamic>),
      chapters: json['chapters'] == null
          ? null
          : ResultData.fromJson(json['chapters'] as Map<String, dynamic>),
      nameConsistency: json['name_consistency'] == null
          ? null
          : ResultData.fromJson(
              json['name_consistency'] as Map<String, dynamic>),
      customSpelling: json['custom_spelling'] == null
          ? null
          : ResultData.fromJson(
              json['custom_spelling'] as Map<String, dynamic>),
      speakerReidentification: json['speaker_reidentification'] == null
          ? null
          : ResultData.fromJson(
              json['speaker_reidentification'] as Map<String, dynamic>),
      structuredDataExtraction: json['structured_data_extraction'] == null
          ? null
          : ResultData.fromJson(
              json['structured_data_extraction'] as Map<String, dynamic>),
      sentimentAnalysis: json['sentiment_analysis'] == null
          ? null
          : ResultData.fromJson(
              json['sentiment_analysis'] as Map<String, dynamic>),
      audioToLLM: json['audio_to_llm'] == null
          ? null
          : AudioToLLM.fromJson(json['audio_to_llm'] as Map<String, dynamic>),
      sentences: json['sentences'] == null
          ? null
          : Sentence.fromJson(json['sentences'] as Map<String, dynamic>),
      displayMode: json['display_mode'] == null
          ? null
          : ResultData.fromJson(json['display_mode'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveTranscriptionResultDataToJson(
        LiveTranscriptionResultData instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
      'transcription': instance.transcription,
      'translation': instance.translation,
      'summarization': instance.summarization,
      'moderation': instance.moderation,
      'named_entity_recognition': instance.namedEntityRecognition,
      'name_consistency': instance.nameConsistency,
      'custom_spelling': instance.customSpelling,
      'speaker_reidentification': instance.speakerReidentification,
      'structured_data_extraction': instance.structuredDataExtraction,
      'sentiment_analysis': instance.sentimentAnalysis,
      'audio_to_llm': instance.audioToLLM,
      'sentences': instance.sentences,
      'display_mode': instance.displayMode,
      'chapters': instance.chapters,
    };
