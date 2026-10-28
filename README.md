# ===== README - DOKUMENTASI LENGKAP CAMPUS LOST & FOUND =====

# Campus Lost & Found
> **Ujian Tengah Semester (UTS) — Pemrograman Multi Platform (TA5J)**  
> **Program Studi Teknologi Informasi — Fakultas Teknologi Informasi**  
> **Institut Sains dan Bisnis (ISB) Atma Luhur Pangkalpinang**  
> **Dosen Koordinator:** Rezky Yuranda, M.Kom (NIDN. 7700009427)

---

## 1. Identitas Kelompok & Pembagian Tugas (Kelompok 4 Orang)

Sesuai redaksi baku soal UTS, berikut adalah pembagian tugas 4 orang anggota kelompok:

| No | NIM | Nama Mahasiswa | Peran Baku Sesuai Soal UTS | Modul & File yang Dipegang |
|:--:|:---:|:---|:---|:---|
| 1 | **2411500025** | **Fathurrahman Safari Lubis** | **Anggota 1:** Auth + navigasi + struktur folder | `lib/main.dart`, `lib/firebase_options.dart`, `lib/providers/auth_provider.dart`, `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart` |
| 2 | `[NIM Anggota 2]` | `[Nama Anggota 2]` | **Anggota 2:** Firestore CRUD + Model & Service + Security Rules | `lib/models/report_model.dart`, `lib/services/firestore_service.dart`, `firestore.rules` |
| 3 | `[NIM Anggota 3]` | `[Nama Anggota 3]` | **Anggota 3:** State Management Firestore + ViewState + Dashboard UI & Client-Side Sorting | `lib/utils/view_state.dart`, `lib/providers/report_provider.dart`, `lib/screens/home_screen.dart`, `lib/screens/report_form_screen.dart`, `lib/screens/report_detail_screen.dart`, `lib/widgets/report_card.dart` |
| 4 | `[NIM Anggota 4]` | `[Nama Anggota 4]` | **Anggota 4:** Dio REST API + loading/error/empty + Future vs Stream | `lib/models/product_model.dart`, `lib/services/api_service.dart`, `lib/providers/api_provider.dart`, `lib/screens/api_list_screen.dart`, `lib/screens/api_detail_screen.dart`, `lib/widgets/loading_view.dart`, `lib/widgets/error_view.dart`, `lib/widgets/empty_view.dart` |

> *Catatan: Nama dan NIM rekan kelompok dapat diubah atau disesuaikan secara langsung pada tabel di atas sesuai kesepakatan pembagian giliran presentasi kelompok.*

---

## 2. Deskripsi & Latar Belakang Project

**Campus Lost & Found** adalah aplikasi mobile multi-platform berbasis **Flutter**, **Firebase**, dan **REST API** yang dirancang sebagai pusat pelaporan dan pencarian barang hilang (*lost*) maupun barang temuan (*found*) di lingkungan kampus ISB Atma Luhur.

### Mengapa Aplikasi Ini Berbeda?
Project ini mengangkat tema orisinal dan **berbeda dari 8 contoh topik bawaan soal UTS** (Kas Kecil, Todo Tugas, Inventaris Warung, Perpustakaan, Agenda Kampus, Absensi, Menu Kantin, Antrean). 

Aplikasi ini mengatasi masalah nyata di mana mahasiswa seringkali kehilangan barang (KTM, dompet, kunci kendaraan, gawai, jaket) atau menemukan barang tercecer namun kesulitan mencari pemilik aslinya. Dengan aplikasi ini:
1. Mahasiswa yang kehilangan dapat membuat laporan kehilangan dengan deskripsi rinci, kategori, lokasi, serta nomor kontak/WhatsApp.
2. Mahasiswa yang menemukan barang dapat membuat laporan temuan tandingan atau mengabarkan bahwa barang telah diamankan di Pos Satpam.
3. Seluruh data laporan disinkronkan secara real-time antar-perangkat.
4. Terdapat fitur katalog referensi barang menggunakan REST API publik (*DummyJSON*) untuk membantu pengguna melihat referensi harga dan estimasi spesifikasi barang.

---

## 3. Fitur Utama & Kepatuhan Spesifikasi Wajib UTS

