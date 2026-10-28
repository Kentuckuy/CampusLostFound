// ===== REPORT DETAIL SCREEN - DETAIL LAPORAN =====

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report_model.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import 'report_form_screen.dart';

/// Halaman Detail Laporan Barang Hilang / Ditemukan
/// Mendukung aksi Edit dan Hapus jika pengguna saat ini adalah pemilik laporan (ownerId)
class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  void _showDeleteDialog(BuildContext context, ReportProvider reportProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await reportProvider.deleteReport(report.id!);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Kembali ke Home
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        reportProvider.errorMessage ??
                            'Gagal menghapus laporan',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();

    // Periksa apakah user saat ini adalah pemilik dokumen (Owner UID)
    final isOwner =
        authProvider.uid.isNotEmpty && authProvider.uid == report.ownerId;

    final isLost = report.type.toLowerCase() == 'lost';
    final typeColor = isLost ? Colors.redAccent : Colors.teal;
    final typeText = isLost
        ? 'Barang Kehilangan (Lost)'
        : 'Barang Ditemukan (Found)';

    final createdAtFormatted = DateFormat('dd MMMM yyyy, HH:mm WIB')
        .format(report.createdAt.toDate());
    final updatedAtFormatted = DateFormat('dd MMMM yyyy, HH:mm WIB')
        .format(report.updatedAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (isOwner) ...[
            IconButton(
              tooltip: 'Edit Laporan',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportFormScreen(report: report),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Hapus Laporan',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, reportProvider),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Tipe Card Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: typeColor.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isLost
                                ? Icons.search_rounded
                                : Icons.check_circle_outline,
                            color: typeColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            typeText,
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          report.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.white.withAlpha(200),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Judul Laporan
            Text(
              report.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Informasi Utama
            _buildInfoTile(
              icon: Icons.category_outlined,
              label: 'Kategori',
              value: report.category,
            ),
            _buildInfoTile(
              icon: Icons.place_outlined,
              label: 'Lokasi Kejadian / Ditemukan',
              value: report.location,
            ),
            _buildInfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Waktu Dilaporkan',
              value: createdAtFormatted,
            ),
            _buildInfoTile(
              icon: Icons.update_outlined,
              label: 'Terakhir Diperbarui',
              value: updatedAtFormatted,
            ),
            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'ID Pelapor',
              value: isOwner ? '${report.ownerId} (Anda)' : report.ownerId,
            ),
            if (report.contactInfo.isNotEmpty)
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: 'Kontak / WhatsApp Pelapor',
                value: report.contactInfo,
              ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Deskripsi Lengkap
            const Text(
              'Deskripsi Lengkap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Aksi Khusus Pemilik: Tombol Cepat Selesai / Dikembalikan
            if (isOwner && report.status.toLowerCase() != 'returned') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final updated = report.copyWith(
                      status: 'returned',
                      updatedAt: Timestamp.now(),
                    );
                    final success = await reportProvider.updateReport(updated);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Status diubah: Sudah Selesai / Dikembalikan',
                          ),
                          backgroundColor: Colors.purple,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(
                    Icons.task_alt_rounded,
                    color: Colors.purple,
                  ),
                  label: const Text(
                    'Tandai Sudah Selesai / Dikembalikan',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Catatan Hak Akses
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isOwner
                          ? 'Anda memiliki hak penuh untuk mengubah atau menghapus laporan ini.'
                          : 'Hanya pemilik laporan yang dapat mengedit atau menghapus laporan ini sesuai aturan Firestore Security Rules.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
