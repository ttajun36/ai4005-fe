import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

class AudioRecorderController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _recordingFilePath;

  Future<void> startRecording() async {
    if (_recordingFilePath == null) {
      await _recorder.openRecorder();
      await _recorder.startRecorder(toFile: 'temp.wav');
    } else {
      await _recorder.resumeRecorder();
    }
  }

  Future<void> pauseRecording() async {
    await _recorder.pauseRecorder();
  }

  Future<String?> stopRecording() async {
    String? tempFilePath = await _recorder.stopRecorder();
    if (tempFilePath != null && tempFilePath.isNotEmpty) {
      if (_recordingFilePath == null) {
        _recordingFilePath = tempFilePath;
      } else {
        await _appendAudioDataToFile(_recordingFilePath!, tempFilePath);
      }
    }
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

  /*  Binary Data 로 SendAudioData 보내기
   *  Future<bool> sendAudioData(String filePath) async {
   *    var request = http.MultipartRequest(
   *        'POST',
   *        Uri.parse(
   *            'https://wgmywho6v8.execute-api.ap-northeast-2.amazonaws.com/v1/answer'));
   *    request.files.add(await http.MultipartFile.fromPath('audio', filePath));
   *    var response = await request.send();
   *    if (response.statusCode == 200) {
   *      print('Audio data successfully sent to API');
   *      return true;
   *    } else {
   *      print('Failed to send audio data to API');
   *      return false;
   *    }
   *  }
   */

  Future<void> _appendAudioDataToFile(
      String existingFilePath, String newFilePath) async {
    File existingFile = File(existingFilePath);
    File newFile = File(newFilePath);
    List<int> existingData = await existingFile.readAsBytes();
    List<int> newData = await newFile.readAsBytes();
    List<int> combinedData = List<int>.from(existingData)..addAll(newData);
    await existingFile.writeAsBytes(combinedData);
    await newFile.delete();
  }

  void dispose() {
    if (_recorder.isRecording || _recorder.isPaused) {
      _recorder.closeRecorder();
    }
  }
}