### A. Firebase Authentication (Materi P04)
- **Registrasi Akun:** Mahasiswa mendaftarkan diri menggunakan Email dan Password.
- **Login Akun:** Autentikasi aman melalui Firebase Authentication dengan pesan error berbahasa Indonesia (misal: password lemah, email sudah terdaftar, format salah).
- **Logout:** Fitur keluar akun dengan konfirmasi dialog.
- **Auth State Listener:** Menggunakan `Stream<User?>` dari `FirebaseAuth.instance.authStateChanges()` yang dipantau oleh `AuthWrapper` di `main.dart`.
- **Proteksi Rute:** Pengguna yang belum login otomatis diarahkan ke `LoginScreen`, dan yang sudah login diarahkan ke `HomeScreen`.

### B. Cloud Firestore CRUD (Materi P05 & P06)
- **Nama Koleksi:** `reports`.
- **Struktur Dokumen:**
  - `title` (String): Judul laporan barang.
  - `description` (String): Ciri-ciri dan rincian barang.
  - `category` (String): Kategori (KTM, Elektronik, Kunci, Tas, dll).
  - `type` (String): Tipe laporan (`lost` / `found`).
  - `location` (String): Lokasi kejadian atau tempat barang diamankan.
  - `status` (String): Status barang (`lost`, `found`, `returned`).
  - `ownerId` (String): UID mahasiswa pembuat laporan.
  - `ownerEmail` (String): Email mahasiswa pembuat laporan.
  - `contactInfo` (String): Nomor WhatsApp/kontak darurat pelapor.
  - `createdAt` (`Timestamp`): Waktu laporan dipublikasikan.
  - `updatedAt` (`Timestamp`): Waktu laporan terakhir kali diperbarui.
- **CollectionReference Eksplisit:** Didefinisikan eksplisit di `FirestoreService` (`_firestore.collection('reports')`).
- **Operasi Lengkap:**
  - `Create`: Menambahkan dokumen laporan baru (`addReport`).
  - `Read (Stream)`: Mengambil stream real-time dokumen (`snapshots()`).
  - `Read (Future)`: Mengambil seluruh dokumen sekali jalan (`getReportsOnce()`).
  - `Update`: Mengubah data laporan atau mengubah status menjadi "Selesai / Sudah Dikembalikan" (`updateReport`).
  - `Delete`: Menghapus laporan sendiri dengan dialog konfirmasi (`deleteReport`).
- **Aturan Query P05 (Sorting Client-Side):** Sesuai aturan P05, query Firestore tidak menggunakan `orderBy` agar tidak mewajibkan pembuatan composite index di Firebase Console. Pengurutan data terbaru dilakukan di sisi client Dart menggunakan `reports.sort((a, b) => b.createdAt.compareTo(a.createdAt))`.
- **Keamanan Server (Firestore Security Rules):** Hanya user login yang dapat membaca data, dan hanya pemilik laporan (`request.auth.uid == resource.data.ownerId`) yang diizinkan mengedit atau menghapus laporannya.

### C. State Management Provider & ViewState (Materi P03)
Didaftarkan rapi pada `main.dart` menggunakan `MultiProvider`:
1. `AuthProvider` — Mengelola status sesi login/register/logout.
2. `ReportProvider` — Mengelola data laporan Firestore, filter kategori/tipe, pencarian, dan sinkronisasi stream.
3. `ApiProvider` — Mengelola request HTTP Dio ke REST API DummyJSON.

Menerapkan 4 status wajib **ViewState**:
- `loading`: Menampilkan indikator loading seragam (`LoadingView`).
- `loaded`: Menampilkan data yang berhasil diambil.
- `error`: Menampilkan pesan error dan tombol coba lagi (`ErrorView` + Retry).
- `empty`: Menampilkan ilustrasi ketika belum ada laporan atau produk (`EmptyView`).
- Seluruh subscription dibersihkan secara aman saat `dispose()`.

### D. REST API Publik Menggunakan Dio (Materi P02)
- Mengakses endpoint publik:
  - Daftar Produk: `GET https://dummyjson.com/products`
  - Detail Produk: `GET https://dummyjson.com/products/{id}`
  - Pencarian: `GET https://dummyjson.com/products/search?q={query}`
