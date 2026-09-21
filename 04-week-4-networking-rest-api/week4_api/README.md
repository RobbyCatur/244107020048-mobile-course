| Key | Value |
|------|-----------------------|
| Nama | Robby Catur Wicaksono |
| NIM | 244107020048 |
| Kelas | TI - 3H |
| Mata Kuliah | Pemrograman Mobile |

# Praktikum 1: Dio dan model data

## 1. Model data dengan fromJson aman null

Buat `lib/data/models/post.dart`. API dummy yang dipakai minggu ini adalah JSONPlaceholder (gratis, tanpa API key) dengan endpoint `GET /posts`.

<img src="../screenshots/praktikum1/data_models_post.png">

Mengapa cast defensif? Respons API nyata sering tidak sesuai dokumentasi (field hilang, tipe berubah). Pola as String? ?? '' mencegah crash type 'Null' is not a subtype yang menjadi sumber bug paling umum pada integrasi API pertama.

## 2. Konfigurasi Dio terpusat

Buat `lib/data/api_client.dart`. Seluruh konfigurasi jaringan (base URL, timeout, logging) hidup di satu tempat:

<img src="../screenshots/praktikum1/api_client.png">

Mengapa Dio, bukan package http? Dio memberi timeout per-request, interceptor (logging/auth header), dan error terstruktur (DioException dengan type) tanpa boilerplate tambahan.

## 3. Repository sebagai pintu data

Buat `lib/data/repositories/post_repository.dart`:

<img src="../screenshots/praktikum1/post_repository.png">

Perhatikan: repository tidak menampilkan UI apa pun dan tidak menangkap exception menjadi nilai diam-diam. Exception dibiarkan naik agar provider mengubahnya menjadi AsyncError secara otomatis di langkah berikutnya.

# Praktikum 2: Provider dan error handling

## 1. Provider AsyncNotifier + pesan error ramah pengguna

Buat `lib/data/providers.dart`. Provider mengubah exception teknis menjadi pesan yang bisa ditampilkan ke pengguna:

<img src="../screenshots/praktikum2/providers.png">

<img src="../screenshots/praktikum2/providers_2.png">

<img src="../screenshots/praktikum2/providers_3.png">

## 2. UI: loading, error, empty, success

Buat `lib/pages/post_list_page.dart`. Setiap state mendapat tampilannya sendiri:

<img src="../screenshots/praktikum2/post_list_page.png">

<img src="../screenshots/praktikum2/post_list_page_2.png">

## 3. Entry point dengan ProviderScope

Isi `lib/main.dart`:

<img src="../screenshots/praktikum2/main.png">

## Uji tiga skenario error

1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts.

<img src="../screenshots/praktikum2/loading.jpeg">

<img src="../screenshots/praktikum2/post_first.jpeg">

<img src="../screenshots/praktikum2/post_last.jpeg">

2. Matikan internet (mode pesawat), tekan refresh, amati pesan ramah + tombol Coba lagi. Nyalakan kembali internet, tekan Coba lagi.

<img src="../screenshots/praktikum2/disconnect.jpeg">

3. Sementara ubah baseUrl menjadi URL salah, amati pesan error koneksi. Kembalikan setelah uji.

```text
baseUrl: 'https://api.abc.example.com'
```

Output:

<img src="../screenshots/praktikum2/disconnect.jpeg">

**Kesalahan umum (bahan ujian)**: memanggil Dio langsung dari widget; menelan exception dengan `catch` kosong; menampilkan pesan teknis mentah ke pengguna; lupa menangani empty state; tidak ada timeout sehingga UI menggantung selamanya.

# Praktikum 3: Pagination dasar

## Konsep pagination

API dengan data besar tidak dikirim sekaligus, melainkan per halaman. JSONPlaceholder mendukung query `?_page=N&_limit=M`. Strategi UI: _infinite scroll_, muat halaman berikut saat pengguna mendekati ujung list, tampilkan indikator kecil di bawah tanpa menghapus data lama.

## 1. Repository paginated

Tambahkan method berikut ke PostRepository:

<img src="../screenshots/praktikum3/post_repository.png">

## 2. Notifier dengan state halaman

Lanjutkan `lib/data/paged_posts.dart` dengan notifier (guard ganda + data lama dipertahankan saat error):

<img src="../screenshots/praktikum3/paged_posts.png">

## 3. Notifier dengan state halaman (lanjutan)

Lanjutkan file `lib/data/paged_posts.dart` dengan notifier:

<img src="../screenshots/praktikum3/paged_posts2.png">

<img src="../screenshots/praktikum3/paged_posts3.png">

## 4. UI infinite scroll

Buat `lib/pages/paged_post_page.dart` dengan ScrollController yang memicu halaman berikut 200px sebelum ujung list:

<img src="../screenshots/praktikum3/paged_post_page.png">

<img src="../screenshots/praktikum3/paged_post_page2.png">

<img src="../screenshots/praktikum3/paged_post_page3.png">

Ubah home di main.dart menjadi PagedPostPage, jalankan, dan scroll sampai bawah. Amati: halaman 1 tampil dulu, indikator muncul, data bertambah tanpa reload penuh.

<img src="../screenshots/praktikum3/preview.png">

# AI Challenge

## AI Prompt Challenge

Minta AI coding assistant (Cursor, Copilot, Claude Code, atau tool setara) dengan prompt berikut:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

<img src="../screenshots/ai_challenge/prompt.png">

**Hasil:**

