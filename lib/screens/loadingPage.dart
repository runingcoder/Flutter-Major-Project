import 'package:flutter/material.dart';
import '../provider/record_audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:finalmicrophone/screens/resultPage.dart';

// class LoadingPage extends StatefulWidget {
//   const LoadingPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoadingPage> createState() => _LoadingPageState();
// }
//
// class _LoadingPageState extends State<LoadingPage> {
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//     // Wait for the provider value to be true
//     await Future.doWhile(() async {
//       final isReceived = context.read<RecordAudioProvider>().received;
//       if (isReceived) {
//         setState(() {
//           _isLoading = false;
//         });
//         return false; // stop waiting
//       }
//       await Future.delayed(Duration(seconds: 2));
//       return true; // continue waiting
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final _recordProvider = Provider.of<RecordAudioProvider>(context);
//     if (_recordProvider.received){
//       Navigator.of(context).pushNamed('/resultsPage');
//     }
//
//     return Scaffold(
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator()
//             : ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pushNamed('/resultsPage');
//           },
//           child: Text('Navigate'),
//         ),
//       ),
//     );
//   }
// }

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<RecordAudioProvider>(context).received;

    if (isLoading) {
      // Navigate to another route once isLoading is true
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShazamResultPage(
          name_and_artist: Provider.of<RecordAudioProvider>(context).song['name_and_artist'],
          url: Provider.of<RecordAudioProvider>(context).song['url'],
          channel_url: Provider.of<RecordAudioProvider>(context).song['channel_url'],
          image_url:
          Provider.of<RecordAudioProvider>(context).song['image_url'],
        )));
      });
    }

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