- Menggunakan HTTP Client **Dio** dengan setelan `connectTimeout` (15s) dan `receiveTimeout` (15s).
- Pemetaan respons JSON ke objek Dart `ProductModel`.
- Layar Daftar Produk (`ApiListScreen`) dan Detail Produk (`ApiDetailScreen`).
- Berperan sebagai modul *read-only* referensi katalog barang.

### E. Integrasi Konsep Dart Asinkron (Materi P01)
- **Future:** Digunakan pada operasi HTTP GET Dio (`ApiService.getProducts()`) dan pengambilan Firestore sekali jalan (`FirestoreService.getReportsOnce()`).
- **Stream:** Digunakan pada pemantauan autentikasi (`authStateChanges()`) dan pembaruan dokumen real-time (`snapshots()`).

---

## 4. Struktur Arsitektur Folder

```text
campus_lost_found/
├── android/                         # Konfigurasi native platform Android
├── web/                             # Konfigurasi platform Web (Chrome)
├── windows/                         # Konfigurasi platform Windows Desktop
├── lib/
│   ├── main.dart                    # Entry point aplikasi & MultiProvider
│   ├── firebase_options.dart        # Konfigurasi resmi FlutterFire (di-commit)
│   ├── models/
│   │   ├── report_model.dart        # Model data laporan Firestore (Timestamp)
│   │   └── product_model.dart       # Model data REST API DummyJSON
│   ├── services/
│   │   ├── firestore_service.dart   # CRUD Cloud Firestore (CollectionReference)
│   │   └── api_service.dart         # HTTP Client Dio untuk DummyJSON
│   ├── providers/
│   │   ├── auth_provider.dart       # Provider autentikasi pengguna
│   │   ├── report_provider.dart     # Provider laporan Firestore & ViewState
│   │   └── api_provider.dart        # Provider REST API Dio & ViewState
│   ├── screens/
│   │   ├── login_screen.dart        # Layar Login
│   │   ├── register_screen.dart     # Layar Registrasi
│   │   ├── home_screen.dart         # Layar Dashboard CRUD & Filter Laporan
│   │   ├── report_form_screen.dart  # Layar Tambah & Edit Laporan
│   │   ├── report_detail_screen.dart# Layar Rincian Laporan & Aksi Pemilik
│   │   ├── api_list_screen.dart     # Layar Daftar Produk REST API
│   │   └── api_detail_screen.dart   # Layar Detail Produk REST API
│   ├── widgets/
│   │   ├── report_card.dart         # Komponen kartu laporan
│   │   ├── loading_view.dart        # Komponen ViewState.loading
│   │   ├── error_view.dart          # Komponen ViewState.error + retry
│   │   └── empty_view.dart          # Komponen ViewState.empty
│   └── utils/
│       └── view_state.dart          # Enum ViewState (loading, loaded, error, empty)
├── test/
│   ├── report_model_test.dart       # Unit test model data & client-side sorting
│   ├── view_state_test.dart         # Unit test enum status ViewState
│   └── widget_test.dart             # Widget test komponen UI ViewState
├── firestore.rules                  # Aturan keamanan database Cloud Firestore
├── pubspec.yaml                     # Konfigurasi dependensi project
├── analysis_options.yaml            # Aturan linting resmi Dart/Flutter
└── README.md                        # Dokumentasi utama project
```

---

## 5. Panduan Lengkap Konfigurasi Firebase (Firebase Setup)

Project ini telah dikonfigurasi menggunakan project Firebase aktif: **`campus-lost-found-70ded`**.

Bagi dosen penguji atau pengembang lain yang ingin menghubungkan aplikasi ini ke project Firebase miliknya sendiri, ikuti panduan berikut:

### Langkah A: Pembuatan Project di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/) di browser.
2. Klik **Add project**, beri nama project Anda (contoh: `campus-lost-found`), lalu ikuti panduan hingga selesai (pilih paket gratis *Spark Plan*).

### Langkah B: Mengaktifkan Firebase Authentication
1. Di menu sidebar sebelah kiri, klik **Build** > **Authentication**.
2. Klik **Get started**.
3. Di tab **Sign-in method**, pilih **Email/Password**.
4. Aktifkan switch **Email/Password** (biarkan opsi Email link nonaktif), lalu klik **Save**.

