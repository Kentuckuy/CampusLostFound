// ===== FIRESTORE SERVICE - CRUD LAPORAN =====

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_model.dart';

/// Service untuk menangani operasi CRUD pada Cloud Firestore
/// Koleksi data utama: 'reports'
/// Menggunakan CollectionReference secara eksplisit sesuai spesifikasi wajib UTS
class FirestoreService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _reportsRef;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    // Definisi CollectionReference secara eksplisit
    _reportsRef = _firestore.collection('reports');
  }

  /// Getter untuk CollectionReference
  CollectionReference<Map<String, dynamic>> get reportsRef => _reportsRef;

  /// CREATE: Menambahkan laporan baru ke koleksi 'reports'
  /// Menggunakan Future (Async P01)
  Future<String> addReport(ReportModel report) async {
    final docRef = await _reportsRef.add(report.toMap());
    return docRef.id;
  }

  /// READ STREAM: Mengambil stream real-time data laporan
  /// Menggunakan `Stream<QuerySnapshot>` (Async P01)
  /// Catatan UTS P05: Tanpa orderBy di Firestore agar tidak butuh composite index,
  /// pengurutan dilakukan di sisi client (Dart).
  Stream<List<ReportModel>> getReportsStream() {
    return _reportsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// READ ONCE (FUTURE): Mengambil seluruh data laporan sekali saja
  /// Memenuhi syarat penggunaan Future get() nyata
  Future<List<ReportModel>> getReportsOnce() async {
    final snapshot = await _reportsRef.get();
    return snapshot.docs.map((doc) {
      return ReportModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// READ BY ID: Mengambil detail laporan berdasarkan ID dokumen
  Future<ReportModel?> getReportById(String docId) async {
    final doc = await _reportsRef.doc(docId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ReportModel.fromMap(doc.data()!, doc.id);
  }

  /// UPDATE: Memperbarui data laporan yang ada
  /// Field updatedAt diperbarui dengan Timestamp.now()
  Future<void> updateReport(ReportModel report) async {
    if (report.id == null || report.id!.isEmpty) {
      throw ArgumentError('ID laporan tidak boleh kosong saat update');
    }
    final data = report.toMap();
    data['updatedAt'] = Timestamp.now();
    await _reportsRef.doc(report.id).update(data);
  }

  /// DELETE: Menghapus dokumen laporan berdasarkan ID
  Future<void> deleteReport(String docId) async {
    if (docId.isEmpty) {
      throw ArgumentError('ID laporan tidak boleh kosong saat delete');
    }
    await _reportsRef.doc(docId).delete();
  }
}
