// ===== AUTH PROVIDER - AUTENTIKASI PENGGUNA =====

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider untuk menangani autentikasi pengguna (Firebase Auth - P04)
/// Menggunakan `Stream<User?>` authStateChanges() dan ChangeNotifier
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _initAuthStateListener();
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get uid => _user?.uid ?? '';
  String get email => _user?.email ?? '';

  /// Inisialisasi Auth State Listener menggunakan `Stream<User?>`
  void _initAuthStateListener() {
    _authSubscription = _auth.authStateChanges().listen(
      (User? user) {
        _user = user;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Kesalahan pada stream autentikasi: $error';
        notifyListeners();
      },
    );
  }

  /// Membersihkan subscription saat provider dilepas
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Menghapus pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// LOGIN PENGGUNA
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem saat login: $e';
      notifyListeners();
      return false;
    }
  }

  /// REGISTRASI PENGGUNA BARU
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem saat registrasi: $e';
      notifyListeners();
      return false;
    }
  }

  /// LOGOUT PENGGUNA
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = 'Gagal keluar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menerjemahkan kode error Firebase Auth ke Bahasa Indonesia yang ramah pengguna
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun dengan email tersebut tidak ditemukan.';
      case 'wrong-password':
        return 'Kata sandi yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format alamat email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'user-disabled':
        return 'Akun pengguna ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan coba beberapa saat lagi.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi (${e.code}).';
    }
  }
}
