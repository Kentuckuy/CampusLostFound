// ===== API LIST SCREEN - DAFTAR PRODUK REST API =====

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/api_provider.dart';
import '../utils/view_state.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'api_detail_screen.dart';

/// Halaman Daftar Produk dari REST API Publik (DummyJSON) menggunakan Dio (P02 / P03)
/// Menampilkan penanganan ViewState: loading, loaded, error, empty
class ApiListScreen extends StatefulWidget {
  const ApiListScreen({super.key});

  @override
  State<ApiListScreen> createState() => _ApiListScreenState();
}

class _ApiListScreenState extends State<ApiListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.watch<ApiProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Referensi (REST API)'),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => apiProvider.fetchProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Penjelasan Materi UTS P02
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blue.withAlpha(20),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data di bawah diambil secara asinkron (Future) dari https://dummyjson.com/products via HTTP Client Dio.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),

          // Kolom Pencarian Produk
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) => apiProvider.searchProducts(val),
              decoration: InputDecoration(
                hintText: 'Cari referensi barang (misal: phone, laptop)...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  onPressed: () =>
                      apiProvider.searchProducts(_searchController.text),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                filled: true,
                fillColor: Colors.grey.withAlpha(25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tampilan Konten Berdasarkan ViewState
          Expanded(
            child: Builder(
              builder: (context) {
                switch (apiProvider.state) {
                  case ViewState.loading:
                    return const LoadingView(
                      message: 'Mengambil produk dari DummyJSON via Dio...',
                    );

                  case ViewState.error:
                    return ErrorView(
                      errorMessage:
                          apiProvider.errorMessage ??
                          'Gagal mengambil data produk dari server DummyJSON.',
                      onRetry: () => apiProvider.retry(),
                    );

                  case ViewState.empty:
                    return EmptyView(
                      title: 'Produk Tidak Ditemukan',
                      message: 'Tidak ada produk referensi yang sesuai dengan kata kunci pencarian.',
                      icon: Icons.inventory_2_outlined,
                      actionLabel: 'Muat Semua Produk',
                      onAction: () {
                        _searchController.clear();
                        apiProvider.fetchProducts();
                      },
                    );

                  case ViewState.loaded:
                  case ViewState.initial:
                    final products = apiProvider.products;
                    return RefreshIndicator(
                      onRefresh: () => apiProvider.fetchProducts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1.5,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: product.thumbnail.isNotEmpty
                                      ? Image.network(
                                          product.thumbnail,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image_outlined,
                                                    color: Colors.grey,
                                                  ),
                                        )
                                      : const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                ),
                              ),
                              title: Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${product.rating}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApiDetailScreen(
                                      productId: product.id,
                                      productTitle: product.title,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
