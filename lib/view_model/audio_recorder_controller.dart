import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

import '../object/message.dart';

class AudioRecorderController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String? _recordingFilePath;
  List<Message>? messageList = [];

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

  Future<String> sendAudioData(String filePath) async {
    final audioFileBytes = await File(filePath).readAsBytes();
    final base64AudioFile = base64Encode(audioFileBytes);

    //messageList to Json
    List<Map<String, String>> messageListJson = messageList
            ?.map((message) => {
                  'role': message.role,
                  'content': message.content,
                })
            .toList() ??
        [];

    print(messageListJson);

    final response = await http.post(
      Uri.parse(
          'https://wgmywho6v8.execute-api.ap-northeast-2.amazonaws.com/v1/answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'audio': base64AudioFile,
        'messages': messageListJson,
      }),
    );

    if (response.statusCode == 200) {
      print('200is right');

      final jsonResponse = jsonDecode(response.body);
      final audioUrl = jsonResponse['audio_url'];
      final messageListJson = jsonResponse['messages'];
      final List<Message> updatedMessageList = [];

      //receive json and update messageList
      if (messageListJson != null) {
        messageListJson.forEach((messageJson) {
          final message = Message(
            role: messageJson['role'],
            content: messageJson['content'],
          );
          updatedMessageList.add(message);
        });
      }

      // Update messageList with updatedMessageList
      messageList = updatedMessageList;

      //for test
      if (messageList != null) {
        // Convert messageList to JSON string
        List<Map<String, String>> messageListJson = messageList
                ?.map((message) => {
                      'role': message.role,
                      'content': message.content,
                    })
                .toList() ??
            [];

        print(messageListJson);
      }

      log(response.body);
      if (audioUrl == null) {
        return '';
      } else {
        return audioUrl;
      }
    } else {
      print('not 200');
      log(response.body);
      return '';
    }
  }

  void dispose() {
    if (_recorder.isRecording || _recorder.isPaused) {
      _recorder.closeRecorder();
    }
  }
}
