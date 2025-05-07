import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'messages_config.g.dart';

@immutable
@JsonSerializable()

/// Specify the websocket messages configuration
class MessagesConfig {
  /// If true, final utterance will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_final_transcripts')
  final bool? receiveFinalTranscripts;

  /// If true, begin and end speech events will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_speech_events')
  final bool? receiveSpeechEvents;

  /// If true, pre-processing events will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_pre_processing_events')
  final bool? receivePreProcessingEvents;

  /// If true, realtime processing events will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_realtime_processing_events')
  final bool? receiveRealtimeProcessingEvents;

  /// If true, post-processing events will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_post_processing_events')
  final bool? receivePostProcessingEvents;

  /// If true, acknowledgments will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_acknowledgments')
  final bool? receiveAcknowledgments;

  /// If true, errors will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_errors')
  final bool? receiveErrors;

  /// If true, lifecycle events will be sent to websocket.
  /// Default: true
  @JsonKey(name: 'receive_lifecycle_events')
  final bool? receiveLifecycleEvents;

  const MessagesConfig({
    this.receiveFinalTranscripts,
    this.receiveSpeechEvents,
    this.receivePreProcessingEvents,
    this.receiveRealtimeProcessingEvents,
    this.receivePostProcessingEvents,
    this.receiveAcknowledgments,
    this.receiveErrors,
    this.receiveLifecycleEvents,
  });

  factory MessagesConfig.fromJson(Map<String, dynamic> json) =>
      _$MessagesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MessagesConfigToJson(this);
}
