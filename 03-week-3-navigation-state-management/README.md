| Key | Value |
|------|-----------------------|
| Nama | Robby Catur Wicaksono |
| NIM | 244107060014 |
| Kelas | TI - 3H |
| Mata Kuliah | Pemrograman Mobile |

# 1. Konsep navigasi dan GoRouter

**Home Page**

<img src="./screenshots/praktikum1_home.jpeg" width="500px">

**Detail Page**

<img src="./screenshots/praktikum1_detail.jpeg" width="500px">

**Penjelasan**

...

## 2. State management dengan Riverpod

**Home Page**

<img src="./screenshots/praktikum2_home.jpeg" width="500px">

**Add To Do**

<img src="./screenshots/praktikum2_addToDo.jpeg" width="500px">

**Setelah To Do Ditambahkan**

<img src="./screenshots/praktikum2_ToDo_added.jpeg" width="500px">

**Setelah Tombol Sampah (Hapus) Diklik**

<img src="./screenshots/praktikum2_ToDo_deleted.jpeg" width="500px">

**Penjelasan**

...

## 3. AsyncValue: loading, error, success

1. Salin kode di atas ke project ToDo Anda (atau project terpisah) dan jalankan. Amati tampilan loading selama 2 detik pertama.

**Loading**

<img src="./screenshots/praktikum3_loading.jpeg" width="500px">

**Home Page**

<img src="./screenshots/praktikum3_home.jpeg" width="500px">

2. Ubah `build()` sementara untuk melempar error: `throw Exception('Gagal terhubung ke server');`. Jalankan dan amati UI error beserta tombol Coba lagi.

```dart
class ProductsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    throw Exception('Gagal terhubung ke server');
  }
  // ...
}
```

<img src="./screenshots/praktikum3_error.jpeg" width="500px">

3. Tekan tombol Coba lagi, `ref.invalidate` membuat provider dijalankan ulang. Pulihkan kode, pastikan state success tampil.

Kembalikan `build()` ke versi normal (hapus `throw`):

```dart
class ProductsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi network
    return ['Keyboard', 'Mouse', 'Monitor'];
  }
  // ...
}
```

`onPressed` tombol "Coba lagi" memanggil `ref.invalidate(productsProvider)`. Ini membuang cache, menjalankan ulang `build()`, sehingga urutan state berjalan lagi: `loading` (spinner 2 detik) → `data` (daftar `Keyboard`, `Mouse`, `Monitor`). Karena `build()` sudah pulih, state success tampil, bukan error.

<img src="./screenshots/praktikum3_success.jpeg" width="500px">

4. Refleksikan: mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting?

```text
Menampilkan data lama dengan indikator refresh lebih baik karena pengguna tetap mendapatkan informasi dan konteks sambil menunggu data terbaru dimuat. Pola ini penting ketika data lama masih relevan dan proses pengambilan data baru membutuhkan waktu atau bergantung pada koneksi jaringan.
```

## 4. AI Challenge

**Prompt:**

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

**Response**

**AI Verification Checklist**

Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

- Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)?
- Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?
- Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)?
- Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?
- Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.
- Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?

## 5. Refactoring dan testing

### Refactoring Challenge

Lakukan refactoring berikut pada aplikasi ToDo Anda, lalu commit dengan pesan yang jelas:

1. Pisahkan widget bar ToDo menjadi TodoTile tersendiri agar build lebih pendek dan mudah diuji.
2. Ekstrak logika filter (misal tampilkan hanya yang belum selesai) menjadi Provider turunan yang membaca todoListProvider.
3. Integrasikan aplikasi ToDo dengan GoRouter: / untuk daftar dan /stats untuk halaman statistik, tambahkan NavigationBar untuk berpindah.

### Testing

Widget test untuk memastikan UI bereaksi terhadap perubahan state provider:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pump();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
```

Jalankan seluruh verifikasi:

```text
flutter analyze
flutter test
```

**Checklist verifikasi mandiri**
- Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.
- ProviderScope membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- UI AsyncValue menangani loading, error, dan success, bukan hanya success.
- flutter analyze tanpa issue dan semua test lulus.
- Hasil AI diverifikasi dan didokumentasikan pada folder docs/.

## 6. Tugas, refleksi, dan referensi

**Mini project / Industry Challenge**
Bangun **aplikasi ToDo dengan navigasi dan Riverpod** sebagai tugas minggu ini:

1. Minimal 2 halaman dengan GoRouter: daftar tugas, halaman detail/statistik.
2. State dikelola Riverpod (Notifier), UI menggunakan ConsumerWidget.
3. Tambahkan fitur simulasi asinkron dengan AsyncValue: state loading, error, dan success tampil dengan benar.
4. Sertakan minimal 1 unit/widget test yang lulus.
5. Kerjakan bagian AI Challenge dan dokumentasikan prompt, hasil AI, perbaikan, serta alasan keputusan teknis Anda.
6. Push ke repository portfolio pada folder 03-week-3-navigation-state-management/ dengan struktur lib/, test/, README.md, dan screenshots/. README menjelaskan tujuan, fitur utama, stack teknologi, cara menjalankan, dan hasil yang dicapai.

**Refleksi**

- Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?
- Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?
- Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?
- Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?