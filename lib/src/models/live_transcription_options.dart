import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../enums/enums.dart';
import 'language_config.dart';
import 'pre_processing.dart';
import 'realtime_processing.dart';
import 'post_processing.dart';
import 'messages_config.dart';
import 'callback_config.dart';

part 'live_transcription_options.g.dart';

/// Options for the transcription process
@immutable
@JsonSerializable()
class LiveTranscriptionOptions {
  ///The encoding format of the audio stream
  @JsonKey(
      name: 'encoding', fromJson: _encodingFromJson, toJson: _encodingToJson)
  final Encoding? encoding;

  /// The bit depth of the audio stream
  @JsonKey(
      name: 'bit_depth', fromJson: _bitDepthFromJson, toJson: _bitDepthToJson)
  final BitDepth? bitDepth;

  /// The sample rate of the audio stream
  @JsonKey(
      name: 'sample_rate',
      fromJson: _sampleRateFromJson,
      toJson: _sampleRateToJson)
  final SampleRate? sampleRate;

  /// The number of channels of the audio stream
  /// Required range: 1 <= x <= 8
  @JsonKey(name: 'channels')
  final int? channels;

  /// Custom metadata you can attach to this live transcription
  /// Example: { "user": "John Doe" }
  @JsonKey(name: 'custom_metadata')
  final Map<String, dynamic>? customMetadata;

  /// The model used to process the audio. "solaria-1" is used by default.
  /// Available options:
  /// - "solaria-1" // default
  @JsonKey(name: 'model')
  final String? model;

  /// The endpointing duration in seconds. Endpointing is the duration of silence which will cause an utterance to be considered as finished
  /// Required range: 0.01 <= x <= 10
  /// Default: 0.05
  @JsonKey(name: 'endpointing')
  final double? endpointing;

  /// The maximum duration in seconds without endpointing. If endpointing is not detected after this duration, current utterance will be considered as finished
  /// Required range: 5 <= x <= 60
  /// Default: 5
  @JsonKey(name: 'maximum_duration_without_endpointing')
  final double? maximumDurationWithoutEndpointing;

  /// Конфигурация языка
  @JsonKey(fromJson: _languageConfigFromJson, toJson: _languageConfigToJson)
  final LanguageConfig? languageConfig;

  /// Конфигурация предварительной обработки
  @JsonKey(
      name: 'pre_processing',
      fromJson: _preProcessingFromJson,
      toJson: _preProcessingToJson)
  final PreProcessing? preProcessing;

  /// Конфигурация обработки в реальном времени
  @JsonKey(
      name: 'realtime_processing',
      fromJson: _realtimeProcessingFromJson,
      toJson: _realtimeProcessingToJson)
  final RealtimeProcessing? realtimeProcessing;

  /// Specify the post-processing configuration
  @JsonKey(
      name: 'post_processing',
      fromJson: _postProcessingFromJson,
      toJson: _postProcessingToJson)
  final PostProcessing? postProcessing;

  /// Specify the websocket messages configuration
  @JsonKey(
      name: 'messages_config',
      fromJson: _messagesConfigFromJson,
      toJson: _messagesConfigToJson)
  final MessagesConfig? messagesConfig;

  /// If true, messages will be sent to configured url.
  /// Default: false
  @JsonKey(name: 'callback')
  final bool? callback;

  /// Specify the callback configuration
  @JsonKey(
      name: 'callback_config',
      fromJson: _callbackConfigFromJson,
      toJson: _callbackConfigToJson)
  final CallbackConfig? callbackConfig;

  /// Creates a new instance of [LiveTranscriptionOptions]
  const LiveTranscriptionOptions({
    this.encoding,
    this.bitDepth,
    this.sampleRate,
    this.channels,
    this.customMetadata,
    this.model,
    this.endpointing,
    this.maximumDurationWithoutEndpointing,
    this.languageConfig,
    this.preProcessing,
    this.realtimeProcessing,
    this.postProcessing,
    this.messagesConfig,
    this.callback,
    this.callbackConfig,
  });

  factory LiveTranscriptionOptions.fromJson(Map<String, dynamic> json) =>
      _$LiveTranscriptionOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$LiveTranscriptionOptionsToJson(this);

  /// Converts encoding from API value to Encoding enum
  static Encoding? _encodingFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return EncodingExtension.fromApiValue(value);
    }
    return null;
  }

  /// Converts Encoding enum to API value
  static String? _encodingToJson(Encoding? encoding) {
    if (encoding == null) return null;
    return encoding.toApiValue();
  }

  /// Converts bit depth from API value to BitDepth enum
  static BitDepth? _bitDepthFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return BitDepth.fromValue(value);
    }
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return BitDepth.fromValue(intValue);
      }
    }
    return null;
  }

  /// Converts BitDepth enum to API value
  static int? _bitDepthToJson(BitDepth? bitDepth) {
    if (bitDepth == null) return null;
    return bitDepth.value;
  }

  /// Converts sample rate from API value to SampleRate enum
  static SampleRate? _sampleRateFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return SampleRate.fromValue(value);
    }
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return SampleRate.fromValue(intValue);
      }
    }
    return null;
  }

  /// Converts SampleRate enum to API value
  static int? _sampleRateToJson(SampleRate? sampleRate) {
    if (sampleRate == null) return null;
    return sampleRate.value;
  }

  /// Converts LanguageConfig from JSON
  static LanguageConfig? _languageConfigFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return LanguageConfig.fromJson(json);
  }

  /// Converts LanguageConfig to JSON
  static Map<String, dynamic>? _languageConfigToJson(LanguageConfig? config) {
    if (config == null) return null;
    return config.toJson();
  }

  /// Converts PreProcessing from JSON
  static PreProcessing? _preProcessingFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PreProcessing.fromJson(json);
  }

  /// Converts PreProcessing to JSON
  static Map<String, dynamic>? _preProcessingToJson(PreProcessing? config) {
    if (config == null) return null;
    return config.toJson();
  }

  /// Converts RealtimeProcessing from JSON
  static RealtimeProcessing? _realtimeProcessingFromJson(
      Map<String, dynamic>? json) {
    if (json == null) return null;
    return RealtimeProcessing.fromJson(json);
  }

  /// Converts RealtimeProcessing to JSON
  static Map<String, dynamic>? _realtimeProcessingToJson(
      RealtimeProcessing? config) {
    if (config == null) return null;
    return config.toJson();
  }

  /// Converts PostProcessing from JSON
  static PostProcessing? _postProcessingFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PostProcessing.fromJson(json);
  }

  /// Converts PostProcessing to JSON
  static Map<String, dynamic>? _postProcessingToJson(PostProcessing? config) {
    if (config == null) return null;
    return config.toJson();
  }

  /// Converts MessagesConfig from JSON
  static MessagesConfig? _messagesConfigFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return MessagesConfig.fromJson(json);
  }

  /// Converts MessagesConfig to JSON
  static Map<String, dynamic>? _messagesConfigToJson(MessagesConfig? config) {
    if (config == null) return null;
    return config.toJson();
  }

  /// Converts CallbackConfig from JSON
  static CallbackConfig? _callbackConfigFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return CallbackConfig.fromJson(json);
  }

  /// Converts CallbackConfig to JSON
  static Map<String, dynamic>? _callbackConfigToJson(CallbackConfig? config) {
    if (config == null) return null;
    return config.toJson();
  }
}
