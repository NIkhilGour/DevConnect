import 'package:devconnect/tabs/model/userdetails.dart';

class Comment {
  int? id;
  String? content;
  UserProfile? userProfile;

  Comment({this.id, this.content, this.userProfile});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['content'] = content;
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    return data;
  }
}
