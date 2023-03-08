import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../provider/play_audio_provider.dart';
import '../provider/record_audio_provider.dart';
import 'package:just_audio/just_audio.dart';

class RecordAndPlayScreen extends StatefulWidget {
  const RecordAndPlayScreen({Key? key}) : super(key: key);

  @override
  State<RecordAndPlayScreen> createState() => _RecordAndPlayScreenState();
}

class _RecordAndPlayScreenState extends State<RecordAndPlayScreen> {


  final user = FirebaseAuth.instance.currentUser!;

// the problem was that the fontsize was big for my email to show.and shouldn't have messed with displayName cs
//  new users don't seem to have displayName and even if I tried creating/involving that in the register
//  function, it seems to be deprecated or smthg. Just use email for now.
  //next is to, see, navigation bar, and making a db named history and associating,
  //users with the searched songs. and adding, upload song functionality to send to server.

  late double _height;


  @override
  Widget build(BuildContext context) {
    bool isReceived = Provider.of<RecordAudioProvider>(context).received;
    bool connectionFail =
        Provider.of<RecordAudioProvider>(context).connectionfail;

    final _recordProvider = Provider.of<RecordAudioProvider>(context);
    final _playProvider = Provider.of<PlayAudioProvider>(context);

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))
          ],
          title: Text('Hello ' + user.email! + ' !',
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80'))),
            child: SingleChildScrollView(
              child: Column(
                //this doesn't matter if SIngelChildScrollView is used.
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  if (!_recordProvider.recordedFilePath.isNotEmpty && !_recordProvider.isRecording)
                    _recordHeading('Upload Audio'),
                  const SizedBox(
                    height: 40,
                  ),
                  if (!_recordProvider.recordedFilePath.isNotEmpty && !_recordProvider.isRecording)
                    _uploadSection(),
                  const SizedBox(
                    height: 60,
                  ),
                  if (!_recordProvider.recordedFilePath.isNotEmpty)
                    _recordHeading('Record Audio'),
                  const SizedBox(
                    height: 40,
                  ),
                  if (!_recordProvider.recordedFilePath.isNotEmpty)
                    _recordingSection(),
                  if (connectionFail)
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Could not send request',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 80),
                          GestureDetector(
                            onTap: () {
                              Provider.of<RecordAudioProvider>(context,
                                      listen: false)
                                  .clearOldData();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Go back',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  InkWell(
                    onTap: () {
                      print(_recordProvider.song);
                      Navigator.of(context).pushNamed('/resultsPage');
                    },
                    child: isReceived
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "See Result!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  if (_recordProvider.recordedFilePath.isNotEmpty &&
                      !_playProvider.isSongPlaying)
                    const SizedBox(height: 40),

                  if (_recordProvider.recordedFilePath.isNotEmpty &&
                      !_playProvider.isSongPlaying &&
                      isReceived)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _resetButton(),
                        const SizedBox(
                          height: 40,
                        ),
                        Text(
                            'Response Time: ${_recordProvider.responseTime.inSeconds.toString()} seconds'),
                      ],
                    ),

                  const SizedBox(
                    height: 40,
                  ),
                  (_recordProvider.recordedFilePath.isNotEmpty &&
                          !isReceived &&
                          !connectionFail)
                      ? CircularProgressIndicator()
                      : Text(''),
                  // _resetButton(),
                  // _loadingPage(),
                ],
              ),
            )));
  }
_uploadSection() {
  final _recordProvider = Provider.of<RecordAudioProvider>(context);
  final _recordProviderWithoutListener =
  Provider.of<RecordAudioProvider>(context, listen: false);
  return InkWell(
    onTap: () async => await _recordProviderWithoutListener.uploadVoice(),
    child: _commonIconSection(Icons.upload, Colors.brown ),
  );
}
  _recordHeading( String messageTime) {
    return  Center(
      child: Text(
        messageTime,
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }


  signUserOut() {
    Provider.of<RecordAudioProvider>(context,listen:false).clearOldData();
    FirebaseAuth.instance.signOut();
  }


  _recordingSection() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);
    final _recordProviderWithoutListener =
        Provider.of<RecordAudioProvider>(context, listen: false);
    if (_recordProvider.isRecording) {
      return InkWell(
        onTap: () async => await _recordProviderWithoutListener.stopRecording(),
        child: RippleAnimation(
          repeat: true,
          minRadius: 40,
          ripplesCount: 6,
          color: Colors.tealAccent,
          child: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(108),
              ),
              child: const Icon(
                Icons.keyboard_voice_rounded,
                color: Colors.white,
                size: 30,
              )),
        ),
      );
    }
    return InkWell(
      onTap: () async => await _recordProviderWithoutListener.recordVoice(),
      child: _commonIconSection(Icons.keyboard_voice_sharp, Colors.green),
    );
  }

  _commonIconSection(IconData iconData, Color color) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child:  Icon(iconData,
          color: Colors.white, size: 30),
    );
  }

  _audioPlayingSection() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return Container(
      width: MediaQuery.of(context).size.width - 110,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          _audioControllingSection(_recordProvider.recordedFilePath),
          _audioProgressSection(),
        ],
      ),
    );
  }

  _audioControllingSection(String songPath) {
    final _playProvider = Provider.of<PlayAudioProvider>(context);
    final _playProviderWithoutListen =
        Provider.of<PlayAudioProvider>(context, listen: false);

    return IconButton(
      onPressed: () async {
        if (songPath.isEmpty) return;

        await _playProviderWithoutListen.playAudio(File(songPath));
      },
      icon: Icon(
          _playProvider.isSongPlaying ? Icons.pause : Icons.play_arrow_rounded),
      color: const Color(0xff4BB543),
      iconSize: 30,
    );
  }

  _audioProgressSection() {
    final _playProvider = Provider.of<PlayAudioProvider>(context);

    return Expanded(
        child: Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LinearPercentIndicator(
        percent: _playProvider.currLoadingStatus,
        backgroundColor: Colors.black26,
        progressColor: const Color(0xff4BB543),
      ),
    ));
  }

  _resetButton() {
    final _recordProvider =
        Provider.of<RecordAudioProvider>(context, listen: false);

    return InkWell(
      onTap: () => _recordProvider.clearOldData(),
      child: Center(
        child: Container(
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Reset',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
