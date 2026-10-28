// ===== REPORT MODEL TEST - PENGUJIAN UNIT MODEL LAPORAN =====

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_lost_found/models/report_model.dart';

void main() {
  group('ReportModel Unit Tests', () {
    final now = Timestamp.now();
    final earlier = Timestamp.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch - 10000,
    );

    final sampleMap = {
      'title': 'KTM Atma Luhur a.n. Mahasiswa',
      'description': 'Tertinggal di Lab Komputer Lantai 3',
      'category': 'KTM & Kartu Identitas',
      'type': 'lost',
      'location': 'Lab Komputer 3',
      'status': 'lost',
      'ownerId': 'user_test_uid_123',
      'createdAt': now,
      'updatedAt': now,
    };

    test('Memetakan Map Firestore ke ReportModel secara benar', () {
      final report = ReportModel.fromMap(sampleMap, 'doc_abc_123');

      expect(report.id, 'doc_abc_123');
      expect(report.title, 'KTM Atma Luhur a.n. Mahasiswa');
      expect(report.type, 'lost');
      expect(report.status, 'lost');
      expect(report.ownerId, 'user_test_uid_123');
      expect(report.createdAt, now);
    });

    test('Mengonversi ReportModel ke Map Firestore secara akurat', () {
      final report = ReportModel(
        id: 'doc_abc_123',
        title: 'Dompet Cokelat',
        description: 'Ditemukan di kantin',
        category: 'Tas, Dompet & Uang',
        type: 'found',
        location: 'Kantin Belakang',
        status: 'found',
        ownerId: 'user_456',
        createdAt: now,
        updatedAt: now,
      );

      final map = report.toMap();

      expect(map['title'], 'Dompet Cokelat');
      expect(map['type'], 'found');
      expect(map['status'], 'found');
      expect(map['ownerId'], 'user_456');
      expect(map['createdAt'], now);
    });

    test('Metode copyWith dapat memperbarui field tertentu tanpa merusak data lain', () {
      final original = ReportModel.fromMap(sampleMap, 'doc_1');
      final updated = original.copyWith(
        status: 'returned',
        title: 'KTM Telah Diambil',
      );

      expect(updated.id, 'doc_1');
      expect(updated.title, 'KTM Telah Diambil');
      expect(updated.status, 'returned');
      expect(updated.ownerId, original.ownerId);
      expect(updated.location, original.location);
    });

    test('Pengurutan data di sisi client (Dart) berfungsi menurun berdasarkan createdAt', () {
      final report1 = ReportModel.fromMap(
        sampleMap,
        'doc_1',
      ).copyWith(createdAt: earlier);
      final report2 = ReportModel.fromMap(
        sampleMap,
        'doc_2',
      ).copyWith(createdAt: now);

      final list = [report1, report2];
      // Sorting descending (terbaru di atas) sesuai aturan UTS P05
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(list.first.id, 'doc_2');
      expect(list.last.id, 'doc_1');
    });
  });
}
