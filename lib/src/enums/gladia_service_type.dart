/// Gladia API service types
enum GladiaServiceType {
  /// Audio service (transcription)
  audio('audio'),

  /// Text service (NLP)
  text('text'),

  /// Video service
  video('video');

  /// String representation for API
  final String value;

  /// Constructor
  const GladiaServiceType(this.value);
}
