import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
class ResultPage extends StatefulWidget {
  final filePath;
  const ResultPage({super.key, this.filePath});
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<dynamic> sortedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    // Replace with your local file or mock data call
    final File audioFile = File(widget.filePath);
    final response = await uploadRecording(audioFile);
    if (response != null) {
      setState(() {
        sortedItems = response['item_sorted'];
        isLoading = false;
      });
    }
  }

  Future<Map<String,dynamic>?> uploadRecording(File audioFile) async {
    final dio = Dio();
    print(audioFile.path);
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(audioFile.path, filename: audioFile.path),
    });
    try {
      final response = await dio.post(
        'https://musicir-1089901605984.asia-southeast1.run.app/upload',
        data: formData,
      );
      return response.data;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Your results", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildResults(),
    );
  }

  Widget _buildResults() {
    if (sortedItems.isEmpty) {
      return Center(
        child: Text("No results found.",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    }

    final bestMatch = sortedItems.first;
    final otherResults = sortedItems.skip(1).toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Best Match"),
        _buildResultItem(bestMatch, isBestMatch: true),
        SizedBox(height: 16),
        _buildSectionTitle("Other results"),
        ...otherResults.map((item) => _buildResultItem(item)).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildResultItem(dynamic item, {bool isBestMatch = false}) {
    final song = item['song_info'];
    final songName = song['name'];
    final songLink = song['link'];

    return GestureDetector(
      onTap: () => _openYouTubeLink(songLink),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBestMatch ? Colors.teal.shade800 : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  songName,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            Icon(Icons.play_circle_filled, color: Colors.red, size: 28),
          ],
        ),
      ),
    );
  }
}
