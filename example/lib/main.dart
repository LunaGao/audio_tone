import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:audio_tone/audio_tone.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var audioTone = AudioTone(wpm: 5, dashDuration: 6);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Init Tone Player'),
              onTap: () async {
                audioTone.playMorseCode(".-.-  .-.- .");
              },
            ),
            InkWell(
              child: ListTile(title: const Text('Tap to Play')),
              onTapDown: (details) {
                log("S ${DateTime.now()}");
                audioTone.play();
              },
              onTapUp: (details) {
                log("E ${DateTime.now()}");
                audioTone.stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
