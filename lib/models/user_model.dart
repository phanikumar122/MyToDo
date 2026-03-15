class UserModel {
  final String id;
  final String googleId;
  final String name;
  final String email;
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.googleId,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:             json['id']             as String,
        googleId:       json['google_id']      as String,
        name:           json['name']           as String,
        email:          json['email']          as String,
        profilePicture: json['profile_picture'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id':              id,
        'google_id':       googleId,
        'name':            name,
        'email':           email,
        'profile_picture': profilePicture,
        'created_at':      createdAt.toIso8601String(),
      };
}
