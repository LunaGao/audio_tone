import 'dart:async';

import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:flutter/material.dart';

import 'demo_widgets.dart';

class DemoOverviewSection extends StatelessWidget {
  const DemoOverviewSection({
    required this.status,
    required this.durationLabel,
    required this.sampleRateLabel,
    super.key,
  });

  final String status;
  final String durationLabel;
  final String sampleRateLabel;

  @override
  Widget build(BuildContext context) {
    return DemoHeroCard(
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
              DemoInfoChip(label: 'Status', value: status),
              DemoInfoChip(label: 'Duration', value: durationLabel),
              DemoInfoChip(label: 'Sample Rate', value: sampleRateLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class DemoMorseInputSection extends StatelessWidget {
  const DemoMorseInputSection({
    required this.controller,
    required this.isPlayingMorse,
    required this.isStreaming,
    required this.onChanged,
    required this.onPlayMorse,
    required this.onPlayStream,
    required this.onGenerateToneData,
    super.key,
  });

  final TextEditingController controller;
  final bool isPlayingMorse;
  final bool isStreaming;
  final Future<void> Function() onChanged;
  final Future<void> Function() onPlayMorse;
  final Future<void> Function() onPlayStream;
  final Future<void> Function() onGenerateToneData;

  @override
  Widget build(BuildContext context) {
    return DemoSectionCard(
      title: 'Morse Input',
      subtitle:
          'Use ".", "-", single-space for letter gaps, and double-space for word gaps.',
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '.. .-.. .-.. ---  .-- --- .-. .-.. -..',
            ),
            onChanged: (_) {
              unawaited(onChanged());
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isStreaming ? null : onPlayMorse,
                  child: const Text('Play Morse'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: isPlayingMorse ? null : onPlayStream,
                  child: const Text('Stream Events'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isPlayingMorse || isStreaming
                  ? null
                  : onGenerateToneData,
              icon: const Icon(Icons.graphic_eq),
              label: const Text('Generate Tone Data'),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoLiveControlsSection extends StatelessWidget {
  const DemoLiveControlsSection({
    required this.sampleRate,
    required this.frequency,
    required this.wpm,
    required this.volume,
    required this.lightFactor,
    required this.onSampleRateChanged,
    required this.onFrequencyChanged,
    required this.onWpmChanged,
    required this.onVolumeChanged,
    required this.onLightFactorChanged,
    super.key,
  });

  final AudioSampleRate sampleRate;
  final AudioFrequency frequency;
  final int wpm;
  final double volume;
  final double lightFactor;
  final ValueChanged<AudioSampleRate> onSampleRateChanged;
  final ValueChanged<AudioFrequency> onFrequencyChanged;
  final ValueChanged<double> onWpmChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onLightFactorChanged;

  @override
  Widget build(BuildContext context) {
    return DemoSectionCard(
      title: 'Live Controls',
      subtitle:
          'All controls below update the current plugin instance immediately.',
      child: Column(
        children: [
          DropdownButtonFormField<AudioSampleRate>(
            initialValue: sampleRate,
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
              if (value != null) {
                onSampleRateChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AudioFrequency>(
            initialValue: frequency,
            decoration: const InputDecoration(
              labelText: 'Tone Frequency',
              border: OutlineInputBorder(),
            ),
            items: AudioFrequency.values
                .map(
                  (item) => DropdownMenuItem<AudioFrequency>(
                    value: item,
                    child: Text('${item.name} (${item.value} Hz)'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onFrequencyChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          DemoSliderRow(
            label: 'WPM',
            valueLabel: '$wpm',
            value: wpm.toDouble(),
            min: 5,
            max: 40,
            divisions: 35,
            onChanged: onWpmChanged,
          ),
          DemoSliderRow(
            label: 'Volume',
            valueLabel: volume.toStringAsFixed(2),
            value: volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: onVolumeChanged,
          ),
          DemoSliderRow(
            label: 'Light Factor',
            valueLabel: lightFactor.toStringAsFixed(1),
            value: lightFactor,
            min: 1.0,
            max: 15.0,
            divisions: 28,
            onChanged: onLightFactorChanged,
          ),
        ],
      ),
    );
  }
}

class DemoTimingsSection extends StatelessWidget {
  const DemoTimingsSection({
    required this.timingsLabel,
    required this.onPlayTimings,
    super.key,
  });

  final String timingsLabel;
  final Future<void> Function() onPlayTimings;

  @override
  Widget build(BuildContext context) {
    return DemoSectionCard(
      title: 'Timing Sequence',
      subtitle:
          'Play a raw tone/silence timing list without Morse parsing. This demo maps the current controls to the pattern for "A" (.-).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current timings: [$timingsLabel] ms'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPlayTimings,
              child: const Text('Play Timings'),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoHoldToneSection extends StatelessWidget {
  const DemoHoldToneSection({
    required this.isHoldingTone,
    required this.onStartHoldTone,
    required this.onEndHoldTone,
    required this.onStopAll,
    super.key,
  });

  final bool isHoldingTone;
  final Future<void> Function() onStartHoldTone;
  final Future<void> Function() onEndHoldTone;
  final Future<void> Function() onStopAll;

  @override
  Widget build(BuildContext context) {
    return DemoSectionCard(
      title: 'Press And Hold Tone',
      subtitle:
          'Use this area to test the continuous tone path with the current frequency and volume.',
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (_) => unawaited(onStartHoldTone()),
            onTapUp: (_) => unawaited(onEndHoldTone()),
            onTapCancel: () => unawaited(onEndHoldTone()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: isHoldingTone
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isHoldingTone
                    ? 'Release To Stop'
                    : 'Press And Hold To Play Tone',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isHoldingTone
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
              onPressed: onStopAll,
              child: const Text('Stop Everything'),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoStreamEventsSection extends StatelessWidget {
  const DemoStreamEventsSection({required this.events, super.key});

  final List<String> events;

  @override
  Widget build(BuildContext context) {
    return DemoSectionCard(
      title: 'Recent Stream Events',
      subtitle: 'Useful for checking light/dark cadence from playStream().',
      child: events.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No events yet'),
            )
          : Column(
              children: events
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
    );
  }
}
