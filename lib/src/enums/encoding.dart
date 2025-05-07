/// Enumeration of available audio encoding formats
enum Encoding {
  /// PCM format (default)
  pcm,

  /// μ-law format (8 bit)
  ulaw,

  /// A-law format (8 bit)
  alaw,
}

/// Extension for Encoding with conversion methods
extension EncodingExtension on Encoding {
  /// Converts enum to string value for API
  String toApiValue() {
    switch (this) {
      case Encoding.pcm:
        return 'wav/pcm';
      case Encoding.ulaw:
        return 'wav/ulaw';
      case Encoding.alaw:
        return 'wav/alaw';
    }
  }

  /// Creates Encoding from string value
  static Encoding? fromApiValue(String? value) {
    if (value == null) return null;

    switch (value) {
      case 'wav/pcm':
        return Encoding.pcm;
      case 'wav/ulaw':
        return Encoding.ulaw;
      case 'wav/alaw':
        return Encoding.alaw;
      default:
        return null;
    }
  }
}
