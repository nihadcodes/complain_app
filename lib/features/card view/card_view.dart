import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/local_storage/database_helper.dart';
import '../complain summary/complain_summary.dart';

class CardViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> complaintList;

  const CardViewPage({Key? key, required this.complaintList}) : super(key: key);

  @override
  _CardViewPageState createState() => _CardViewPageState();
}

class _CardViewPageState extends State<CardViewPage> {
  late List<Map<String, dynamic>> _complaintList;
  late AudioPlayer _audioPlayer;
  late Map<int, VideoPlayerController?> _videoControllers;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _complaintList = List.from(widget.complaintList);
    _audioPlayer = AudioPlayer();
    _videoControllers = {};
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < _complaintList.length; i++) {
      final videoPath = _complaintList[i]['videoPath'];
      if (videoPath != null) {
        _videoControllers[i] = VideoPlayerController.file(File(videoPath))
          ..initialize().then((_) {
            setState(() {});
          });
      } else {
        _videoControllers[i] = null;
      }
    }
  }

  void _deleteAllComplaints() {
    DatabaseHelper().deleteAllComplaints();
    setState(() {
      _complaintList.clear();
    });
  }

  void _showActionDialog(Map<String, dynamic> complaintData, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplainSummary(complaintData: complaintData),
                  ),
                );
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseHelper().deleteComplaint(id);
                setState(() {
                  _complaintList.removeWhere((complaint) => complaint['id'] == id);
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoControllers.forEach((key, controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Response List'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAllComplaints,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _complaintList.isEmpty
            ? Center(child: Text('No complaints available'))
            : ListView.builder(
          itemCount: _complaintList.length,
          itemBuilder: (context, index) {
            final reversedIndex = _complaintList.length - 1 - index;
            final complaintData = _complaintList[reversedIndex];
            final id = complaintData['id'];

            return GestureDetector(
              onLongPress: () {
                _showActionDialog(complaintData, id);
              },
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee ID: ${complaintData['employeeId']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complain Against: ${complaintData['complainAgainst']}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${complaintData['complainDescription']}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      if (complaintData['imagePath'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(complaintData['imagePath']),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (_videoControllers[reversedIndex] != null &&
                          _videoControllers[reversedIndex]!.value.isInitialized)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: _videoControllers[reversedIndex]!.value.aspectRatio,
                                child: VideoPlayer(_videoControllers[reversedIndex]!),
                              ),
                            ),
                            VideoProgressIndicator(
                              _videoControllers[reversedIndex]!,
                              allowScrubbing: true,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _videoControllers[reversedIndex]!.value.isPlaying
                                      ? _videoControllers[reversedIndex]!.pause()
                                      : _videoControllers[reversedIndex]!.play();
                                });
                              },
                              child: Icon(
                                _videoControllers[reversedIndex]!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 6),
                      if (complaintData['audioPath'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_isAudioPlaying) {
                                  await _audioPlayer.stop();
                                  setState(() {
                                    _isAudioPlaying = false;
                                  }
                                  );
                                } else {
                                  await _audioPlayer.play(DeviceFileSource(complaintData['audioPath']));
                                  setState(() {
                                    _isAudioPlaying = true;
                                  });
                                }
                              },
                              child: Text(_isAudioPlaying ? 'Pause Audio' : 'Play Audio'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
