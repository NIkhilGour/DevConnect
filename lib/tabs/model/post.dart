import 'package:devconnect/tabs/model/group.dart';
import 'package:devconnect/tabs/model/like.dart';
import 'package:devconnect/tabs/model/user.dart';
import 'package:devconnect/tabs/model/userdetails.dart';

class Post {
  int? id;
  String? description;
  String? content;
  String? fileUrl;
  String? fileType;
  String? github;
  UserProfile? userProfile;
  int? likecout;
  List<Like>? likes;
  int? commentcount;
  List<Comments>? comments;
  List<TechSkills>? techSkills;
  String? isconnected;
  Group? group;

  Post(
      {this.id,
      this.description,
      this.content,
      this.fileUrl,
      this.fileType,
      this.github,
      this.userProfile,
      this.likecout,
      this.likes,
      this.commentcount,
      this.comments,
      this.techSkills,
      this.isconnected,
      this.group});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    content = json['content'];
    fileUrl = json['fileUrl'];
    fileType = json['fileType'];
    github = json['github'];
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
    likecout = json['likecout'];
    if (json['likes'] != null) {
      likes = <Like>[].cast<Like>();
      json['likes'].forEach((v) {
        likes!.add(Like.fromJson(v));
      });
    }
    commentcount = json['commentcount'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
    if (json['techSkills'] != null) {
      techSkills = <TechSkills>[];
      json['techSkills'].forEach((v) {
        techSkills!.add(TechSkills.fromJson(v));
      });
    }
    isconnected = json['isUserConnected'];
    if (json['group'] != null) group = Group.fromJson(json['group']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['content'] = content;
    data['fileUrl'] = fileUrl;
    data['fileType'] = fileType;
    data['github'] = github;
    data['isConnected'] = isconnected;
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    data['likecout'] = likecout;
    if (likes != null) {
      data['likes'] = likes!.map((v) => v.toJson()).toList();
    }
    data['commentcount'] = commentcount;
    if (comments != null) {
      data['comments'] = comments!.map((v) => v.toJson()).toList();
    }
    if (techSkills != null) {
      data['techSkills'] = techSkills!.map((v) => v.toJson()).toList();
    }
    if (group != null) {
      data['group'] = group!.toJson();
    }
    return data;
  }

  Post copyWith(
      {int? id,
      String? description,
      String? content,
      String? fileUrl,
      String? fileType,
      String? github,
      User? userProfile,
      int? likecout,
      List<Like>? likes,
      int? commentcount,
      List<dynamic>? comments,
      List<String>? techSkills,
      String? isconnected,
      Group? group}) {
    return Post(
        id: id ?? this.id,
        description: description ?? this.description,
        content: content ?? this.content,
        fileUrl: fileUrl ?? this.fileUrl,
        fileType: fileType ?? this.fileType,
        github: github ?? this.github,
        userProfile: this.userProfile,
        likecout: likecout ?? this.likecout,
        likes: likes ?? this.likes,
        commentcount: commentcount ?? this.commentcount,
        comments: this.comments,
        techSkills: this.techSkills,
        isconnected: isconnected ?? this.isconnected,
        group: group ?? this.group);
  }
}

class TechSkills {
  int? id;
  String? skill;

  TechSkills({this.id, this.skill});

  TechSkills.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    skill = json['skill'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['skill'] = skill;
    return data;
  }
}

class Comments {
  int? id;
  String? content;
  Post? post;
  User? user;

  Comments({this.id, this.content, this.post, this.user});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['content'] = content;
    if (post != null) {
      data['post'] = post!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
