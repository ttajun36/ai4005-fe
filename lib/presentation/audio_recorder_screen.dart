import 'package:ai4005_fe/view_model/audio_recorder_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioRecorderScreen extends StatefulWidget {
  final AudioRecorderController audioRecorderController;

  const AudioRecorderScreen({
    required this.audioRecorderController,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  bool _isRecording = false;
  bool _ableRecording = true;
  bool _talkingAI = false;

  void _onRecordButtonPressed() async {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      await widget.audioRecorderController.startRecording();
    } else {
      setState(() {
        _ableRecording = !_ableRecording;
      });
      String? filePath = await widget.audioRecorderController.stopRecording();
      if (filePath != null) {
        await widget.audioRecorderController.sendAudioData(filePath);
        // DEBUG: Play audio file
        AudioPlayer audioPlayer = AudioPlayer();
        await audioPlayer.setSourceDeviceFile(filePath);
        setState(() {
          _talkingAI = !_talkingAI;
        });
        Duration? duration = await audioPlayer.getDuration();
        await audioPlayer.play(DeviceFileSource(filePath));
        if (duration != null) {
          await Future.delayed(duration, () {
            setState(() {
              _talkingAI = !_talkingAI;
              _ableRecording = !_ableRecording;
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _talkingAI
                ? Image.asset('assets/catTalk.gif')
                : Image.asset('assets/closemouth.jpeg'),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              onPressed: _ableRecording ? _onRecordButtonPressed : null,
              padding: const EdgeInsets.only(top: 100, bottom: 10),
            ),
            Text(_isRecording ? 'Recording...' : 'Tap to record'),
          ],
        ),
      ),
    );
  }
}
