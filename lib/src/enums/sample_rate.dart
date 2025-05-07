/// Enumeration of available audio sampling rate values
enum SampleRate {
  /// 8000 Hz
  hz8000(8000),

  /// 16000 Hz (default)
  hz16000(16000),

  /// 32000 Hz
  hz32000(32000),

  /// 44100 Hz
  hz44100(44100),

  /// 48000 Hz
  hz48000(48000);

  /// Sampling rate value in Hz
  final int value;

  /// Constructor
  const SampleRate(this.value);

  /// Creates SampleRate from integer value
  static SampleRate? fromValue(int? value) {
    if (value == null) return null;

    switch (value) {
      case 8000:
        return SampleRate.hz8000;
      case 16000:
        return SampleRate.hz16000;
      case 32000:
        return SampleRate.hz32000;
      case 44100:
        return SampleRate.hz44100;
      case 48000:
        return SampleRate.hz48000;
      default:
        return null;
    }
  }
}
