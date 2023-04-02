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

  void _onRecordButtonPressed() async {
    if (!_isRecording) {
      await widget.audioRecorderController.startRecording();
    } else {
      String? filePath = await widget.audioRecorderController.stopRecording();
      if (filePath != null) {
        await widget.audioRecorderController.sendAudioData(filePath);
        // DEBUG: Play audio file
        AudioPlayer audioPlayer = AudioPlayer();
        await audioPlayer.setSourceDeviceFile(filePath);
        await audioPlayer.play(DeviceFileSource(filePath));
      }
    }
    setState(() {
      _isRecording = !_isRecording;
    });
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
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              onPressed: _onRecordButtonPressed,
            ),
            Text(_isRecording ? 'Recording...' : 'Tap to record'),
          ],
        ),
      ),
    );
  }
}
