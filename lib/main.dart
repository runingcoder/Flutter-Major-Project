import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/record_audio_provider.dart';
import 'provider/play_audio_provider.dart';
import 'screens/record_and_play_audio.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const EntryRoot());
}

class EntryRoot extends StatelessWidget {
  const EntryRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordAudioProvider()),
        ChangeNotifierProvider(create: (_) => PlayAudioProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Record And Play',
        home: RecordAndPlayScreen(),
      ),
    );
  }
}