### Langkah C: Membuat Database Cloud Firestore
1. Di menu sidebar sebelah kiri, klik **Build** > **Firestore Database**.
2. Klik tombol **Create database**.
3. Pilih lokasi server (contoh: `asia-southeast2` Jakarta atau default), lalu klik **Next**.
4. Pilih opsi **Start in production mode**, lalu klik **Create**.

### Langkah D: Memasang Aturan Keamanan Database (`firestore.rules`)
1. Buka tab **Rules** pada Firestore Database di Firebase Console.
2. Salin seluruh isi dari file `firestore.rules` project ini:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /reports/{reportId} {
         // Semua user yang login dapat membaca seluruh laporan kampus
         allow read: if request.auth != null;
         
         // Pembuatan laporan hanya boleh atas nama UID user yang login
         allow create: if request.auth != null && 
                       request.resource.data.ownerId == request.auth.uid;
         
         // Update dan Delete HANYA boleh dilakukan oleh pemilik asli laporan
         allow update, delete: if request.auth != null && 
                                  resource.data.ownerId == request.auth.uid;
       }
       match /{document=**} {
         allow read, write: if false;
       }
     }
   }
   ```
3. Klik tombol **Publish**.

### Langkah E: Menjalankan FlutterFire CLI
1. Pastikan FlutterFire CLI telah aktif di komputer:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Di terminal direktori project `campus_lost_found`, jalankan:
   ```bash
   flutterfire configure
   ```
3. Pilih project Firebase Anda, lalu pilih platform target (`android, web, windows`). File `lib/firebase_options.dart` akan otomatis disinkronkan.

> **Catatan Keamanan Git (Sesuai Aturan UTS):**  
> File `lib/firebase_options.dart` **di-commit ke Git dan TIDAK dimasukkan ke `.gitignore`** agar dosen penguji dapat langsung mereview dan menjalankan project. File tersebut hanya memuat identifier client publik dan aman dibagikan karena database sepenuhnya dilindungi oleh *Firestore Security Rules* berbasis UID.

---

## 6. Panduan Menjalankan Aplikasi

### 1. Unduh Dependensi
```bash
flutter pub get
```

### 2. Jalankan Formatter, Analisis Statis, & Pengujian
```bash
dart format .
flutter analyze
flutter test
```
*(Seluruh perintah di atas terverifikasi 100% lulus tanpa error)*.

### 3. Jalankan Aplikasi
Pilih salah satu platform yang Anda inginkan:

- **Jalankan di Google Chrome (Paling Praktis & Cepat):**
  ```bash
  flutter run -d chrome
  ```
- **Jalankan di Emulator Android:**
  ```bash
  flutter emulators --launch Medium_Phone
  flutter run
  ```
- **Jalankan di Windows Desktop:**
  ```bash
  flutter run -d windows
  ```

---

## 7. Status Validasi & Pengujian Nyata

- [x] **Implementasi Kode:** 100% selesai, tanpa fungsi kosong/TODO palsu.
- [x] **Penanda Komentar Wajib:** Seluruh file source code memiliki penanda `// ===== NAMA BAGIAN =====`.
- [x] **Pemeriksaan Statis (`flutter analyze`):** `No issues found!` (0 error, 0 warning, 0 lint).
- [x] **Pengujian Otomatis (`flutter test`):** `All tests passed!` (10/10 test unit dan widget berhasil).
- [x] **Kepatuhan Aturan Git:** `firebase_options.dart` di-commit ke Git.
- [x] **Pembersihan Project:** File panduan presentasi terpisah di luar folder project, dokumentasi Firebase menyatu lengkap di `README.md`.

---

## 8. Tautan Pengumpulan Tugas UTS

- **Link Repositori GitHub:** `[TEMPEL_LINK_GITHUB_REPO_DISINI]`
- **Link Google Drive Video Rekaman Presentasi (Zoom Gallery View):**  
  `[TEMPEL_LINK_GOOGLE_DRIVE_VIDEO_DISINI]`  
  *(Pastikan setelan link Google Drive diatur ke "Anyone with the link / Siapa saja yang memiliki link dapat melihat")*
