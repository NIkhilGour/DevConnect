import 'package:devconnect/tabs/model/userdetails.dart';

class Message {
  final int? id;
  final UserProfile? userProfile;
  final String? message;
  final DateTime? timestamp;

  Message({
    this.id,
    this.userProfile,
    this.message,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: (json['id']),
        userProfile: json['sender'] != null
            ? UserProfile.fromJson(json['sender'] as Map<String, dynamic>)
            : null,
        message: json['message'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': userProfile?.toJson(),
        'message': message,
        'timestamp': timestamp?.toIso8601String(),
      };

  Message copyWith({
    int? id,
    UserProfile? userProfile,
    String? message,
    DateTime? timestamp,
  }) =>
      Message(
        id: this.id,
        userProfile: userProfile ?? this.userProfile,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
      );
}
