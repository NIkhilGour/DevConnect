import 'dart:io';

import 'package:devconnect/core/colors.dart';
import 'package:devconnect/tabs/apiServices/publishpost.dart';
import 'package:devconnect/tabs/model/skill.dart';
import 'package:devconnect/tabs/widgets/skillsslection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class Addpost extends StatefulWidget {
  const Addpost({
    super.key,
  });

  @override
  State<Addpost> createState() => _AddpostState();
}

class _AddpostState extends State<Addpost> {
  final TextEditingController descriptioncontroller = TextEditingController();
  final TextEditingController githubcontroller = TextEditingController();
  VideoPlayerController? videoPlayerController;
  List<Skill> selectedSkills = [];
  File? imagefile;
  File? videofile;
  final formkey = GlobalKey<FormState>();
  PlatformFile? pickedFile;
  Uint8List? fileBytes;
  @override
  Widget build(BuildContext context) {
    Future<void> pickimage() async {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (videofile != null) {
          setState(() {
            videofile = null;
            imagefile = File(image.path);
          });
        } else {
          setState(() {
            imagefile = File(image.path);
          });
        }
      }
    }

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
        }

        setState(() {
          pickedFile = file;
          fileBytes = file.bytes;
        });

        if (!isImage) {
          print("load video");
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

    Future<void> pickvideo() async {
      final video = await ImagePicker().pickVideo(source: ImageSource.gallery);

      if (video != null) {
        if (imagefile != null) {
          imagefile = null;
        }
        videofile = File(video.path);
        videoPlayerController = VideoPlayerController.file(videofile!);
        await videoPlayerController!.initialize();
        setState(() {});
        videoPlayerController!.setLooping(true);
        videoPlayerController!.play();
      }
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

      Navigator.pop(context, {
        'description': descriptioncontroller.text,
        'github': githubcontroller.text,
        'skills': selectedSkills,
        'file': imagefile ?? videofile,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.r),
            child: Container(
              height: 40.h,
              width: 80.w,
              decoration: BoxDecoration(
                  color: Color(0xFF876FE8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: GestureDetector(
                onTap: () {
                  handlePublish();
                },
                child: Center(
                    child: Text(
                  'Publish',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: seedcolor),
                )),
              ),
            ),
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(fontSize: 18.sp),
                  ),
                  TextFormField(
                    controller: descriptioncontroller,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Share your thoughts...'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please give description for post';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: TextFormField(
                        controller: githubcontroller,
                        maxLines: 1,
                        decoration: InputDecoration(
                            icon: Icon(Icons.commit),
                            hintStyle: TextStyle(fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            hintText: 'Github'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide github for project';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  if (!kIsWeb && (imagefile != null || videofile != null))
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
                                    if (imagefile != null) {
                                      pickimage();
                                    } else {
                                      pickvideo();
                                    }
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFF876FE8).withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.r)),
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
                                    if (imagefile != null) {
                                      imagefile = null;
                                    } else {
                                      videofile = null;
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFF876FE8).withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.r)),
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
                          padding:
                              EdgeInsets.only(left: 8.w, right: 8.w, top: 60.h),
                          child: SizedBox(
                              height: 350,
                              width: MediaQuery.of(context).size.width,
                              child: imagefile != null
                                  ? Image.file(
                                      imagefile!,
                                      fit: BoxFit.cover,
                                    )
                                  : AspectRatio(
                                      aspectRatio: videoPlayerController!
                                          .value.aspectRatio,
                                      child:
                                          VideoPlayer(videoPlayerController!),
                                    )),
                        ),
                      ],
                    ),
                  if (kIsWeb && pickedFile != null)
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
                                    if (pickedFile!.extension == "mp4") {
                                      pickFile(isImage: false);
                                    } else {
                                      pickFile(isImage: true);
                                    }
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFF876FE8).withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.r)),
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
                                      pickedFile = null;
                                      fileBytes = null;
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFF876FE8).withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.r)),
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
                          padding:
                              EdgeInsets.only(left: 8.w, right: 8.w, top: 60.h),
                          child: SizedBox(
                              height: 350,
                              width: MediaQuery.of(context).size.width,
                              child: pickedFile!.extension == "mp4"
                                  ? AspectRatio(
                                      aspectRatio: videoPlayerController!
                                          .value.aspectRatio,
                                      child:
                                          VideoPlayer(videoPlayerController!),
                                    )
                                  : Image.memory(fileBytes!)),
                        ),
                      ],
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: List.generate(selectedSkills.length, (index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: const Color(0xFF876FE8).withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedSkills[index].skill!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSkills.removeAt(index);
                                  });
                                },
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: const Color(0xFF876FE8).withOpacity(0.1),
          ),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        if (!kIsWeb) {
                          pickimage();
                        } else {
                          pickFile(isImage: true);
                        }
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        size: 35.r,
                      )),
                  IconButton(
                      onPressed: () {
                        if (kIsWeb) {
                          pickFile(isImage: false);
                        } else {
                          pickvideo();
                        }
                      },
                      icon: Icon(
                        Icons.video_collection_outlined,
                        size: 35.r,
                      )),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Skillsselection(
                        onselect: (p0) {
                          setState(() {
                            selectedSkills = p0;
                          });
                        },
                        selectedSkills: selectedSkills,
                      );
                    },
                  );
                },
                child: Text(
                  'Select skills',
                  style: TextStyle(fontSize: 16.sp, color: seedcolor),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
