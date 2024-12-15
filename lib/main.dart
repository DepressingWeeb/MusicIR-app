import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_ir/result_page.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioScreen(),
    );
  }
}

class AudioScreen extends StatefulWidget {
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  bool isRecording = false;
  final AudioRecorder _record = AudioRecorder();
  String? tempFilePath;

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    tempFilePath = "${tempDir.path}/recorded_audio.m4a";

    if (await _record.hasPermission()) {
      await _record.start(
        const RecordConfig(),
        path: tempFilePath!,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      isRecording = false;
    });
    _showSnackBar("Recording saved at: $path");
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        tempFilePath=result.files.single.path!;
      });
      print(tempFilePath);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "What song do you looking at ?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (isRecording) {
                  await _stopRecording();
                } else {
                  await _startRecording();
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade300,
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text("Attach files"),
            ),
            SizedBox(height: 20),
            Text(
              isRecording ? "Listening, please wait..." : "Record or upload files",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Builder(
                builder: (ctx){
                  if (tempFilePath == null){
                    return const SizedBox();
                  }
                  String fileName = tempFilePath!.split(Platform.pathSeparator).last;
                  return Text(
                      "File chosen: $fileName",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        )
                  );
                }
            ),
            SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: (){
                if (tempFilePath==null) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultPage(filePath: tempFilePath,),
                  ),
                );
              },
              icon: Icon(Icons.multitrack_audio_outlined),
              label: Text("Start Analyzing"),
            ),
          ],
        ),
      ),
    );
  }
}
