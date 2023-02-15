import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:finalmicrophone/services/storage_management.dart';
import 'package:finalmicrophone/services/permission_management.dart';
import 'package:finalmicrophone/services/toast_services.dart';

class RecordAudioProvider extends ChangeNotifier {
  final Record _record = Record();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';

  bool get isRecording => _isRecording;

  String get recordedFilePath => _afterRecordingFilePath;

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

    final url = Uri.parse('http://192.168.0.105:90/upload-audio');
    final file = File(_audioFilePath!);

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('File uploaded successfully:');
    } else {
      print('Error while uploading file');
    }

    print('Audio file path: $_audioFilePath');

    _isRecording = false;
    _afterRecordingFilePath = _audioFilePath ?? '';
    notifyListeners();
  }
}

//
// final url = Uri.parse('http://192.168.0.105:90/upload-audio/');
// final file = File(_audioFilePath!);
//
// final request = http.MultipartRequest('POST', url);
// request.files.add(await http.MultipartFile.fromPath('audio', file.path));
//
// final response = await request.send();
//
// if (response.statusCode == 200) {
// print('File Uploaded Successfully');
// } else {
// print(response.statusCode);
// print('Error while uploading file');
// }

// List<int> audioBytes = await File(_audioFilePath!).readAsBytes();
//
// // Encode audio bytes as base64 string
// String audioBase64 = base64Encode(audioBytes);
//
// // Prepare POST request with audio data as body
// final url = Uri.parse('http://192.168.0.105:90/upload-audio');
// Map<String, String> headers = {'Content-Type': 'application/json'};
// Map<String, dynamic> body = {'audio_data': audioBase64};
// http.Response response =
//     await http.post(url, headers: headers, body: jsonEncode(body));
//
// if (response.statusCode == 200) {
// print('Audio sent successfully');
// } else {
// print(response.statusCode);
// print('Error sending audio');
// }
