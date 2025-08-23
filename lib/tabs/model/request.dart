import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/userdetails.dart';

class Request {
  int? id;
  UserProfile? user;
  Post? post;
  String? status;

  Request({this.id, this.user, this.post, this.status});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (post != null) {
      data['post'] = post!.toJson();
    }
    data['status'] = status;
    return data;
  }
}
