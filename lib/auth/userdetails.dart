import 'dart:io';
import 'dart:typed_data';

import 'package:devconnect/auth/apiServices/getskills.dart';
import 'package:devconnect/auth/apiServices/userdetailsApi.dart';
import 'package:devconnect/auth/model/skill.dart';
import 'package:devconnect/auth/widgets/skillsselection.dart';
import 'package:devconnect/auth/widgets/textfield_widget.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/tabs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Userdetails extends StatefulWidget {
  const Userdetails({super.key, required this.token});
  final String token;

  @override
  State<Userdetails> createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController phonenumbercontroller = TextEditingController();
  final TextEditingController biocontroller = TextEditingController();
  final TextEditingController locationcontroller = TextEditingController();

  String? dropdownvalue;

  List<Skill> selectedSkills = [];
  List<Skill> allSkills = [];
  DateTime? dob;
  File? image;
  Uint8List? imagefileBytes;
  bool isloading = false;

  @override
  void initState() {
    fetchSkills(widget.token);
    super.initState();
  }

  void fetchSkills(String token) async {
    final List<Skill>? result = await getAllSkills(token);
    if (result == null) return;
    setState(() {
      allSkills = result;
    });
  }

  void pickimage(bool isweb) async {
    if (isweb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        final file = result.files.first;
        setState(() {
          imagefileBytes = file.bytes;
        });
      }

      return;
    }
    XFile? pickedimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedimage != null) {
      setState(() async {
        image = File(pickedimage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    Widget userDetailswidget = Scaffold(
      backgroundColor: backgroundcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: isMobile ? 30.h : 30),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        height: isMobile ? 100.h : 100,
                        width: isMobile ? 100.w : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                        child: image != null
                            ? ClipOval(
                                child: Image.file(image!, fit: BoxFit.cover))
                            : imagefileBytes != null
                                ? ClipOval(child: Image.memory(imagefileBytes!))
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: isMobile ? 18.r : 18,
                          child: IconButton(
                            icon: Icon(Icons.edit,
                                size: isMobile ? 18.r : 18,
                                color: Colors.black),
                            onPressed: () {
                              kIsWeb ? pickimage(true) : pickimage(false);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20.h : 20),
                TextfieldWidget(
                  title: 'Username',
                  subtitle: 'Enter your name',
                  controller: usernamecontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username cannot be empty';
                    }
                    return null;
                  },
                ),
                TextfieldWidget(
                  title: 'Bio',
                  subtitle: 'Tell about yourself',
                  controller: biocontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bio cannot be empty';
                    }
                    return null;
                  },
                ),
                TextfieldWidget(
                  title: 'Phone',
                  subtitle: 'Enter your phone number',
                  controller: phonenumbercontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    return null;
                  },
                ),
                TextfieldWidget(
                  title: 'Location',
                  subtitle: 'Enter your location',
                  controller: locationcontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isMobile ? 10.h : 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        DateTime? pickeddate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                        );
                        if (pickeddate != null) {
                          setState(() {
                            dob = pickeddate;
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_month),
                      label: Text(
                        'Date of birth',
                        style: TextStyle(color: seedcolor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20.w : 20,
                            vertical: isMobile ? 12.h : 12),
                      ),
                    ),
                    Container(
                      height: isMobile ? 40.h : 40,
                      width: isMobile ? 150.w : 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: dob != null
                            ? Text(
                                dob.toString().substring(0, 10),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Select DOB',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: isMobile ? 10.h : 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gender",
                    style: TextStyle(
                        fontSize: isMobile ? 14.sp : 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: isMobile ? 8.h : 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: isMobile ? 170.w : 170,
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.w : 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(isMobile ? 10.r : 10),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        initialValue: dropdownvalue,
                        hint: Text("Select your gender"),
                        items: ['Male', 'Female', 'Prefer not to say']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            dropdownvalue = value;
                          });
                        },
                        icon: Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: isMobile ? 14.sp : 14),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select gender';
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isMobile ? 12.r : 12),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 40.w : 40,
                            vertical: isMobile ? 12.h : 12),
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
                              allSkills: allSkills,
                              selectedSkills: selectedSkills,
                            );
                          },
                        );
                      },
                      child: Text(
                        'Select skills',
                        style: TextStyle(
                            fontSize: isMobile ? 16.sp : 16, color: seedcolor),
                      ),
                    )
                  ],
                ),
                SizedBox(height: isMobile ? 30.h : 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 12.r : 12),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 40.w : 40,
                        vertical: isMobile ? 12.h : 12),
                  ),
                  onPressed: () async {
                    if (image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Please select profile picture")),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      if (dob == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please select date of birth")),
                        );
                        return;
                      }
                      if (selectedSkills.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("Please select at least one skill")),
                        );
                        return;
                      }

                      setState(() {
                        isloading = true;
                      });
                      final response = await setUserDetails(userProfile: {
                        "name": usernamecontroller.text,
                        "phonenumber": phonenumbercontroller.text,
                        "gender": dropdownvalue,
                        "location": locationcontroller.text,
                        "dateofbirth": dob!.toString().substring(0, 10),
                        "bio": biocontroller.text,
                        "techSkills": selectedSkills
                      }, token: widget.token, profilePictureFile: image);

                      setState(() {
                        isloading = false;
                      });
                      if (response != null) {
                        await SharedPreferencesService.setInt(
                            'userId', response['user']['id']);
                        JWTService.addtoken(widget.token);

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Tabs()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Something went wrong")),
                        );

                        return;
                      }
                    }
                  },
                  child: isloading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Details',
                          style: TextStyle(
                              fontSize: isMobile ? 16.sp : 16,
                              color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return isMobile
        ? Center(child: userDetailswidget)
        : Scaffold(
            body: Row(
              children: [
                // ------------ LEFT PANEL (web only) ------------
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7F7FD5),
                          Color(0xFF86A8E7),
                          Color(0xFF91EAE4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(CupertinoIcons.globe,
                              color: Colors.white, size: 70),
                          SizedBox(height: 20),
                          Text(
                            'DevConnect',
                            style: GoogleFonts.redHatDisplay(
                              fontSize: 38,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Connect • Collaborate • Grow',
                            style: GoogleFonts.redHatText(
                                fontSize: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ------------- LOGIN CARD (same) --------------
                Expanded(
                  flex: 2,
                  child: Center(child: userDetailswidget),
                ),
              ],
            ),
          );
  }
}
