import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/user.dart';

class Like {
  int? id;
  Post? post;
  User? user;

  Like({this.id, this.post, this.user});

  Like.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (post != null) {
      data['post'] = post!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
