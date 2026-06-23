import 'dart:async';
import 'dart:io';

import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'demo_sections.dart';
import 'wav_writer.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final TextEditingController _morseController = TextEditingController(
    text: '.. .-.. .-.. ---  .-- --- .-. .-.. -..',
  );

  AudioSampleRate _sampleRate = AudioSampleRate.cdQuality;
  AudioFrequency _frequency = AudioFrequency.defaultFrequency;
  int _wpm = 18;
  final int _dashDuration = 3;
  final int _dotDashIntervalDuration = 1;
  final int _letterIntervalDuration = 3;
  final int _wordsIntervalDuration = 7;
  double _volume = 0.7;
  double _lightFactor = 5.0;

  late AudioTone _audioTone;
  StreamSubscription<dynamic>? _streamSubscription;

  bool _isHoldingTone = false;
  bool _isPlayingMorse = false;
  bool _isStreaming = false;
  bool _isGeneratingToneData = false;
  double? _lastDurationSeconds;
  String _status = 'Ready';
  final List<String> _events = <String>[];

  @override
  void initState() {
    super.initState();
    _audioTone = _createAudioTone();
    unawaited(_refreshDuration());
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    unawaited(_audioTone.stop());
    _morseController.dispose();
    super.dispose();
  }

  AudioTone _createAudioTone() {
    return AudioTone(
      sampleRate: _sampleRate,
      frequency: _frequency,
      wpm: _wpm,
      dashDuration: _dashDuration,
      dotDashIntervalDuration: _dotDashIntervalDuration,
      letterIntervalDuration: _letterIntervalDuration,
      wordsIntervalDuration: _wordsIntervalDuration,
      volume: _volume,
      lightFlashingMagnificationFactor: _lightFactor,
    );
  }

  String get _durationLabel => _lastDurationSeconds == null
      ? '--'
      : '${_lastDurationSeconds!.toStringAsFixed(2)} s';

  List<int> get _aTimings {
    final dotMs = (((60 / _wpm) / 50) * 1000).round();
    return <int>[
      dotMs,
      dotMs * _dotDashIntervalDuration,
      dotMs * _dashDuration,
    ];
  }

  String get _aTimingsLabel => _aTimings.join(', ');

  Future<void> _refreshDuration() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lastDurationSeconds = null;
      });
      return;
    }

    try {
      final duration = await _audioTone.getMorseCodePlayDuration(morse);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastDurationSeconds = duration;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Duration failed: $error';
      });
    }
  }

  void _rebuildAudioTone({bool recreate = false}) {
    if (recreate) {
      _audioTone = _createAudioTone();
    } else {
      _audioTone.setFrequency(_frequency);
      _audioTone.setSpeed(_wpm);
      _audioTone.setDashDuration(_dashDuration);
      _audioTone.setDotDashIntervalDuration(_dotDashIntervalDuration);
      _audioTone.setLetterIntervalDuration(_letterIntervalDuration);
      _audioTone.setWordsIntervalDuration(_wordsIntervalDuration);
      _audioTone.setVolume(_volume);
      _audioTone.setLightFlashingMagnificationFactor(_lightFactor);
    }
    unawaited(_refreshDuration());
  }

  void _pushEvent(String message) {
    final timestamp = TimeOfDay.now().format(context);
    setState(() {
      _events.insert(0, '$timestamp  $message');
      if (_events.length > 8) {
        _events.removeRange(8, _events.length);
      }
    });
  }

  Future<void> _playMorse() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      setState(() {
        _status = 'Enter Morse code first';
      });
      return;
    }

    await _streamSubscription?.cancel();
    setState(() {
      _isStreaming = false;
      _isPlayingMorse = true;
      _status = 'Playing Morse code...';
    });

    try {
      final duration = await _audioTone.getMorseCodePlayDuration(morse);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastDurationSeconds = duration;
      });

      await _audioTone.playMorseCode(morse);
      if (!mounted) {
        return;
      }
      _pushEvent('Morse playback started');
      setState(() {
        _status = 'Morse playback started';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Play failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingMorse = false;
        });
      }
    }
  }

  Future<void> _playStream() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      setState(() {
        _status = 'Enter Morse code first';
      });
      return;
    }

    await _streamSubscription?.cancel();

    setState(() {
      _isStreaming = true;
      _status = 'Streaming light/dark events...';
      _events.clear();
    });

    _streamSubscription = _audioTone.playStream(morse);
    _streamSubscription!
      ..onData((dynamic event) {
        if (!mounted) {
          return;
        }
        _pushEvent('Stream event: $event');
      })
      ..onDone(() {
        if (!mounted) {
          return;
        }
        setState(() {
          _isStreaming = false;
          _status = 'Stream finished';
        });
      })
      ..onError((Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isStreaming = false;
          _status = 'Stream failed: $error';
        });
      });
  }

  Future<void> _playTimings() async {
    final timings = _aTimings;
    await _streamSubscription?.cancel();
    setState(() {
      _isStreaming = false;
      _isPlayingMorse = true;
      _status = 'Playing timing sequence...';
    });

    try {
      final result = await _audioTone.playTimings(timings);
      if (!mounted) {
        return;
      }
      if (result != 0) {
        setState(() {
          _status = 'playTimings failed: $result';
        });
        return;
      }
      _pushEvent('Timing sequence started: [$timings]');
      setState(() {
        _status = 'Timing sequence started';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'playTimings failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingMorse = false;
        });
      }
    }
  }

  Future<void> _generateToneData() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      setState(() {
        _status = 'Enter Morse code first';
      });
      return;
    }

    setState(() {
      _isGeneratingToneData = true;
      _status = 'Generating tone data...';
    });

    try {
      final data = await _audioTone.generateToneSoundData(morse);
      if (!mounted) return;

      final sampleCount = data.length;
      final previewList = <String>[];
      final previewLen = sampleCount > 20 ? 20 : sampleCount;
      for (var i = 0; i < previewLen; i++) {
        previewList.add(data[i].toStringAsFixed(3));
      }
      final preview = previewList.join(', ');
      final suffix = sampleCount > 20 ? ', ...' : '';

      _pushEvent('Tone data: $sampleCount samples [$preview$suffix]');
      setState(() {
        _status = 'Generated $sampleCount samples';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Generate tone data failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingToneData = false;
        });
      }
    }
  }

  Future<void> _saveWav() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      setState(() {
        _status = 'Enter Morse code first';
      });
      return;
    }

    setState(() {
      _status = 'Generating and saving WAV file...';
    });

    try {
      final data = await _audioTone.generateToneSoundData(morse);
      if (!mounted) return;

      final wavBytes = WavWriter.encode(
        samples: data,
        sampleRate: _sampleRate.value,
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/morse_tone_$timestamp.wav');
      await file.writeAsBytes(wavBytes);

      if (!mounted) return;
      final sizeKb = (wavBytes.length / 1024).toStringAsFixed(1);
      _pushEvent(
        'WAV saved: ${file.path} ($sizeKb KB, ${data.length} samples)',
      );
      setState(() {
        _status = 'WAV saved to ${file.path}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Save WAV failed: $error';
      });
    }
  }

  Future<void> _shareWav() async {
    final morse = _morseController.text.trim();
    if (morse.isEmpty) {
      setState(() {
        _status = 'Enter Morse code first';
      });
      return;
    }

    setState(() {
      _status = 'Generating WAV for sharing...';
    });

    try {
      final data = await _audioTone.generateToneSoundData(morse);
      if (!mounted) return;

      final wavBytes = WavWriter.encode(
        samples: data,
        sampleRate: _sampleRate.value,
      );

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/morse_tone_share.wav');
      await file.writeAsBytes(wavBytes);

      if (!mounted) return;

      final sizeKb = (wavBytes.length / 1024).toStringAsFixed(1);
      final params = ShareParams(
        text: 'Morse Tone Audio',
        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        setState(() {
          _status = 'WAV shared successfully';
        });
        if (!mounted) return;
        _pushEvent('Shared WAV: $sizeKb KB, ${data.length} samples');
        setState(() {
          _status = 'WAV shared successfully';
        });
      } else {
        setState(() {
          _status = 'WAV shared failed';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Share WAV failed: $error';
      });
    }
  }

  Future<void> _stopAll() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _audioTone.stop();
    if (!mounted) {
      return;
    }
    setState(() {
      _isHoldingTone = false;
      _isPlayingMorse = false;
      _isStreaming = false;
      _isGeneratingToneData = false;
      _status = 'Stopped';
    });
  }

  Future<void> _startHoldTone() async {
    if (_isHoldingTone) {
      return;
    }

    setState(() {
      _isHoldingTone = true;
      _status = 'Holding tone...';
    });
    await _audioTone.play();
  }

  Future<void> _endHoldTone() async {
    if (!_isHoldingTone) {
      return;
    }

    await _audioTone.stop();
    if (!mounted) {
      return;
    }
    setState(() {
      _isHoldingTone = false;
      _status = 'Tone stopped';
    });
  }

  void _updateSampleRate(AudioSampleRate value) {
    setState(() {
      _sampleRate = value;
      _status = 'Sample rate updated';
    });
    _rebuildAudioTone(recreate: true);
  }

  void _updateFrequency(AudioFrequency value) {
    setState(() {
      _frequency = value;
      _status = 'Frequency updated';
    });
    _rebuildAudioTone();
  }

  void _updateWpm(double value) {
    setState(() {
      _wpm = value.round();
    });
    _rebuildAudioTone();
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
    });
    _rebuildAudioTone();
  }

  void _updateLightFactor(double value) {
    setState(() {
      _lightFactor = value;
    });
    _rebuildAudioTone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Tone Demo'), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DemoOverviewSection(
              status: _status,
              durationLabel: _durationLabel,
              sampleRateLabel: '${_sampleRate.value} Hz',
            ),
            const SizedBox(height: 16),
            DemoMorseInputSection(
              controller: _morseController,
              isPlayingMorse: _isPlayingMorse,
              isStreaming: _isStreaming,
              onChanged: _refreshDuration,
              onPlayMorse: _playMorse,
              onPlayStream: _playStream,
              onGenerateToneData: _generateToneData,
              onSaveWav: _saveWav,
              onShareWav: _shareWav,
            ),
            const SizedBox(height: 16),
            DemoLiveControlsSection(
              sampleRate: _sampleRate,
              frequency: _frequency,
              wpm: _wpm,
              volume: _volume,
              lightFactor: _lightFactor,
              onSampleRateChanged: _updateSampleRate,
              onFrequencyChanged: _updateFrequency,
              onWpmChanged: _updateWpm,
              onVolumeChanged: _updateVolume,
              onLightFactorChanged: _updateLightFactor,
            ),
            const SizedBox(height: 16),
            DemoTimingsSection(
              timingsLabel: _aTimingsLabel,
              onPlayTimings: _playTimings,
            ),
            const SizedBox(height: 16),
            DemoHoldToneSection(
              isHoldingTone: _isHoldingTone,
              onStartHoldTone: _startHoldTone,
              onEndHoldTone: _endHoldTone,
              onStopAll: _stopAll,
            ),
            const SizedBox(height: 16),
            DemoStreamEventsSection(events: _events),
          ],
        ),
      ),
    );
  }
}
