// ===== REPORT MODEL - MODEL DATA LAPORAN =====

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data laporan barang hilang / ditemukan (Lost & Found)
/// Terintegrasi dengan Cloud Firestore menggunakan CollectionReference 'reports'
class ReportModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String type; // 'lost' atau 'found'
  final String location;
  final String status; // 'lost', 'found', atau 'returned'
  final String ownerId;
  final String ownerEmail;
  final String contactInfo; // No. WhatsApp / Kontak darurat
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ReportModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.status,
    required this.ownerId,
    this.ownerEmail = '',
    this.contactInfo = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory untuk memetakan DocumentSnapshot / Map Firestore ke objek ReportModel
  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      type: map['type'] as String? ?? 'lost',
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? 'lost',
      ownerId: map['ownerId'] as String? ?? '',
      ownerEmail: map['ownerEmail'] as String? ?? '',
      contactInfo: map['contactInfo'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? map['updatedAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  /// Factory langsung dari Firestore DocumentSnapshot
  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ReportModel.fromMap(data, snapshot.id);
  }

  /// Konversi objek ReportModel ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'location': location,
      'status': status,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'contactInfo': contactInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Salin objek dengan perubahan nilai tertentu
  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? location,
    String? status,
    String? ownerId,
    String? ownerEmail,
    String? contactInfo,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
