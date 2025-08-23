import 'package:flutter/material.dart';

class Group {
  int? id;
  String? name;
  int? postId;
  List<int>? members;

  Group({this.id, this.name, this.postId, this.members});

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    postId = json['postId'];
    if (json['memberIds'] != null) {
      members = <int>[];
      json['memberIds'].forEach((v) {
        members!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['postId'] = postId;

    if (members != null) {
      data['memberIds'] = members!.map(
        (e) {
          e.toInt();
        },
      ).toList();
    }

    return data;
  }
}
