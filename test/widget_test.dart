// ===== WIDGET TEST - PENGUJIAN KOMPONEN UI =====

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_lost_found/widgets/loading_view.dart';
import 'package:campus_lost_found/widgets/error_view.dart';
import 'package:campus_lost_found/widgets/empty_view.dart';

void main() {
  group('UI ViewState Widgets Test', () {
    testWidgets('LoadingView menampilkan indikator dan pesan secara benar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(message: 'Sedang memuat data laporan...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sedang memuat data laporan...'), findsOneWidget);
    });

    testWidgets('ErrorView menampilkan pesan error dan tombol coba lagi', (
      WidgetTester tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              errorMessage: 'Gagal terhubung ke database',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Gagal terhubung ke database'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('EmptyView menampilkan judul, deskripsi, dan tombol aksi', (
      WidgetTester tester,
    ) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 'Belum Ada Laporan',
              message: 'Silakan laporkan barang hilang.',
              actionLabel: 'Buat Laporan Baru',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Laporan'), findsOneWidget);
      expect(find.text('Silakan laporkan barang hilang.'), findsOneWidget);
      expect(find.text('Buat Laporan Baru'), findsOneWidget);

      await tester.tap(find.text('Buat Laporan Baru'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });
  });
}
