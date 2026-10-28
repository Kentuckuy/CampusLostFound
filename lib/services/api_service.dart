// ===== API SERVICE - REQUEST DUMMYJSON DENGAN DIO =====

import 'package:dio/dio.dart';

import '../models/product_model.dart';

/// Service untuk menangani HTTP Request ke REST API publik (DummyJSON) menggunakan Dio
/// Sesuai materi P02 REST API Dio
class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://dummyjson.com';

  ApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  /// READ LIST: Mengambil daftar produk dari endpoint /products
  /// Operasi Future nyata (P01 & P02)
  Future<List<ProductModel>> getProducts({int limit = 30, int skip = 0}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final List<dynamic> productsJson =
            data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map(
              (item) =>
                  ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'Gagal mengambil data produk: Status code ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Kesalahan tak terduga saat memuat produk: $e');
    }
  }

  /// READ DETAIL: Mengambil detail satu produk dari endpoint /products/{id}
  Future<ProductModel> getProductDetail(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return ProductModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'Gagal mengambil detail produk ID $id: Status ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Kesalahan tak terduga saat memuat detail produk: $e');
    }
  }

  /// SEARCH: Mencari produk berdasarkan kata kunci
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final List<dynamic> productsJson =
            data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map(
              (item) =>
                  ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Gagal mencari produk dengan kata kunci "$query"',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Kesalahan tak terduga saat pencarian produk: $e');
    }
  }
}
