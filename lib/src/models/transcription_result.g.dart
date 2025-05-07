// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionResult _$TranscriptionResultFromJson(Map<String, dynamic> json) =>
    TranscriptionResult(
      id: json['id'] as String,
      status: json['status'] as String,
      requestId: json['request_id'] as String?,
      version: (json['version'] as num?)?.toInt(),
      createdAt: BaseResponse.dateTimeFromJson(json['created_at']),
      completedAt: BaseResponse.dateTimeFromJson(json['completed_at']),
      customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
      errorCode: (json['error_code'] as num?)?.toInt(),
      kind: json['kind'] as String?,
      file: json['file'] == null
          ? null
          : FileInfo.fromJson(json['file'] as Map<String, dynamic>),
      requestParams: TranscriptionResult._convertFromRequestParams(
          json['request_params'] as Map<String, dynamic>?),
      result: json['result'] == null
          ? null
          : TranscriptionResultData.fromJson(
              json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranscriptionResultToJson(
        TranscriptionResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request_id': instance.requestId,
      'version': instance.version,
      'status': instance.status,
      'created_at': BaseResponse.dateTimeToJson(instance.createdAt),
      'completed_at': BaseResponse.dateTimeToJson(instance.completedAt),
      'custom_metadata': instance.customMetadata,
      'error_code': instance.errorCode,
      'kind': instance.kind,
      'file': instance.file,
      'request_params': instance.requestParams,
      'result': instance.result,
    };

TranscriptionResultData _$TranscriptionResultDataFromJson(
        Map<String, dynamic> json) =>
    TranscriptionResultData(
      metadata: json['metadata'] == null
          ? null
          : TranscriptionMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>),
      transcription: json['transcription'] == null
          ? null
          : TranscriptionData.fromJson(
              json['transcription'] as Map<String, dynamic>),
      translation:
          _resultDataFromJson(json['translation'] as Map<String, dynamic>?),
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
          : ResultData.fromJson(json['audio_to_llm'] as Map<String, dynamic>),
      sentences: json['sentences'] == null
          ? null
          : ResultData.fromJson(json['sentences'] as Map<String, dynamic>),
      displayMode: json['display_mode'] == null
          ? null
          : ResultData.fromJson(json['display_mode'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranscriptionResultDataToJson(
        TranscriptionResultData instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
      'transcription': instance.transcription,
      'translation': _resultDataToJson(instance.translation),
      'summarization': instance.summarization,
      'moderation': instance.moderation,
      'named_entity_recognition': instance.namedEntityRecognition,
      'chapters': instance.chapters,
      'name_consistency': instance.nameConsistency,
      'custom_spelling': instance.customSpelling,
      'speaker_reidentification': instance.speakerReidentification,
      'structured_data_extraction': instance.structuredDataExtraction,
      'sentiment_analysis': instance.sentimentAnalysis,
      'audio_to_llm': instance.audioToLLM,
      'sentences': instance.sentences,
      'display_mode': instance.displayMode,
    };

TranscriptionData _$TranscriptionDataFromJson(Map<String, dynamic> json) =>
    TranscriptionData(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      fullTranscript: json['full_transcript'] as String,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sentences: (json['sentences'] as List<dynamic>?)
          ?.map((e) => SentenceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => SubtitleData.fromJson(e as Map<String, dynamic>))
          .toList(),
      utterances: (json['utterances'] as List<dynamic>?)
          ?.map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranscriptionDataToJson(TranscriptionData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'full_transcript': instance.fullTranscript,
      'languages': instance.languages,
      'sentences': instance.sentences,
      'subtitles': instance.subtitles,
      'utterances': instance.utterances,
    };

SentenceData _$SentenceDataFromJson(Map<String, dynamic> json) => SentenceData(
      success: json['success'] as bool?,
      isEmpty: json['isEmpty'] as bool?,
      execTime: (json['execTime'] as num?)?.toDouble(),
      error: json['error'] == null
          ? null
          : ErrorData.fromJson(json['error'] as Map<String, dynamic>),
      results:
          (json['results'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SentenceDataToJson(SentenceData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isEmpty': instance.isEmpty,
      'execTime': instance.execTime,
      'error': instance.error,
      'results': instance.results,
    };

SubtitleData _$SubtitleDataFromJson(Map<String, dynamic> json) => SubtitleData(
      format: json['format'] as String,
      subtitles: json['subtitles'] as String,
    );

Map<String, dynamic> _$SubtitleDataToJson(SubtitleData instance) =>
    <String, dynamic>{
      'format': instance.format,
      'subtitles': instance.subtitles,
    };

TranscriptionSegment _$TranscriptionSegmentFromJson(
        Map<String, dynamic> json) =>
    TranscriptionSegment(
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

Map<String, dynamic> _$TranscriptionSegmentToJson(
        TranscriptionSegment instance) =>
    <String, dynamic>{
      'text': instance.text,
      'start': instance.start,
      'end': instance.end,
      'speaker': instance.speaker,
      'confidence': instance.confidence,
      'language': instance.language,
      'channel': instance.channel,
      'words': instance.words,
    };

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      text: json['word'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'word': instance.text,
      'start': instance.start,
      'end': instance.end,
      'confidence': instance.confidence,
    };
