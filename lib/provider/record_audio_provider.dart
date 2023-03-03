import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:record/record.dart';
import 'package:finalmicrophone/services/storage_management.dart';
import 'package:finalmicrophone/services/permission_management.dart';
import 'package:finalmicrophone/services/toast_services.dart';

class RecordAudioProvider extends ChangeNotifier {
  final BuildContext context;
  RecordAudioProvider( this.context);
  Map<String, dynamic> _song = {
    'name_and_artist': 'Example Song',
    'indices':'0000',
    'city': 'Torronto',
    'url': 'https://www.youtube.com/watch?v=example',
    'channel_url':'Somthignsdf',
    'image_url': 'https://example.com/image.png',
  };
  bool _received = false;
  get received => _received;

  void changeStatus(){
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

  onWillPop(){
    _received = false;
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  clearOldData() {
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  recordVoice() async {
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
    final url = Uri.parse('http://192.168.0.102:90/upload-audio');
    final file = File(_audioFilePath!);

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('File uploaded successfully:');

      var finalResponse =  await response.stream.bytesToString();
      print('hello there');
      Map<String, dynamic> useResponse = jsonDecode(finalResponse);
      setSong(useResponse);
      changeStatus();



    } else {
      print('Error while uploading file');
    }

    print('Audio file path: $_audioFilePath');


    notifyListeners();
  }}