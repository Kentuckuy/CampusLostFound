// ===== API DETAIL SCREEN - DETAIL PRODUK REST API =====

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/api_provider.dart';
import '../utils/view_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

/// Halaman Detail Produk dari REST API DummyJSON via Dio (P02 / P03)
/// Menampilkan hasil GET /products/{id}
class ApiDetailScreen extends StatefulWidget {
  final int productId;
  final String? productTitle;

  const ApiDetailScreen({
    super.key,
    required this.productId,
    this.productTitle,
  });

  @override
  State<ApiDetailScreen> createState() => _ApiDetailScreenState();
}

class _ApiDetailScreenState extends State<ApiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiProvider>().fetchProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.watch<ApiProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productTitle ?? 'Detail Produk Referensi'),
      ),
      body: Builder(
        builder: (context) {
          switch (apiProvider.detailState) {
            case ViewState.loading:
              return const LoadingView(
                message: 'Memuat rincian produk dari DummyJSON...',
              );

            case ViewState.error:
              return ErrorView(
                errorMessage:
                    apiProvider.detailErrorMessage ??
                    'Gagal memuat detail produk.',
                onRetry: () {
                  apiProvider.fetchProductDetail(widget.productId);
                },
              );

            case ViewState.empty:
            case ViewState.initial:
              return const Center(child: Text('Data tidak tersedia'));

            case ViewState.loaded:
              final product = apiProvider.selectedProduct;
              if (product == null) {
                return const Center(child: Text('Data produk tidak ditemukan'));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Utama / Carousel
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[100],
                      child: product.thumbnail.isNotEmpty
                          ? Image.network(
                              product.thumbnail,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                            )
                          : const Icon(Icons.image_outlined, size: 64),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori & Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(
                                    30,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber[700],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating} / 5.0',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Judul Produk
                          Text(
                            product.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Brand
                          Text(
                            'Brand: ${product.brand}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Harga & Diskon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (product.discountPercentage > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(30),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Diskon ${product.discountPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stok
                          Row(
                            children: [
                              Icon(
                                product.stock > 0
                                    ? Icons.check_circle_outline
                                    : Icons.highlight_off,
                                color: product.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ketersediaan: ${product.stock} unit dalam stok',
                                style: TextStyle(
                                  color: product.stock > 0
                                      ? Colors.green[800]
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Deskripsi
                          const Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          // Galeri Foto Tambahan jika ada
                          if (product.images.isNotEmpty) ...[
                            const Text(
                              'Galeri Foto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 85,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: product.images.length,
                                itemBuilder: (context, idx) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.images[idx],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Catatan REST API Dio
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withAlpha(120),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Modul REST API (P02 & P03) bersifat read-only untuk referensi harga dan spesifikasi barang hilang/temuan.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
