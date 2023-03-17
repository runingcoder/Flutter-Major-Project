import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:provider/provider.dart';
import '../provider/play_audio_provider.dart';
import '../provider/record_audio_provider.dart';
import 'package:http/http.dart' as http;


class UploadAndRecord extends StatefulWidget {
  const UploadAndRecord({Key? key}) : super(key: key);

  @override
  State<UploadAndRecord> createState() => _UploadAndRecordState();
}

class _UploadAndRecordState extends State<UploadAndRecord> {
  late DocumentSnapshot _docSnapshot;
   String? screenName = '';

  // final user = FirebaseAuth.instance.currentUser!;


@override
  void initState()  {
  callUser();
    super.initState();
  }
callUser() async {
  late DocumentSnapshot doc;
  final docRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid!);
  doc = await docRef.get();
  final data = doc.data() as Map<String, dynamic>;
  print('data is ');
  print(data);
  screenName = data['first name'];
if(screenName == null){
  screenName = FirebaseAuth.instance.currentUser!.displayName;
}
}

  @override
  Widget build(BuildContext context) {
    bool isReceived = Provider.of<RecordAudioProvider>(context).received;
    bool connectionFail =
        Provider.of<RecordAudioProvider>(context).connectionfail;

    final _recordProvider = Provider.of<RecordAudioProvider>(context);
    final _playProvider = Provider.of<PlayAudioProvider>(context);
    bool isRecordingInProgress = _recordProvider.recordedFilePath.isNotEmpty &&
        !isReceived &&
        !connectionFail;
    bool isUploadingInProgress =
        _recordProvider.uploadStatus && !isReceived && !connectionFail;
    bool resultAfterRecording = _recordProvider.recordedFilePath.isNotEmpty &&
        !_playProvider.isSongPlaying &&
        _recordProvider.received;
    bool resultAfterUploading = _recordProvider.uploadStatus &&
        !_playProvider.isSongPlaying &&
        _recordProvider.received;
    bool uploadAudioCase = !_recordProvider.uploadStatus &&
        !_recordProvider.recordedFilePath.isNotEmpty &&
        !_recordProvider.isRecording &&
        !connectionFail;
    bool recordAudioCase = !_recordProvider.uploadStatus &&
        !_recordProvider.recordedFilePath.isNotEmpty &&
        !connectionFail ;
    String imageUrlBG =
        'https://images.unsplash.com/photo-1550895030-823330fc2551?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${screenName} !',
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
      backgroundColor: Colors.white,

      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(imageUrlBG))),
          child: SingleChildScrollView(
            child: Column(
//this doesn't matter if SIngelChildScrollView is used.
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                children: [
                    uploadAudioCase? Text(
                      'Switch IP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                    ): Text(''),
                    uploadAudioCase?   SizedBox(height: 30): SizedBox(height: 0),
                    uploadAudioCase?  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _recordProvider.riyanshwifi(),
                          child: Text(
                            'Riaynsh Wifi',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.check,
                            color: _recordProvider.ipLocation == IPLocation.mobileHotspot ? Colors.grey : Colors.green),
                      ],
                    ): Text(''),
                    uploadAudioCase? SizedBox(height: 20): SizedBox(height: 0),
                    uploadAudioCase?  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _recordProvider.mobilehotspot(),
                          child: Text(
                            'Mobile Hotspot',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.check,
                            color: _recordProvider.ipLocation == IPLocation.mobileHotspot ? Colors.green : Colors.grey),
                      ],
                    ): Text(''),
                  ]
                ),

                const SizedBox(
                  height: 100,
                ),
                if (uploadAudioCase) _recordHeading('Upload Audio'),
                const SizedBox(
                  height: 40,
                ),
                if (uploadAudioCase) _uploadSection(),
                const SizedBox(
                  height: 60,
                ),
                if (recordAudioCase) _recordHeading('Record Audio'),
                const SizedBox(
                  height: 40,
                ),
                if (recordAudioCase) _recordingSection(),
                if (connectionFail) afterConnectionFail(),
                afterReceived(),
                const SizedBox(height: 40),

                if (resultAfterRecording) ResultColumn(),
                if (resultAfterUploading) ResultColumn(),
                const SizedBox(
                  height: 40,
                ),
                if (isRecordingInProgress) CircularProgressIndicator(),
                if (!isRecordingInProgress) Text(''),
                if (isUploadingInProgress) CircularProgressIndicator(),
                if (!isUploadingInProgress) Text(''),

// _resetButton(),
// _loadingPage(),
              ],
            ),
          )),
    );
  }
// loadingRequest(){
//   final _recordProvider = Provider.of<RecordAudioProvider>(context);
//
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       CircularProgressIndicator(),
//       const SizedBox(
//         height: 40,
//       ),
//       GestureDetector(
//         onTap: () {
//           Provider.of<RecordAudioProvider>(context, listen: false)
//               .clearOldData();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             'Cancel search',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

  afterConnectionFail() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return SingleChildScrollView(
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
              Provider.of<RecordAudioProvider>(context, listen: false)
                  .clearOldData();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    );
  }
  afterReceived() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return InkWell(
      onTap: () {
        print(_recordProvider.song);
        Navigator.of(context).pushNamed('/resultsPage');
      },
      child: _recordProvider.received
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
    );
  }
  _uploadSection() {
    final _recordProviderWithoutListener =
    Provider.of<RecordAudioProvider>(context, listen: false);
    return InkWell(
      onTap: () async => await _recordProviderWithoutListener.uploadAudio(),
      child: _commonIconSection(Icons.upload, Colors.brown),
    );
  }
  _recordHeading(String messageTime) {
    return Center(
      child: Text(
        messageTime,
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }
  ResultColumn() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _resetButton(),
        const SizedBox(
          height: 40,
        ),
        Text(
            'Response Time: ${_recordProvider.responseTime.inSeconds.toString()} seconds'),
      ],
    );
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
      child: Icon(iconData, color: Colors.white, size: 30),
    );
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
