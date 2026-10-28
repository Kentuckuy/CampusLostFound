// ===== HOME SCREEN - DASHBOARD CRUD LAPORAN =====

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../utils/view_state.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/report_card.dart';
import 'api_list_screen.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

/// Halaman Dashboard Utama: Menampilkan Daftar Laporan Barang Hilang & Ditemukan (CRUD Firestore)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () {
              Navigator.pop(ctx);
              authProvider.logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Lost & Found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              authProvider.email.isNotEmpty ? authProvider.email : 'Mahasiswa',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Navigasi ke REST API DummyJSON
          IconButton(
            tooltip: 'Katalog Produk (REST API)',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApiListScreen()),
              );
            },
          ),
          // Tombol Logout
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, authProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bar Pencarian & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  onChanged: (val) => reportProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari barang, lokasi, atau kategori...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              reportProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.withAlpha(25),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Pilihan Tab Filter Tipe: Semua, Kehilangan, Ditemukan
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Semua Laporan',
                        isSelected: reportProvider.selectedTypeFilter == 'all',
                        onSelected: () => reportProvider.setTypeFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: '🔍 Kehilangan (Lost)',
                        isSelected: reportProvider.selectedTypeFilter == 'lost',
                        onSelected: () => reportProvider.setTypeFilter('lost'),
                        selectedColor: Colors.redAccent.withAlpha(40),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: '✓ Ditemukan (Found)',
                        isSelected:
                            reportProvider.selectedTypeFilter == 'found',
                        onSelected: () => reportProvider.setTypeFilter('found'),
                        selectedColor: Colors.teal.withAlpha(40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tampilan Daftar Berdasarkan ViewState (Pola Wajib UTS)
          Expanded(
            child: Builder(
              builder: (context) {
                switch (reportProvider.state) {
                  case ViewState.loading:
                    return const LoadingView(
                      message: 'Menghubungkan ke Cloud Firestore...',
                    );

                  case ViewState.error:
                    return ErrorView(
                      errorMessage:
                          reportProvider.errorMessage ??
                          'Terjadi kendala saat memuat laporan dari Firestore.',
                      onRetry: () => reportProvider.initReportsStream(),
                    );

                  case ViewState.empty:
                    return EmptyView(
                      title: 'Belum Ada Laporan',
                      message: 'Belum ada laporan barang hilang atau ditemukan di kampus. Jadilah yang pertama melapor!',
                      icon: Icons.search_off_rounded,
                      actionLabel: 'Buat Laporan Baru',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportFormScreen(),
                          ),
                        );
                      },
                    );

                  case ViewState.loaded:
                  case ViewState.initial:
                    final reports = reportProvider.filteredReports;
                    if (reports.isEmpty) {
                      return const EmptyView(
                        title: 'Tidak Ditemukan',
                        message: 'Tidak ada laporan yang sesuai dengan filter atau kata kunci pencarian Anda.',
                        icon: Icons.filter_alt_off_outlined,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await reportProvider.fetchReportsOnce();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ReportCard(
                            report: report,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReportDetailScreen(report: report),
                                ),
                              );
                            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportFormScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? selectedColor,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: selectedColor,
    );
  }
}
