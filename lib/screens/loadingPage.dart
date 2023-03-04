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
    bool isReceived = Provider.of<RecordAudioProvider>(context).received;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircularProgressIndicator(),
            isReceived? ElevatedButton( onPressed: () {
              Navigator.of(context).pushNamed('/resultsPage');
            },child: Text('Received')): Text("NOt received"),
        ],)
      ),
    );
  }
}
