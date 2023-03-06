import 'package:finalmicrophone/screens/resultPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/auth_page.dart';
import 'provider/record_audio_provider.dart';
import 'provider/play_audio_provider.dart';
import 'screens/record_and_play_audio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EntryRoot());
}

class EntryRoot extends StatelessWidget {
  const EntryRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordAudioProvider(context)),
        ChangeNotifierProvider(create: (_) => PlayAudioProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Record And Play',
          initialRoute: '/',
          routes: {

            '/recordScreen': (context) => RecordAndPlayScreen(),
            '/resultsPage': (context) => ShazamResultPage(
                  name_and_artist:
                      Provider.of<RecordAudioProvider>(context).song['name'],
                  url: Provider.of<RecordAudioProvider>(context).song['url'],
                  channel_url: Provider.of<RecordAudioProvider>(context)
                      .song['channel_url'],
                  image_url: Provider.of<RecordAudioProvider>(context)
                      .song['image_url'],
                ),
          },
          home: AuthPage()),
    );
  }
}
