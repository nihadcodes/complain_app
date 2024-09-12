import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/local_storage/database_helper.dart';
import '../complain summary/complain_summary.dart';
import '../card view/card_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';


class ComplainForm extends StatelessWidget {
  final String username;

  const ComplainForm({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complain Form',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: MultiInputForm(username: username),
    );
  }
}

class MultiInputForm extends StatefulWidget {



  final String username;


  const MultiInputForm({Key? key, required this.username}) : super(key: key);

  @override
  _MultiInputFormState createState() => _MultiInputFormState();
}

class _MultiInputFormState extends State<MultiInputForm> {
  final Record _audioRecorder = Record();
  String? _audioFileName;
  bool _isRecording = false;
  bool _isAudioPlaying = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedNotify;
  String? _selectedComplainBasis;
  String? _selectedWitness;
  String? _selectedComplainAgainst;


  Future<void> _playAudio() async {
    if (_audio != null) {
      try {
        print('Playing audio from file: ${_audio!.path}'); // Log before playing
        await _audioPlayer.play(DeviceFileSource(_audio!.path));
        setState(() {
          _isAudioPlaying = true;
        });
        print('Audio playing.'); // Log after playing
      } catch (e) {
        print('Error during playback: $e'); // Log exceptions
        _showErrorDialog('An error occurred while playing audio.');
      }
    } else {
      print('No audio file selected.'); // Log if no file selected
      _showErrorDialog('No audio file selected.');
    }
  }



  Future<void> _pauseAudio() async {
    if (_audio != null && _isAudioPlaying) {
      try {
        print('Pausing audio...');
        await _audioPlayer.pause();
        setState(() {
          _isAudioPlaying = false;
        });
        print('Audio paused.');
      } catch (e) {
        print('Error during pause: $e');
        _showErrorDialog('An error occurred while pausing audio.');
      }
    } else {
      print('No audio playing or no audio file selected.');
    }
  }



  VideoPlayerController? _videoPlayerController;

  final _formKey = GlobalKey<FormState>();

  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _notifyController = TextEditingController();
  final _complainAgainstController = TextEditingController();
  final _complainBasisController = TextEditingController();
  final _witnessController = TextEditingController();
  final _complainDescriptionController = TextEditingController();
  final _actionSeekController = TextEditingController();
  final _occuranceDateController = TextEditingController();


