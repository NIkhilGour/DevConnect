import 'dart:typed_data';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/tabs/model/skill.dart';
import 'package:devconnect/tabs/widgets/skillsslection.dart'
    show Skillsselection;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class WebAddPost extends StatefulWidget {
  const WebAddPost({super.key});

  @override
  State<WebAddPost> createState() => _WebAddPostState();
}

class _WebAddPostState extends State<WebAddPost> {
  final TextEditingController descriptioncontroller = TextEditingController();
  final TextEditingController githubcontroller = TextEditingController();

  List<Skill> selectedSkills = [];

  PlatformFile? pickedFile;
  Uint8List? fileBytes;
  VideoPlayerController? videoPlayerController;

  final formkey = GlobalKey<FormState>();

  /// Pick Image or Video
  Future<void> pickFile({required bool isImage}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      // Clear old video if exists
      if (videoPlayerController != null) {
        await videoPlayerController!.dispose();
        videoPlayerController = null;
      }

      setState(() {
        pickedFile = file;
        fileBytes = file.bytes;
      });

      if (!isImage) {
        videoPlayerController = VideoPlayerController.network(
          Uri.dataFromBytes(file.bytes!, mimeType: "video/mp4").toString(),
        );
        await videoPlayerController!.initialize();
        videoPlayerController!
          ..setLooping(true)
          ..play();
        setState(() {});
      }
    }
  }

  void handleSkillSelection() async {
    showDialog(
      context: context,
      builder: (_) => Skillsselection(
        onselect: (skills) => setState(() => selectedSkills = skills),
        selectedSkills: selectedSkills,
      ),
    );
  }

  void handlePublish() {
    final isValid = formkey.currentState!.validate();
    if (!isValid) return;

    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add Skills required')),
      );
      return;
    }

    final postData = {
      'description': descriptioncontroller.text,
      'github': githubcontroller.text,
      'skills': selectedSkills,
      'file': pickedFile,
    };

    descriptioncontroller.clear();
    githubcontroller.clear();
    selectedSkills.clear();
    pickedFile = null;
    fileBytes = null;

    Navigator.pop(context, postData);
  }

  @override
  void dispose() {
    descriptioncontroller.dispose();
    githubcontroller.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      width: MediaQuery.sizeOf(context).width * 0.55,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20,
                        )),
                    Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFF876FE8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: GestureDetector(
                        onTap: () {
                          handlePublish();
                        },
                        child: Center(
                            child: Text(
                          'Publish',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: seedcolor),
                        )),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 15,
                ),

                /// Description
                Text('Description', style: GoogleFonts.poppins(fontSize: 18)),
                TextFormField(
                  controller: descriptioncontroller,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Share your thoughts...'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please give description for post'
                      : null,
                ),

                const SizedBox(height: 16),

                /// GitHub
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextFormField(
                      controller: githubcontroller,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.commit),
                        border: InputBorder.none,
                        hintText: 'Github',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please provide github for project'
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24), // <-- fixed gap before buttons

                /// File Buttons (web style)
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => pickFile(isImage: true),
                      icon: const Icon(Icons.photo),
                      label: const Text("Select Image"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => pickFile(isImage: false),
                      icon: const Icon(Icons.videocam),
                      label: const Text("Select Video"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Select Skill Button
                    OutlinedButton.icon(
                      onPressed: handleSkillSelection,
                      icon: const Icon(Icons.add),
                      label: const Text("Select Skill"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),

                /// File Preview
                if (fileBytes != null)
                  Stack(
                    children: [
                      Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (pickedFile != null &&
                                      pickedFile!.extension == "mp4") {
                                    pickFile(isImage: false);
                                  } else {
                                    pickFile(isImage: true);
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF876FE8).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Icon(
                                      Icons.edit,
                                      color: seedcolor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (pickedFile != null) {
                                    setState(() {
                                      fileBytes = null;
                                      pickedFile = null;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF876FE8).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Icon(
                                      Icons.close_sharp,
                                      color: seedcolor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 60),
                          child: SizedBox(
                            height: 350,
                            width: MediaQuery.of(context).size.width,
                            child: pickedFile!.extension == "mp4"
                                ? AspectRatio(
                                    aspectRatio: videoPlayerController!
                                        .value.aspectRatio,
                                    child: VideoPlayer(videoPlayerController!),
                                  )
                                : Image.memory(fileBytes!, fit: BoxFit.cover),
                          )),
                    ],
                  ),
                const SizedBox(height: 24),

                /// Skill Chips
                if (selectedSkills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF876FE8).withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(skill.skill!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(
                                    () => selectedSkills.remove(skill)),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
