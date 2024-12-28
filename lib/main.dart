import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_ir/result_page.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
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
      _showSnackBar("File attached: ${result.files.single.name}");
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
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00667B),
                Color(0xFF002F38),
                Color(0xFF1E1E1E),
              ],
              stops: [0.0, 0.49 / 2, 0.89 / 2], // Adjust stops for smoother transition
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0), // Padding for the whole Column
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              // Top Content
              Text(
                "What song do",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 17.0,
                      color: Color(0xFFEDF2F4),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "you looking at?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 17.0,
                      color: Color(0xFFEDF2F4),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
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
              SizedBox(height: 30),
              // Bottom Content
              ElevatedButton.icon(
                onPressed: () async {
                  await _pickFile(); // Call your _pickFile method to attach a file
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tempFilePath == null ? Colors.white : Colors.green, // Dynamic color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                icon: Icon(
                  Icons.upload_file,
                  color: tempFilePath == null ? Colors.black : Colors.white, // Dynamic icon color
                ),
                label: Text(
                  tempFilePath == null ? "Attach files" : "File Attached", // Dynamic text
                  style: TextStyle(
                    color: tempFilePath == null ? Colors.black : Colors.white, // Dynamic text color
                  ),
                ),
              ),
              SizedBox(height: 80),
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
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (tempFilePath == null) {
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(filePath: tempFilePath),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5275AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Enter your song name or lyric",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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
                      SizedBox(height: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
  List<dynamic> _results = [];
  bool _isLoading = false;

  // Function to fetch data from the API
  Future<void> _fetchSearchResults(String query) async {
    final url = Uri.parse(
        "https://musictextsearchapi-1089901605984.asia-southeast2.run.app/search?query=$query&size=20");
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _results = data; // Assuming the API returns a list of results directly
        });
      } else {
        print("Failed to fetch results: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to open a URL
  void _openYouTubeLink(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open the link: $link");
    }
  }

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
            stops: [0.0, 0.49 / 2, 0.89 / 2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with Search Field and Cancel Button
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
                                  contentPadding: EdgeInsets.symmetric(vertical: 6.0),
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
                                    print("Text changed: $text"); // Debug log
                                  });
                                },
                                onSubmitted: (text) {
                                  _fetchSearchResults(text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Results Section
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : _results.isEmpty
                    ? Center(
                        child: Text(
                          "No results found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return Card(
                          color: Color(0xFF121212),
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0), // Padding inside the card
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between left and right sections
                              children: [
                                // Left Section: Icon and Song Name
                                Row(
                                  children: [
                                    Icon(Icons.music_note, color: Colors.green, size: 24), // Music note icon
                                    SizedBox(width: 12), // Spacing between icon and text
                                    Text(
                                      item['title'] ?? "No Title", // Song title
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                // Right Section: Play Icon
                                IconButton(
                                  icon: Icon(Icons.play_circle_filled, color: Colors.red, size: 28), // Play icon
                                  onPressed: () {
                                    _openYouTubeLink(item['link'] ?? ""); // Open the YouTube link
                                  },
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}