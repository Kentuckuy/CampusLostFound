// ===== REPORT PROVIDER - STATE MANAJEMEN LAPORAN =====

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../utils/view_state.dart';

/// Provider untuk mengelola state laporan Firestore (P05 / P06)
/// Menerapkan pola ViewState: loading, loaded, error, empty
/// Menggunakan StreamSubscription dan membersihkannya saat dispose()
class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<List<ReportModel>>? _reportsSubscription;

  ViewState _state = ViewState.loading;
  List<ReportModel> _allReports = [];
  String? _errorMessage;

  // Filter state
  String _selectedTypeFilter = 'all'; // 'all', 'lost', 'found'
  String _selectedStatusFilter = 'all'; // 'all', 'lost', 'found', 'returned'
  String _searchQuery = '';

  ReportProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService() {
    initReportsStream();
  }

  // Getters
  ViewState get state => _state;
  List<ReportModel> get allReports => _allReports;
  String? get errorMessage => _errorMessage;
  String get selectedTypeFilter => _selectedTypeFilter;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;

  /// Daftar laporan setelah difilter dan diurutkan di sisi client (Dart)
  List<ReportModel> get filteredReports {
    return _allReports.where((report) {
      final matchesType =
          _selectedTypeFilter == 'all' ||
          report.type.toLowerCase() == _selectedTypeFilter.toLowerCase();
      final matchesStatus =
          _selectedStatusFilter == 'all' ||
          report.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          report.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesType && matchesStatus && matchesSearch;
    }).toList();
  }

  /// Inisialisasi stream laporan dari Firestore (Async P01: Stream)
  void initReportsStream() {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    _reportsSubscription?.cancel();
    _reportsSubscription = _firestoreService.getReportsStream().listen(
      (reports) {
        // Aturan UTS P05: Sorting dilakukan di sisi client (Dart)
        // Laporan terbaru ditampilkan paling atas tanpa index orderBy Firestore
        reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _allReports = reports;

        if (_allReports.isEmpty) {
          _state = ViewState.empty;
        } else {
          _state = ViewState.loaded;
        }
        notifyListeners();
      },
      onError: (error) {
        _state = ViewState.error;
        _errorMessage = 'Gagal berlangganan stream laporan: $error';
        notifyListeners();
      },
    );
  }

  /// Mengambil data sekali saja menggunakan Future (Async P01: Future)
  Future<void> fetchReportsOnce() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final reports = await _firestoreService.getReportsOnce();
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _allReports = reports;

      if (_allReports.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Gagal memuat data laporan: $e';
      notifyListeners();
    }
  }

  /// CREATE: Menambah laporan baru
  Future<bool> addReport(ReportModel report) async {
    try {
      await _firestoreService.addReport(report);
      // Stream Firestore akan otomatis memperbarui _allReports
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// UPDATE: Memperbarui laporan yang sudah ada
  Future<bool> updateReport(ReportModel report) async {
    try {
      await _firestoreService.updateReport(report);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// DELETE: Menghapus laporan berdasarkan ID
  Future<bool> deleteReport(String docId) async {
    try {
      await _firestoreService.deleteReport(docId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus laporan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Ubah filter tipe ('all', 'lost', 'found')
  void setTypeFilter(String type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  /// Ubah filter status ('all', 'lost', 'found', 'returned')
  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  /// Ubah pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Membersihkan subscription saat provider di-dispose
  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
  }
}
