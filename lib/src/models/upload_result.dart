import 'package:meta/meta.dart';

/// Result of uploading audio file to Gladia API
@immutable
class UploadResult {
  /// URL of the uploaded audio file
  final String audioUrl;

  /// Audio file metadata
  final AudioMetadata? audioMetadata;

  /// Creates a new instance of [UploadResult]
  const UploadResult({
    required this.audioUrl,
    this.audioMetadata,
  });

  /// Creates [UploadResult] from JSON data
  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      audioUrl: json['audio_url'] as String,
      audioMetadata: json['audio_metadata'] != null
          ? AudioMetadata.fromJson(
              json['audio_metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
        'audio_url': audioUrl,
        if (audioMetadata != null) 'audio_metadata': audioMetadata!.toJson(),
      };
}

/// Audio file metadata
@immutable
class AudioMetadata {
  /// File identifier
  final String id;

  /// File name
  final String? filename;

  /// File extension
  final String? extension;

  /// File size in bytes
  final int? size;

  /// Audio duration in seconds
  final double? audioDuration;

  /// Number of audio channels
  final int? numberOfChannels;

  /// Creates a new instance of [AudioMetadata]
  const AudioMetadata({
    required this.id,
    this.filename,
    this.extension,
    this.size,
    this.audioDuration,
    this.numberOfChannels,
  });

  /// Creates [AudioMetadata] from JSON data
  factory AudioMetadata.fromJson(Map<String, dynamic> json) {
    return AudioMetadata(
      id: json['id'] as String,
      filename: json['filename'] as String?,
      extension: json['extension'] as String?,
      size: json['size'] as int?,
      audioDuration: json['audio_duration'] as double?,
      numberOfChannels:
          json['number_of_channels'] as int? ?? json['nb_channels'] as int?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        if (filename != null) 'filename': filename,
        if (extension != null) 'extension': extension,
        if (size != null) 'size': size,
        if (audioDuration != null) 'audio_duration': audioDuration,
        if (numberOfChannels != null) 'number_of_channels': numberOfChannels,
      };
}
