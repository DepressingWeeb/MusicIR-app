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
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AudioScreen(), // Current screen
    NameLyricScreen(), // New screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Switch between screens
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E), // Background color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Shadow color
              offset: Offset(0, -2), // Position of shadow (top side of bar)
              blurRadius: 8, // Blur effect
              spreadRadius: 2, // Spread radius
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF1E1E1E), // Set to transparent
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Audio & File",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: "Name & Lyric",
            ),
          ],
        ),
      ),
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        tempFilePath = result.files.single.path!;
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
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Linear Gradient Background
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00667B),
                      Color(0xFF002F38),
                      Color(0xFF1E1E1E),
                    ],
                    stops: [0.0, 0.49, 0.89],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "What song do you looking at?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 17.0,
                            color: Color(0xFFEDF2F4),
                          )
                        ],
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
                        radius: 96,
                        backgroundColor: Color(0xFF5275AF),
                        child: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 90,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Section with Solid Background Color
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Color(0xFF1E1E1E),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: Icon(
                        Icons.upload_file,
                        color: Colors.black,
                      ),
                      label: Text(
                        "Attach files",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 100),
                    Text(
                      isRecording
                          ? "Listening, please wait..."
                          : "Record or upload files!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (tempFilePath == null) {
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResultPage(filePath: tempFilePath),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5275AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        elevation: 0,
                      ),
                      icon: Icon(
                        Icons.multitrack_audio_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Start Analyzing",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New screen for Name & Lyric
class NameLyricScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Linear Gradient Background
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00667B),
                      Color(0xFF002F38),
                      Color(0xFF1E1E1E),
                    ],
                    stops: [0.0, 0.49, 0.89],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Adjust vertical padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 12), // Add padding to the left
                        child: Text(
                          "Enter your song name or lyric",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 17.0,
                                color: Color(0xFFFED2F4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Adjust spacing between text and search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchResultScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Icon(Icons.search, color: Colors.grey),
                                ),
                                Text(
                                  "Search",
                                  style: TextStyle(color: Colors.black54, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Section with Solid Background Color
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Color(0xFF1E1E1E),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding
                      child: Text(
                        "Discover song names and lyrics easily.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00667B),
              Color(0xFF002F38),
              Color(0xFF1E1E1E),
            ],
            stops: [0.0, 0.49 / 2, 0.89 / 2], // Adjusted stops for smoother transition
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with only the search field and "Cancel" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF121212),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(Icons.search, color: Colors.white),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 11.0),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(Icons.clear, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                          });
                                        },
                                      )
                                      : null,
                                ),
                                style: TextStyle(color: Colors.white),
                                onChanged: (text) {
                                  setState(() {
                                    print("Search text: $text");
                                  }); // Refresh UI to show or hide "X" button
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your result",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 17.0,
                              color: Color(0xFFEDF2F4),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Add your results list or content here
                      Container(
                        width: double.infinity, // Ensures the container spans the full screen width
                        padding: const EdgeInsets.all(16.0), // Padding for inner content
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFef6F6).withOpacity(0.0), // Transparent at the start
                              Color(0xFFEde0E0).withOpacity(0.2), // Slightly opaque at the end
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Love Me Do - Mono / Remastered",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            // Add more rows or content here
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}