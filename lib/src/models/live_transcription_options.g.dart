// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_transcription_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveTranscriptionOptions _$LiveTranscriptionOptionsFromJson(
        Map<String, dynamic> json) =>
    LiveTranscriptionOptions(
      encoding: LiveTranscriptionOptions._encodingFromJson(json['encoding']),
      bitDepth: LiveTranscriptionOptions._bitDepthFromJson(json['bit_depth']),
      sampleRate:
          LiveTranscriptionOptions._sampleRateFromJson(json['sample_rate']),
      channels: (json['channels'] as num?)?.toInt(),
      customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
      model: json['model'] as String?,
      endpointing: (json['endpointing'] as num?)?.toDouble(),
      maximumDurationWithoutEndpointing:
          (json['maximum_duration_without_endpointing'] as num?)?.toDouble(),
      languageConfig: LiveTranscriptionOptions._languageConfigFromJson(
          json['languageConfig'] as Map<String, dynamic>?),
      preProcessing: LiveTranscriptionOptions._preProcessingFromJson(
          json['pre_processing'] as Map<String, dynamic>?),
      realtimeProcessing: LiveTranscriptionOptions._realtimeProcessingFromJson(
          json['realtime_processing'] as Map<String, dynamic>?),
      postProcessing: LiveTranscriptionOptions._postProcessingFromJson(
          json['post_processing'] as Map<String, dynamic>?),
      messagesConfig: LiveTranscriptionOptions._messagesConfigFromJson(
          json['messages_config'] as Map<String, dynamic>?),
      callback: json['callback'] as bool?,
      callbackConfig: LiveTranscriptionOptions._callbackConfigFromJson(
          json['callback_config'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$LiveTranscriptionOptionsToJson(
        LiveTranscriptionOptions instance) =>
    <String, dynamic>{
      'encoding': LiveTranscriptionOptions._encodingToJson(instance.encoding),
      'bit_depth': LiveTranscriptionOptions._bitDepthToJson(instance.bitDepth),
      'sample_rate':
          LiveTranscriptionOptions._sampleRateToJson(instance.sampleRate),
      'channels': instance.channels,
      'custom_metadata': instance.customMetadata,
      'model': instance.model,
      'endpointing': instance.endpointing,
      'maximum_duration_without_endpointing':
          instance.maximumDurationWithoutEndpointing,
      'languageConfig': LiveTranscriptionOptions._languageConfigToJson(
          instance.languageConfig),
      'pre_processing':
          LiveTranscriptionOptions._preProcessingToJson(instance.preProcessing),
      'realtime_processing': LiveTranscriptionOptions._realtimeProcessingToJson(
          instance.realtimeProcessing),
      'post_processing': LiveTranscriptionOptions._postProcessingToJson(
          instance.postProcessing),
      'messages_config': LiveTranscriptionOptions._messagesConfigToJson(
          instance.messagesConfig),
      'callback': instance.callback,
      'callback_config': LiveTranscriptionOptions._callbackConfigToJson(
          instance.callbackConfig),
    };
