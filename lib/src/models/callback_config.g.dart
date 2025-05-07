// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'callback_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallbackConfig _$CallbackConfigFromJson(Map<String, dynamic> json) =>
    CallbackConfig(
      url: json['url'] as String?,
      receiveFinalTranscripts: json['receive_final_transcripts'] as bool?,
      receiveSpeechEvents: json['receive_speech_events'] as bool?,
      receivePreProcessingEvents:
          json['receive_pre_processing_events'] as bool?,
      receiveRealtimeProcessingEvents:
          json['receive_realtime_processing_events'] as bool?,
      receivePostProcessingEvents:
          json['receive_post_processing_events'] as bool?,
      receiveAcknowledgments: json['receive_acknowledgments'] as bool?,
      receiveErrors: json['receive_errors'] as bool?,
      receiveLifecycleEvents: json['receive_lifecycle_events'] as bool?,
    );

Map<String, dynamic> _$CallbackConfigToJson(CallbackConfig instance) =>
    <String, dynamic>{
      'url': instance.url,
      'receive_final_transcripts': instance.receiveFinalTranscripts,
      'receive_speech_events': instance.receiveSpeechEvents,
      'receive_pre_processing_events': instance.receivePreProcessingEvents,
      'receive_realtime_processing_events':
          instance.receiveRealtimeProcessingEvents,
      'receive_post_processing_events': instance.receivePostProcessingEvents,
      'receive_acknowledgments': instance.receiveAcknowledgments,
      'receive_errors': instance.receiveErrors,
      'receive_lifecycle_events': instance.receiveLifecycleEvents,
    };
