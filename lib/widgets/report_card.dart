// ===== REPORT CARD - KOMPONEN KARTU LAPORAN =====

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/report_model.dart';

/// Komponen kartu untuk menampilkan satu data laporan barang hilang/ditemukan
class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLost = report.type.toLowerCase() == 'lost';
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm')
        .format(report.createdAt.toDate());

    // Warna badge tipe
    final typeColor = isLost ? Colors.redAccent : Colors.teal;
    final typeLabel = isLost ? 'KEHILANGAN' : 'DITEMUKAN';

    // Status label dan warna
    Color statusColor;
    String statusLabel;
    switch (report.status.toLowerCase()) {
      case 'returned':
        statusColor = Colors.purple;
        statusLabel = 'Selesai / Dikembalikan';
        break;
      case 'found':
        statusColor = Colors.teal;
        statusLabel = 'Telah Ditemukan';
        break;
      case 'lost':
      default:
        statusColor = Colors.orange;
        statusLabel = 'Masih Dicari';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: typeColor.withAlpha(50), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris badge: Tipe & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLost
                              ? Icons.search_rounded
                              : Icons.check_circle_outline,
                          size: 14,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Judul Laporan
              Text(
                report.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),

              // Deskripsi
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Baris info lokasi dan waktu
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.location.isNotEmpty
                          ? report.location
                          : 'Lokasi kampus',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormatted,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
