import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/user.dart';

class UserProfile {
  int? id;
  User? user;
  String? name;
  List<TechSkills>? techSkills;
  Null phoneNumber;
  String? profilePictureUrl;
  String? bio;
  String? dateofbirth;
  String? gender;
  String? location;

  UserProfile(
      {this.id,
      this.user,
      this.name,
      this.techSkills,
      this.phoneNumber,
      this.profilePictureUrl,
      this.bio,
      this.dateofbirth,
      this.gender,
      this.location});

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    name = json['name'];
    if (json['techSkills'] != null) {
      techSkills = <TechSkills>[];
      json['techSkills'].forEach((v) {
        techSkills!.add(TechSkills.fromJson(v));
      });
    }
    phoneNumber = json['phoneNumber'];
    profilePictureUrl = json['profilePictureUrl'];
    bio = json['bio'];
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['name'] = name;
    if (techSkills != null) {
      data['techSkills'] = techSkills!.map((v) => v.toJson()).toList();
    }
    data['phoneNumber'] = phoneNumber;
    data['profilePictureUrl'] = profilePictureUrl;
    data['bio'] = bio;
    data['dateofbirth'] = dateofbirth;
    data['gender'] = gender;
    data['location'] = location;
    return data;
  }
}