<table>
  <tr>
    <td>
    <p>10 Halaman Pertama</p>
    <img src="../screenshots/ai_challenge/first_page_loaded.jpeg">
    </td>
    <td>
    <p>Halaman Pertama Setelah Terload</p>
    <img src="../screenshots/ai_challenge/first_page_full.jpeg">
    </td>
    <td>
    <p>Seluruh Halaman</p>
    <img src="../screenshots/ai_challenge/full_page_loaded.jpeg">
    </td>
  </tr>
</table>

## Verifikasi hasil AI di device fisik

Hasil AI tidak dipercaya begitu saja. Layer Comment diverifikasi lewat unit test (2 test fromJson) dan test pesan error (4 test). Namun saat dijalankan di device fisik muncul bug yang tidak tertangkap test: list pagination stuck di 10 item dengan spinner/loading selamanya.

Akar masalah (hasil analisis bersama AI):

1. Error saat memuat halaman berikutnya ditelan diam-diam karena UI hanya
   menampilkan pesan error ketika list masih kosong.
2. Di layar tinggi (720x1640), 10 item + footer lebih pendek dari viewport
   sehingga `maxScrollExtent = 0` — list tidak bisa di-scroll dan listener
   scroll tidak pernah fires.

Perbaikan: state error disimpan bersama data (footer menampilkan pesan + tombol "Coba lagi"), dan posisi scroll di-check ulang setiap load selesai sehingga halaman berikutnya dimuat otomatis sampai layar terisi.

<table>
  <tr>
    <td>
    <p>Sebelum fix: fling tidak menambah data</p>
    <img src="../screenshots/ai_challenge/verify_03_now.png">
    </td>
    <td>
    <p>Sesudah fix: 20 item terisi otomatis</p>
    <img src="../screenshots/ai_challenge/verify_04_autoload.png">
    </td>
    <td>
    <p>Akhir data: footer indikator muncul</p>
    <img src="../screenshots/ai_challenge/verify_05_manual_scroll.png">
    </td>
  </tr>
</table>

Catatan verifikasi lengkap (termasuk koreksi atas kode hasil AI, mis. cast `as num?` yang masih crash dan `FamilyAsyncNotifier` yang tidak ada di Riverpod 3) didokumentasikan di `docs/verifikasi-ai-week4.md`.

# Refactoring dan testing

## Refactoring Challenge

Lakukan refactoring berikut pada project API Anda, lalu commit dengan pesan yang jelas:

### 1. Ekstrak widget baris post menjadi PostTile tersendiri agar ListView.builder pendek dan mudah diuji.

Buat `lib/widgets/post_tile.dart`. `ListView.builder` di halaman paged dan non-paged sebelumnya berisi `ListTile` inline yang duplikat. `PostTile` memiliki parameter `onTap` (navigasi) dan `showBody` (subtitle body untuk halaman non-paged), sehingga builder kedua halaman pendek dan tile bisa diuji sebagai widget tersendiri.

### 2. Pindahkan friendlyErrorMessage ke file lib/data/network_errors.dart agar bisa dipakai ulang halaman paged dan non-paged.

Pindahkan `friendlyErrorMessage` dari `providers.dart` ke `lib/data/network_errors.dart`. Fungsinya hanya butuh `DioException`, bukan provider, jadi letaknya terlepas dari lapisan state. Halaman paged, non-paged, dan detail semuanya mengimpor file yang sama.

### 3. Tambahkan halaman detail post dengan GoRouter (/post/:id) yang menampilkan title dan body lengkap, state detail diambil dari list yang sudah dimuat atau via repository bila langsung dibuka.

Tambah dependensi `go_router`, buat `lib/router.dart` dengan route `/` (daftar post) dan `/post/:id` (detail), ubah `main.dart` menjadi `MaterialApp.router`. Halaman detail `lib/pages/post_detail_page.dart` mengambil data secara berjenjang:

1. Cari di list yang sudah dimuat (`pagedPostsProvider`) → tampil instan, nol request baru saat user navigasi dari daftar.
2. Jika list masih dimuat, tunggu.
3. Jika dibuka langsung (deep link) dan post tidak ada di list → fetch via `PostRepository.fetchPost(id)` (GET /posts/:id) lewat `postDetailProvider` (FutureProvider.family).

### Hasil

`flutter analyze` tanpa issue dan `flutter test` lulus 12/12, termasuk test baru: klik tile membuka `/post/:id` dari cache (tanpa fetch), dan fallback repository saat post tidak ada di list.

## Testing: unit test model + mock repository

Buat `test/post_test.dart`, uji parsing aman null, mapping error, dan provider dengan repository palsu (tanpa internet):

```dart
class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false})
      : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}
```

## 2. Empat test

1. **Parsing aman null** — `Post.fromJson({'id': 7})`: field hilang diberi default (`title ''`, `userId 0`), tidak crash.
2. **Mapping error** — `DioException(connectionError)` → `friendlyErrorMessage` berisi kata "terhubung".
3. **Provider sukses** — `ProviderContainer` dengan `postRepositoryProvider.overrideWith((ref) => FakePostRepository(...))`, dibaca lewat helper `readPostsOnce`; hasilnya data dari repository palsu.
4. **Provider error** — repo palsu melempar error, `readPostsErrorOnce` menghasilkan `AsyncError` berisi `DioException`.

Catatan implementasi: setelah refactor, `friendlyErrorMessage` diimpor dari `lib/data/network_errors.dart` (bukan `providers.dart`), dan Riverpod 3 memakai `overrideWith((ref) => value)` untuk `Provider`.

## 3. Jalankan

```text
flutter analyze
flutter test
```

**Hasil:** analyze tanpa issue; `flutter test` lulus **16/16** (4 test baru di `post_test.dart` + 12 test sebelumnya). Pola override repository palsu ini adalah fondasi mock API yang dipakai lagi di Minggu 12 (Testing & QA).