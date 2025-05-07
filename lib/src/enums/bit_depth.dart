/// Enumeration of available audio bit depth values
enum BitDepth {
  /// 8 bits
  bits8(8),

  /// 16 bits (default)
  bits16(16),

  /// 24 bits
  bits24(24),

  /// 32 bits
  bits32(32);

  /// Bit depth value
  final int value;

  /// Constructor
  const BitDepth(this.value);

  /// Creates BitDepth from integer value
  static BitDepth? fromValue(int? value) {
    if (value == null) return null;

    switch (value) {
      case 8:
        return BitDepth.bits8;
      case 16:
        return BitDepth.bits16;
      case 24:
        return BitDepth.bits24;
      case 32:
        return BitDepth.bits32;
      default:
        return null;
    }
  }
}
