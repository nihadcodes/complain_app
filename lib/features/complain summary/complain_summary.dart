import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class ComplainSummary extends StatelessWidget {
  final Map<String, dynamic> complaintData;

  const ComplainSummary({Key? key, required this.complaintData}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print(complaintData);


    return Scaffold(
      appBar: AppBar(
        title: Text('Complain Summary'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildDetailTile('Employee ID', complaintData['employeeId'] ?? ''),
                  _buildDetailTile('Name', complaintData['name'] ?? ''),
                  _buildDetailTile('Notify', complaintData['notify'] ?? ''),
                  _buildDetailTile('Complain Against', complaintData['complainBasis'] ?? ''),
                  _buildDetailTile('Basis of Complaint', complaintData['complainAgainst'] ?? ''),
                  _buildDetailTile('Witness', complaintData['witness'] ?? ''),
                  _buildDetailTile('Complain Description', complaintData['complainDescription'] ?? ''),
                  _buildDetailTile('Action Seek', complaintData['actionSeek'] ?? ''),
                  _buildDetailTile(
                    'Selected Date',
                    complaintData['selectedDate'] != null
                        ? DateTime.parse(complaintData['selectedDate'])
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                        : 'No Date Selected',
                  ),
                  if (complaintData['imagePath'] != null)
                    _buildImageCard(complaintData['imagePath']),
                  if (complaintData['videoPath'] != null)
                    _VideoPlayerSection(videoPath: complaintData['videoPath']),
                  if (complaintData['audioPath'] != null)
                    _buildAudioCard(complaintData['audioPath']),
                ],
              )

            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text('Attached Image'),
            leading: Icon(Icons.image, color: Colors.blueAccent),
          ),
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(String audioPath) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final AudioPlayer _audioPlayer = AudioPlayer();
        bool _isPlaying = false;

        void _playPauseAudio() async {
          if (_isPlaying) {
            await _audioPlayer.pause();
          } else {
            await _audioPlayer.play(DeviceFileSource(audioPath));
          }
          setState(() {
            _isPlaying = !_isPlaying;
          });
        }


        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                title: Text('Attached Audio'),
                leading: Icon(Icons.audio_file, color: Colors.blueAccent),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.audiotrack, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        File(audioPath).path.split('/').last,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _playPauseAudio,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Pause Audio' : 'Play Audio'),
                  ),
                  SizedBox(width: 10),
                  // ElevatedButton.icon(
                  //   onPressed: _stopAudio,
                  //   icon: Icon(Icons.stop),
                  //   label: Text('Stop Audio'),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}

class _VideoPlayerSection extends StatefulWidget {

  final String videoPath;

  const _VideoPlayerSection({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerSectionState createState() => _VideoPlayerSectionState();
}



class _VideoPlayerSectionState extends State<_VideoPlayerSection> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text('Attached Video'),
              leading: Icon(Icons.video_collection, color: Colors.blueAccent),
            ),
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}


