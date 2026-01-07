import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin, advertiser }

class UserModel {
  final String id;
  final String uid;  // Firebase Auth UID
  final String name;
  final String email;
  final String? profileImage;
  final String? city;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserRole role;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    this.city,
    required this.createdAt,
    this.updatedAt,
    this.role = UserRole.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      uid: json['uid'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      city: json['city'],
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      role: json['role'] == 'admin' 
          ? UserRole.admin 
          : json['role'] == 'advertiser'
          ? UserRole.advertiser
          : UserRole.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'city': city,
      'createdAt': createdAt,  // Will be converted to Timestamp by Firestore
      'updatedAt': updatedAt,
      'role': role == UserRole.admin 
          ? 'admin' 
          : role == UserRole.advertiser 
          ? 'advertiser' 
          : 'user',
    };
  }

  UserModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    String? city,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isAdvertiser => role == UserRole.advertiser;
}
