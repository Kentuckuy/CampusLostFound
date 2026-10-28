// ===== REPORT FORM SCREEN - TAMBAH & EDIT LAPORAN =====

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_model.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';

/// Halaman formulir untuk Menambah (Create) atau Mengubah (Update) Laporan
class ReportFormScreen extends StatefulWidget {
  final ReportModel? report; // Jika null -> mode Tambah, jika ada -> mode Edit

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;

  late String _selectedType;
  late String _selectedCategory;
  late String _selectedStatus;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'KTM & Kartu Identitas',
    'Elektronik & Gadget',
    'Kunci & Aksesoris',
    'Tas, Dompet & Uang',
    'Buku & Alat Tulis',
    'Pakaian & Sepatu',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _locationController = TextEditingController(text: r?.location ?? '');
    _contactController = TextEditingController(text: r?.contactInfo ?? '');

    _selectedType = r?.type ?? 'lost';
    _selectedCategory = _categories.contains(r?.category)
        ? r!.category
        : _categories.first;
    _selectedStatus = r?.status ?? (_selectedType == 'lost' ? 'lost' : 'found');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.report != null;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (authProvider.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = false;
    if (_isEditMode) {
      final updated = widget.report!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        location: _locationController.text.trim(),
        contactInfo: _contactController.text.trim(),
        status: _selectedStatus,
        updatedAt: Timestamp.now(),
      );
      success = await reportProvider.updateReport(updated);
    } else {
      final newReport = ReportModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        location: _locationController.text.trim(),
        contactInfo: _contactController.text.trim().isNotEmpty
            ? _contactController.text.trim()
            : authProvider.email,
        ownerEmail: authProvider.email,
        status: _selectedStatus,
        ownerId: authProvider.uid,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      success = await reportProvider.addReport(newReport);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Laporan berhasil diperbarui'
                  : 'Laporan berhasil dipublikasikan',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reportProvider.errorMessage ?? 'Gagal menyimpan laporan',
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Laporan' : 'Buat Laporan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Button: Tipe Laporan
              const Text(
                'Tipe Laporan *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'lost',
                    label: Text('Barang Hilang'),
                    icon: Icon(Icons.search_rounded),
                  ),
                  ButtonSegment(
                    value: 'found',
                    label: Text('Barang Ditemukan'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    if (!_isEditMode) {
                      _selectedStatus = _selectedType == 'lost'
                          ? 'lost'
                          : 'found';
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Judul Laporan
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Judul Barang / Laporan *',
                  hintText: 'Contoh: Dompet Cokelat Eiger / KTM Ilkom',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul laporan wajib diisi';
                  }
                  if (val.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori Barang *',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              // Lokasi
              TextFormField(
                controller: _locationController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Lokasi Terakhir / Ditemukan *',
                  hintText: 'Contoh: Kantin Gedung B / Ruang Kelas 302',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lokasi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kontak Pelapor
              TextFormField(
                controller: _contactController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Kontak / No. WhatsApp Pelapor',
                  hintText: 'Contoh: WA 0812-xxxx-xxxx / IG: @nama',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  helperText: 'Agar penemu/pemilik barang bisa menghubungi Anda langsung',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Dropdown (Jika Edit Mode atau Opsional)
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status Terkini Laporan *',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'lost',
                    child: Text('Hilang (Belum Ditemukan)'),
                  ),
                  DropdownMenuItem(value: 'found', child: Text('Ditemukan')),
                  DropdownMenuItem(
                    value: 'returned',
                    child: Text('Selesai / Sudah Dikembalikan'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Rinci *',
                  hintText: 'Jelaskan ciri-ciri khusus barang, warna, stiker, isi, atau kontak darurat.',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 50.0),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isEditMode ? Icons.check_circle : Icons.save_rounded,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Menyimpan...'
                      : (_isEditMode ? 'Simpan Perubahan' : 'Kirim Laporan'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
