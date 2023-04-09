import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

class AudioRecorderController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String? _recordingFilePath;

  Future<void> startRecording() async {
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: 'temp.wav');
  }

  Future<String?> stopRecording() async {
    // tempFilePath = /Users/eomtaejun/Library/Developer/CoreSimulator/Devices/8F76A02B-7407-4901-9286-0F7558F271A6/data/Containers/Data/Application/043B08A0-CE37-4FE5-BBCF-BFEBF76056A8/tmp/temp.wav
    String? tempFilePath = await _recorder.stopRecorder();
    _recordingFilePath = tempFilePath;
    await _recorder.closeRecorder();
    return _recordingFilePath;
  }

  Future<bool> sendAudioData(String filePath) async {
    final audioFileBytes = await File(filePath).readAsBytes();
    final base64AudioFile = base64Encode(audioFileBytes);

    final response = await http.post(
      Uri.parse(
          'https://wgmywho6v8.execute-api.ap-northeast-2.amazonaws.com/v1/answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'audio': base64AudioFile}),
    );

    if (response.statusCode == 200) {
      log(response.body);
      return true;
    } else {
      log(response.body);
      return false;
    }
  }

  void dispose() {
    if (_recorder.isRecording || _recorder.isPaused) {
      _recorder.closeRecorder();
    }
  }
}
