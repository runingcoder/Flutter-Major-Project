import 'dart:io';
import 'dart:convert';

import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:record/record.dart';
import 'package:finalmicrophone/services/storage_management.dart';
import 'package:finalmicrophone/services/permission_management.dart';
import 'package:finalmicrophone/services/toast_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

class RecordAudioProvider extends ChangeNotifier {
  final url = Uri.parse('http://192.168.0.103:90/upload-audio');
  bool _connectionfail = false;
  bool _uploadStatus = false;
  get uploadStatus => _uploadStatus;

  get connectionfail => _connectionfail;
  Duration? _responseTime;
  bool _keepLoading = false;

  get keepLoading => _keepLoading;

  get responseTime => _responseTime;

  void toggleLoading() {
    _keepLoading = true;
  }

  final BuildContext context;

  RecordAudioProvider(this.context);

  Map<String, dynamic> _song = {
    'name': 'Example Song',
    'indices': '0000',
    'city': 'Torronto',
    'url': 'https://www.youtube.com/watch?v=example',
    'channel_url': 'Somthignsdf',
    'image_url': 'https://example.com/image.png',
  };
  bool _received = false;

  get received => _received;

  void changeStatus() {
    _received = !_received;
    notifyListeners();
  }

  Map<String, dynamic> get song => _song;

  void setSong(Map<String, dynamic> newSong) {
    _song = newSong;
    notifyListeners();
  }

  final Record _record = Record();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';

  bool get isRecording => _isRecording;

  String get recordedFilePath => _afterRecordingFilePath;

  onWillPop() {
    _received = false;
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  clearOldData() {
    _afterRecordingFilePath = '';
    _received = false;
    _connectionfail = false;
    _uploadStatus =false;
    notifyListeners();
  }
postRequest(String originalPath) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.103:90/upload-audio'),
    );
    final audioFileField =
        await http.MultipartFile.fromPath('file', originalPath!);
    request.files.add(audioFileField);
    _responseTime = null;
    DateTime startTime = DateTime.now();
    // Send the request and await the response
    final response = await request.send();
    // Handle the response
    if (response.statusCode == 200) {
      print('File uploaded successfully:');
      DateTime endTime = DateTime.now();
      _responseTime = endTime.difference(startTime);
      notifyListeners();
      var finalResponse = await response.stream.bytesToString();
      print('hello there');
      Map<String, dynamic> useResponse = jsonDecode(finalResponse);
      setSong(useResponse);
      changeStatus();
    } else {
      print('Error while uploading file');
      _connectionfail = true;
      print('conenction fail is ' + _connectionfail.toString());

      notifyListeners();
    }
  } catch (e) {
    print('Error sending post request: $e');
    _connectionfail = true;
    print('connection fail is  ' +
        _connectionfail.toString() +
        'in catch block');

    notifyListeners();
  }
}
  recordVoice() async {
    print("entered recordVoice");
    final _isPermitted = (await PermissionManagement.recordingPermission()) &&
        (await PermissionManagement.storagePermission());

    if (!_isPermitted) return;

    if (!(await _record.hasPermission())) return;

    final _voiceDirPath = await StorageManagement.getAudioDir;
    final _voiceFilePath = StorageManagement.createRecordAudioPath(
        dirPath: _voiceDirPath, fileName: 'audio_message');

    await _record.start(
      path: _voiceFilePath,
      numChannels: 1,
      samplingRate: 8000,
    );
    _isRecording = true;
    notifyListeners();

    showToast('Recording Started');
  }
  uploadAudio() async {
    final audioFile = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (audioFile == null) return;
    if (audioFile != null) {
      final filePath = audioFile.files.single.path;

      print('First Uploaded');
      _uploadStatus = true;
      notifyListeners();
      postRequest(filePath!);
      notifyListeners();
    }
  }



  stopRecording() async {
    String? _audioFilePath;

    if (await _record.isRecording()) {
      _audioFilePath = await _record.stop();
      showToast('Recording Stopped');
      // Assume audio file is saved as a File object
    }
    _isRecording = false;
    notifyListeners();
    _afterRecordingFilePath = _audioFilePath ?? '';

    final file = File(_audioFilePath!);
    postRequest(_audioFilePath!);
    notifyListeners();
  }
}