  File? _image;
  File? _video;
  File? _audio;
  DateTime? _selectedDate;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // _loadRecentData();
  }

  // Future<void> _loadRecentData() async {
  //   List<Map<String, dynamic>> complaints = await DatabaseHelper()
  //       .getComplaints();
  //
  //   if (complaints.isNotEmpty) {
  //     Map<String, dynamic> recentComplaint = complaints.last;
  //
  //     setState(() {
  //       _employeeIdController.text = recentComplaint['employeeId'] ?? '';
  //       _nameController.text = recentComplaint['name'] ?? '';
  //       _notifyController.text = recentComplaint['notify'] ?? '';
  //       _complainAgainstController.text =
  //           recentComplaint['complainAgainst'] ?? '';
  //       _complainDescriptionController.text =
  //           recentComplaint['complainDescription'] ?? '';
  //       _actionSeekController.text = recentComplaint['actionSeek'] ?? '';
  //       _selectedDate = recentComplaint['selectedDate'] != null
  //           ? DateTime.parse(recentComplaint['selectedDate'])
  //           : null;
  //       _image = recentComplaint['imagePath'] != null ? File(recentComplaint['imagePath']) : null;
  //       _video = recentComplaint['videoPath'] != null ? File(recentComplaint['videoPath']) : null;
  //       _audio = recentComplaint['audioPath'] != null ? File(recentComplaint['audioPath']) : null;
  //     });
  //   }
  // }
  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _notifyController.dispose();
    _complainAgainstController.dispose();
    _complainBasisController.dispose();
    _witnessController.dispose();
    _complainDescriptionController.dispose();
    _actionSeekController.dispose();
    _videoPlayerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    log('picked_file: ${pickedFile?.name}');

    if(pickedFile == null){
      return;
    }
    setState(() {
      _image = File(pickedFile.path);
    });


  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await _picker.pickVideo(source: source);

    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
        _videoPlayerController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
          });
      });
    }
  }
  Future<void> _recordAudio() async {
    final status = await Permission.microphone.request();
    print('Microphone permission status: $status');

    if (status == PermissionStatus.granted) {
      try {
        if (_isRecording) {
          print('Stopping recording...');
          final filePath = await _audioRecorder.stop();
          print('Recording stopped. File path: $filePath');
          setState(() {
            _audio = File(filePath!);
            _audioFileName = _audio!.path.split('/').last;
            _isRecording = false;
          });
        } else {
          print('Starting recording...');
          await _audioRecorder.start();
          print('Recording started.');
          setState(() {
            _isRecording = true;
            _audioFileName = null;
          });
        }
      } catch (e) {
        print('Error during recording: $e');
        _showErrorDialog('An error occurred while recording audio.');
      }
    } else {
      _showErrorDialog('Microphone permission is required to record audio.');
    }
  }


  Future<void> _pickAudioFromFile() async {
    print('Picking audio file...'); // Log picking file action
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      print('Audio file selected: ${result.files.single.path}');
      setState(() {
        _audio = File(result.files.single.path!);
        _audioFileName = _audio!.path.split('/').last;
      });
    } else {
      print('No audio file selected.'); // Log if no file selected
      _showErrorDialog('No audio file selected.');
    }
  }




  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Pick from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showVideoSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Pick from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Record Video'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideo(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.audiotrack),
              title: Text('Pick from File'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAudioFromFile();
                _audioPlayer;
              },
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _saveLocally() async {
    if (_formKey.currentState?.validate() ?? false) {
      final complaint = {
        'employeeId': _employeeIdController.text,
        'name': _nameController.text,
        'notify': _notifyController.text,
        'complainAgainst': _complainAgainstController.text,
        'complainBasis': _complainBasisController.text,
        'witness': _witnessController.text,
        'complainDescription': _complainDescriptionController.text,
        'actionSeek': _actionSeekController.text,
        'selectedDate': _selectedDate?.toIso8601String(),
        'imagePath': _image?.path,
        'videoPath': _video?.path,
        'audioPath': _audio?.path,

      };

      print('Data to be saved: $complaint');

     await DatabaseHelper().insertComplaint(complaint);

      List<Map<String, dynamic>> complaints = await DatabaseHelper()
          .getComplaints();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CardViewPage(complaintList: complaints),
        ),
      );
      _clearForm();
    }
  }

  void _clearForm() {
    setState(() {
      _employeeIdController.clear();
      _nameController.clear();
      _notifyController.clear();
      _complainAgainstController.clear();
      _complainDescriptionController.clear();
      _actionSeekController.clear();
      _selectedDate = null;
      _image = null;
      _video = null;
      _audio = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {


      final String employeeId = _employeeIdController.text;
      final String notify = _notifyController.text;
      final String complainAgainst = _complainAgainstController.text;
      final String complainBasis = _complainBasisController.text;
      final String witness = _witnessController.text;
      final String complainDescription = _complainDescriptionController.text;
      final String seekingAction = _actionSeekController.text;
      final String occuranceDate = _occuranceDateController.text;



      String apiUrl = 'http://118.179.223.41:7007/ords/xact_erp/HRM/Complain_form?P_ENTRY_BY_ID=4&P_INSIDE=y&P_EVENT_LOCATION=Barishal&P_EVIDENCE=12&P_WITHNESS=1&P_NOTIFYING_PERSON=2&P_NOTIFYING_AUTH=2&P_SEEKING_ACTION=1&P_HOW_HAPP=2&P_COMPL_DTLS=$complainDescription&P_COMPL_AGAINST_EMPL=1&P_OCCURANCE_DATE=29-08-2024&P_COMPL_POLICY=1&P_COMPL_BASIS=1&P_GRIV_EMPL_ID=1';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),

            body: {
              'P_GRIV_EMPL_ID': employeeId,
              'P_ENTRY_BY_ID': widget.username,
              'P_NOTIFYING_AUTH': notify,
              'P_COMPL_AGAINST_EMPL': complainAgainst,
              'P_COMPL_BASIS': complainBasis,
              'P_WITHNESS': witness,
              'P_COMPL_DTLS': complainDescription,
              'P_SEEKING_ACTION': seekingAction,
              'P_OCCURANCE_DATE': occuranceDate,
              'P_EVIDENCE': _image != null ? '1' : '0',
          },
        );

        if (response.statusCode == 200) {
          print('Response status: ${response.statusCode}');
          log(response.body);

          final complaint = {
            'employeeId': _employeeIdController.text,
            'name': _nameController.text,
            'notify': _notifyController.text,
            'complainAgainst': _complainAgainstController.text,
            'complainBasis': _complainBasisController.text,
            'witness': _witnessController.text,
            'complainDescription': _complainDescriptionController.text,
            'actionSeek': _actionSeekController.text,
            'selectedDate': _selectedDate?.toIso8601String(),
            'imagePath': _image?.path,
            'videoPath' : _video?.path,
            'audioPath': _audio?.path,
          };

          await DatabaseHelper().insertComplaint(complaint);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ComplainSummary(complaintData: complaint),
            ),
          );
          _clearForm();

        } else {
          _showErrorDialog('Failed to submit the form. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // void _navigateToCardViewPage() async {
  //   List<Map<String, dynamic>> complaints = await DatabaseHelper()
  //       .getComplaints();
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => CardViewPage(complaintList: complaints),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Complain Form'),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.person_pin, color: Colors.white), // User icon
                const SizedBox(width: 8),
                Center(
                  child: Text(
                    widget.username,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _employeeIdController,
                        decoration: InputDecoration(
                          labelText: 'Employee ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your employee ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedNotify, // The currently selected option
                        decoration: InputDecoration(
                          labelText: 'Notify',
                          border: OutlineInputBorder(),
                        ),
                        items: ['HR', 'Finance', 'Developer'].map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNotify = newValue;
                          });
                          _notifyController.text = newValue ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a name to notify';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _complainAgainstController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Comp Against',
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your name';
                      //     }
                      //     return null;
                      //   },
                      // ),



                      DropdownButtonFormField<String>(
                        value: _selectedComplainAgainst, // The currently selected option
                        decoration: InputDecoration(
                          labelText: 'Complain Against',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Harassment', 'Unfair Behavior', 'Technical Problem'].map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedComplainAgainst = newValue; // Update the selected option
                          });
                          _complainAgainstController.text = newValue ?? ''; // Update the controller's text
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a name to notify';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedComplainBasis,
                        decoration: InputDecoration(
                          labelText: 'Basis of Complaint',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Option 1', 'Option 2', 'Option 3'].map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedComplainBasis = newValue;
                          });
                          _complainBasisController.text = newValue ?? '';
                          log('selected value : $newValue');
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a name to notify';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedWitness,
                        decoration: InputDecoration(
                          labelText: 'Witness(if any)',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Option 1', 'Option 2', 'Option 3'].map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedWitness = newValue;
                          });

                          _witnessController.text = newValue ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a name to notify';
                          }
                          return null;
                        },
                      ),


                      SizedBox(height: 16),
                      TextFormField(
                        controller: _complainDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description of the Complain',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _actionSeekController,
                        decoration: InputDecoration(
                          labelText: 'What action do you seek?',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the action you seek';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _selectDate,
                              child: Text(
                                _selectedDate == null
                                    ? 'Date of occurrence'
                                    : _selectedDate!.toLocal().toString().split(
                                    ' ')[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showImageSourceActionSheet,
                              icon: Icon(Icons.camera_alt_sharp),
                              label: Text('Upload Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _image == null
                          ? Text('No image selected.')
                          : Image.file(
                        _image!,
                        height: 200,
                        width: 200,
                      ),


                      if (_video != null && _videoPlayerController != null)
                        _videoPlayerController!.value.isInitialized
                            ? AspectRatio(
                          aspectRatio: _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        )
                            : Container(),


                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showVideoSourceActionSheet,
                              icon: Icon(Icons.video_collection),
                              label: Text('Upload Video'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          ListTile(
                            onTap: _showAudioSourceActionSheet,
                            title: Text(_audioFileName ?? 'Select from files'),
                            leading: Icon(Icons.audio_file, color: Colors.blueAccent),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _recordAudio,
                                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                                    label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                if (_audioFileName != null) ...[
                                  SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: _isAudioPlaying ? _pauseAudio : _playAudio,
                                    icon: Icon(_isAudioPlaying ? Icons.pause : Icons.play_arrow),
                                    label: Text(_isAudioPlaying ? 'Pause Audio' : 'Play Audio'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                  ),

                                ],
                              ],
                            ),
                          ),
                        ],
                      ),



                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveLocally,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Save & Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),

                ),
                ElevatedButton(
                  onPressed: _clearForm,
                  child: Text('Clear Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}












