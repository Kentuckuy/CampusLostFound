// ===== API PROVIDER - STATE REST API DIO =====

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/view_state.dart';

/// Provider untuk mengelola state data dari REST API DummyJSON via Dio (P02 / P03)
/// Mengimplementasikan pola ViewState: loading, loaded, error, empty
class ApiProvider extends ChangeNotifier {
  final ApiService _apiService;

  ViewState _state = ViewState.initial;
  ViewState _detailState = ViewState.initial;

  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  String? _errorMessage;
  String? _detailErrorMessage;

  ApiProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService() {
    fetchProducts();
  }

  // Getters
  ViewState get state => _state;
  ViewState get detailState => _detailState;
  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  /// FETCH LIST: Mengambil daftar produk dari REST API (Operasi Future P01 & P02)
  Future<void> fetchProducts() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getProducts();
      _products = result;

      if (_products.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
      notifyListeners();
    } on DioException catch (dioErr) {
      _state = ViewState.error;
      _errorMessage = _mapDioError(dioErr);
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Gagal memuat produk dari server: $e';
      notifyListeners();
    }
  }

  /// FETCH DETAIL: Mengambil detail produk berdasarkan ID
  Future<void> fetchProductDetail(int id) async {
    _detailState = ViewState.loading;
    _detailErrorMessage = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      final product = await _apiService.getProductDetail(id);
      _selectedProduct = product;
      _detailState = ViewState.loaded;
      notifyListeners();
    } on DioException catch (dioErr) {
      _detailState = ViewState.error;
      _detailErrorMessage = _mapDioError(dioErr);
      notifyListeners();
    } catch (e) {
      _detailState = ViewState.error;
      _detailErrorMessage = 'Gagal memuat detail produk: $e';
      notifyListeners();
    }
  }

  /// PENCARIAN PRODUK
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      fetchProducts();
      return;
    }

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.searchProducts(query.trim());
      _products = result;

      if (_products.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
      notifyListeners();
    } on DioException catch (dioErr) {
      _state = ViewState.error;
      _errorMessage = _mapDioError(dioErr);
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Gagal mencari produk: $e';
      notifyListeners();
    }
  }

  /// Operasi Retry jika terjadi error
  Future<void> retry() async {
    await fetchProducts();
  }

  /// Memetakan error Dio ke pesan yang mudah dipahami
  String _mapDioError(DioException dioErr) {
    switch (dioErr.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (timeout). Silakan periksa jaringan internet Anda.';
      case DioExceptionType.badResponse:
        final code = dioErr.response?.statusCode;
        return 'Server memberikan respons error ($code). Coba lagi nanti.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke jaringan.';
      case DioExceptionType.cancel:
        return 'Permintaan data dibatalkan.';
      default:
        return 'Terjadi masalah jaringan: ${dioErr.message ?? 'Unknown error'}';
    }
  }

  @override
  void dispose() {
    // Bersihkan resource jika ada subscription
    super.dispose();
  }
}
