import 'dart:async';

import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Tone Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E6B5C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Tone Demo'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Morse + tone playground',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tune the signal, calculate the duration, stream light/dark events, or hold a pure tone.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        label: 'Status',
                        value: _status,
                      ),
                      _InfoChip(
                        label: 'Duration',
                        value: _lastDurationSeconds == null
                            ? '--'
                            : '${_lastDurationSeconds!.toStringAsFixed(2)} s',
                      ),
                      _InfoChip(
                        label: 'Sample Rate',
                        value: '${_sampleRate.value} Hz',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Morse Input',
              subtitle: 'Use ".", "-", single-space for letter gaps, and double-space for word gaps.',
              child: Column(
                children: [
                  TextField(
                    controller: _morseController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '.. .-.. .-.. ---  .-- --- .-. .-.. -..',
                    ),
                    onChanged: (_) {
                      unawaited(_refreshDuration());
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _isStreaming ? null : _playMorse,
                          child: const Text('Play Morse'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isPlayingMorse ? null : _playStream,
                          child: const Text('Stream Events'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Live Controls',
              subtitle: 'All controls below update the current plugin instance immediately.',
              child: Column(
                children: [
                  DropdownButtonFormField<AudioSampleRate>(
                    initialValue: _sampleRate,
                    decoration: const InputDecoration(
                      labelText: 'Sample Rate',
                      border: OutlineInputBorder(),
                    ),
                    items: AudioSampleRate.values
                        .map(
                          (rate) => DropdownMenuItem<AudioSampleRate>(
                            value: rate,
                            child: Text('${rate.name} (${rate.value} Hz)'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _sampleRate = value;
                        _status = 'Sample rate updated';
                      });
                      _rebuildAudioTone(recreate: true);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AudioFrequency>(
                    initialValue: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Tone Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: AudioFrequency.values
                        .map(
                          (frequency) => DropdownMenuItem<AudioFrequency>(
                            value: frequency,
                            child: Text('${frequency.name} (${frequency.value} Hz)'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _frequency = value;
                        _status = 'Frequency updated';
                      });
                      _rebuildAudioTone();
                    },
                  ),
                  const SizedBox(height: 16),
                  _SliderRow(
                    label: 'WPM',
                    valueLabel: '$_wpm',
                    value: _wpm.toDouble(),
                    min: 5,
                    max: 40,
                    divisions: 35,
                    onChanged: (value) {
                      setState(() {
                        _wpm = value.round();
                      });
                      _rebuildAudioTone();
                    },
                  ),
                  _SliderRow(
                    label: 'Volume',
                    valueLabel: _volume.toStringAsFixed(2),
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                      _rebuildAudioTone();
                    },
                  ),
                  _SliderRow(
                    label: 'Light Factor',
                    valueLabel: _lightFactor.toStringAsFixed(1),
                    value: _lightFactor,
                    min: 1.0,
                    max: 15.0,
                    divisions: 28,
                    onChanged: (value) {
                      setState(() {
                        _lightFactor = value;
                      });
                      _rebuildAudioTone();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Press And Hold Tone',
              subtitle: 'Use this area to test the continuous tone path with the current frequency and volume.',
              child: Column(
                children: [
                  GestureDetector(
                    onTapDown: (_) => unawaited(_startHoldTone()),
                    onTapUp: (_) => unawaited(_endHoldTone()),
                    onTapCancel: () => unawaited(_endHoldTone()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: _isHoldingTone
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isHoldingTone ? 'Release To Stop' : 'Press And Hold To Play Tone',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _isHoldingTone
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _stopAll,
                      child: const Text('Stop Everything'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Recent Stream Events',
              subtitle: 'Useful for checking light/dark cadence from playStream().',
              child: _events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No events yet'),
                    )
                  : Column(
                      children: _events
                          .map(
                            (event) => Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(event),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5F4EE), Color(0xFFF5EEDC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
