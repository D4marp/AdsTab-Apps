import 'package:cloud_firestore/cloud_firestore.dart';

class AdModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final String displayFormat;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int impressions;
  final int clicks;
  final String targetAudience;
  final String budget;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? contactEmail;
  final String? contactPhone;
  final String? companyName;
  final String status;

  AdModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.displayFormat,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.impressions,
    required this.clicks,
    required this.targetAudience,
    required this.budget,
    required this.createdAt,
    this.updatedAt,
    this.contactEmail,
    this.contactPhone,
    this.companyName,
    required this.status,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      displayFormat: json['displayFormat'] ?? 'tab',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(json['startDate'] ?? 0),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(json['endDate'] ?? 0),
      isActive: json['isActive'] ?? false,
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      targetAudience: json['targetAudience'] ?? 'General',
      budget: json['budget'] ?? '0',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      companyName: json['companyName'],
      status: json['status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'imageUrls': imageUrls,
      'displayFormat': displayFormat,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'impressions': impressions,
      'clicks': clicks,
      'targetAudience': targetAudience,
      'budget': budget,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'companyName': companyName,
      'status': status,
    };
  }

  AdModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    List<String>? imageUrls,
    String? displayFormat,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? impressions,
    int? clicks,
    String? targetAudience,
    String? budget,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactEmail,
    String? contactPhone,
    String? companyName,
    String? status,
  }) {
    return AdModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      displayFormat: displayFormat ?? this.displayFormat,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      targetAudience: targetAudience ?? this.targetAudience,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
    );
  }
}
