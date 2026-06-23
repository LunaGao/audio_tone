import 'dart:typed_data';

/// WAV file writer utility
/// Converts audio sample data (Float64List) to standard WAV format bytes
class WavWriter {
  WavWriter._();

  /// Encode audio samples to WAV format bytes
  ///
  /// [samples] Audio sample data, values range from -1.0 to 1.0
  /// [sampleRate] Sample rate in Hz (e.g. 44100)
  /// [numChannels] Number of audio channels, default 1 (mono)
  /// [bitsPerSample] Bits per sample, default 16
  ///
  /// Returns complete WAV file bytes (header + PCM data)
  static Uint8List encode({
    required Float64List samples,
    required int sampleRate,
    int numChannels = 1,
    int bitsPerSample = 16,
  }) {
    final bytesPerSample = bitsPerSample ~/ 8;
    final byteRate = sampleRate * numChannels * bytesPerSample;
    final blockAlign = numChannels * bytesPerSample;
    final dataSize = samples.length * numChannels * bytesPerSample;
    const headerSize = 44;
    final fileSize =
        headerSize +
        dataSize -
        8; // RIFF chunk size excludes "RIFF" and size field itself

    final buffer = Uint8List(headerSize + dataSize);
    final byteData = buffer.buffer.asByteData();

    // RIFF header
    _writeString(buffer, 0, 'RIFF');
    byteData.setUint32(4, fileSize, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    // fmt sub-chunk
    _writeString(buffer, 12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little); // Sub-chunk size (PCM = 16)
    byteData.setUint16(20, 1, Endian.little); // Audio format: 1 = PCM
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data sub-chunk
    _writeString(buffer, 36, 'data');
    byteData.setUint32(40, dataSize, Endian.little);

    // Write PCM sample data
    var offset = headerSize;
    for (var i = 0; i < samples.length; i++) {
      // Clamp sample to [-1.0, 1.0]
      final clamped = samples[i].clamp(-1.0, 1.0);
      // Convert to 16-bit signed integer
      final pcmValue = (clamped * 32767).round();
      byteData.setInt16(offset, pcmValue, Endian.little);
      offset += 2;
    }

    return buffer;
  }

  static void _writeString(Uint8List buffer, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      buffer[offset + i] = value.codeUnitAt(i);
    }
  }
}
