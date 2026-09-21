# Verifikasi Hasil AI — Week 4 (Networking & REST API)

Tanggal: 2026-09-21 · Tools: Qoder CLI · Proyek: `week4_api`

Dokumen ini mencatat bagian kode yang **dihasilkan dengan bantuan AI**, bagaimana
saya **memverifikasinya**, dan koreksi yang ditemukan selama verifikasi.
Prinsip: tidak ada keluaran AI yang dipercaya begitu saja — semuanya dicek lewat
`flutter analyze`, `flutter test`, dan dijalankan di device fisik.

## 1. Layer Repository Comment (Dio + flutter_riverpod)

| Komponen | File | Hasil verifikasi |
|---|---|---|
| Model `Comment` (`fromJson` null-safe) | `lib/data/models/comment.dart` | ✅ Lulus 2 unit test |
| `CommentRepository.fetchComments(postId)` + timeout 10 s | `lib/data/repositories/comment_repository.dart` | ✅ Review manual; `Options(send/receiveTimeout: 10s)` menegaskan timeout global `api_client.dart` |
| `commentListProvider` (family `AsyncNotifier`) → `AsyncError` otomatis | `lib/data/providers.dart` | ✅ Review manual |
| `friendlyErrorMessage` (timeout / connection / 404 / 5xx) | `lib/data/providers.dart` | ✅ Lulus 4 unit test |

**Koreksi terhadap hasil AI:** versi pertama `fromJson` AI memakai
`(json['x'] as num?)?.toInt() ?? 0` yang **tetap crash** bila field bertipe
salah (mis. angka dikirim sebagai string). Test saya menangkap ini; AI lalu
menggantinya dengan helper defensif `_asInt`/`_asString`. Versi pertama juga
memakai `FamilyAsyncNotifier` yang tidak ada di Riverpod 3 — analyzer menolak,
diwajibkan konstruktor `CommentListNotifier(this.postId)`.

## 2. Bug di Device Fisik: Stuck 10 Item + Spinner Abadi

**Temuan user (device fisik):** list post ter-pagination berhenti di 10 item,
spinner footer berputar terus.

**Akar masalah (analisis kode hasil AI sebelumnya):**
1. `loadNextPage` menyimpan error ke state, tapi UI lama hanya menampilkan
   pesan error saat `items.isEmpty` → dengan 10 item sudah termuat, error
   halaman ke-2 **ditelan diam-diam** dan footer tetap jadi spinner
   (`hasMore` default `true`).
2. Listener scroll hanya fires saat posisi berubah → setelah error, tidak ada
   mekanisme retry sama sekali.
3. Race: scroll sebelum halaman-1 selesai memicu fetch halaman 1 dua kali.

**Perbaikan:** lihat bagian 3 di bawah; sudah diverifikasi ulang dengan
widget test `State error + retry` (error kini tampil + tombol Coba lagi).

## 3. Audit Terhadap Ketentuan Praktikum

| Ketentuan | Status | Bukti |
|---|---|---|
| UI tidak memanggil Dio langsung; semua data lewat repository + provider | ✅ | `grep import 'package:dio'` di `lib/pages/*` = kosong; test meng-override `postRepositoryProvider` dengan fake, UI tetap jalan — bukti lapisan terpisahkan |
| 4 state tampil benar: loading, error (+retry), empty, success | ✅ | `PagedPostPage`: flag baru `isLoadingFirst` memisahkan *loading* dari *empty* (sebelumnya server 0 data = spinner abadi); error fullscreen + tombol retry, error load-more di footer + retry; `PostListPage` via `state.when` + `posts.isEmpty` |
| Pagination: data bertambah saat scroll, tanpa request ganda, ada indikator akhir data | ✅ | Guard `isLoadingFirst/isLoadingMore/hasMore/items.isEmpty` di notifier; re-check posisi pasca-load untuk layar besar; footer "Semua data termuat." saat `hasMore=false`. Test membuktikan `fetchCount[1]==1` dan `fetchCount[2]==1` |
| `flutter analyze` tanpa issue | ✅ | `No issues found!` (2026-09-21) |
| Semua test lulus | ✅ | `flutter test` → **16/16 lulus** (2 model Comment + 4 pesan error + 4 unit `post_test.dart` (parsing, mapping error, provider sukses/error via `FakePostRepository` tanpa internet) + 4 widget pagination/detail + 2 jalur cache vs repository) |
| Hasil AI diverifikasi & didokumentasikan di `docs/` | ✅ | Dokumen ini |

## 4. Catatan Test Default

`test/widget_test.dart` bawaan template ("Counter increments smoke test")
sudah tidak relevan karena `main.dart` diganti `PagedPostPage`, dan selalu
gagal. Saya ganti dengan smoke test pagination yang menguji state
loading/error/empty/success memakai `FakePostRepository` (tanpa HTTP sungguhan).

## 5. Verifikasi Device Fisik (2026-09-21, Redmi 2409BRN2CY / Android 15)

Dijalankan dengan `flutter run` + screenshot `adb screencap`. Bukti di
`docs/evidence/`:

| File | Bukti |
|---|---|
| `verify_01_initial.png` | Halaman 1: 10 post + footer "Geser untuk memuat lagi..." |
| `verify_03_now.png` | **Bug masih ada setelah perbaikan pertama**: fling user tidak menambah data |
| `verify_04_autoload.png` | Setelah fix chain-fill: 20 post terisi otomatis tanpa sentuhan |
| `verify_05_manual_scroll.png` | Scroll manual sampai post 100 + footer "Semua data termuat." |

**Temuan kunci dari device (yang test otomatis tidak tangkap):** di layar
tinggi 720x1640, 10 item + footer **lebih pendek dari viewport** sehingga
`maxScrollExtent = 0` — list tidak bisa di-scroll sama sekali dan listener
scroll tidak pernah fires. Perbaikan: re-check posisi via `ref.listen` setiap
load selesai, sehingga halaman berikutnya dimuat otomatis sampai layar terisi
atau data habis. Log Dio menunjukkan tiap halaman `_page=1..11` hanya
direquest **satu kali** (tidak ada request ganda; halaman 11 = probe akhir
yang mengembalikan [] lalu `hasMore=false`).

Catatan: injeksi `adb input swipe` diblokir MIUI (butuh *USB debugging
(security settings)*), sehingga scroll akhir dilakukan manual oleh user
sambil log & screenshot dipantau.

## 6. Cara Replikasi Verifikasi

```bash
flutter analyze lib test   # target: No issues found
flutter test               # target: All tests passed (16)
flutter run                # device fisik: scroll sampai dasar ->
                           # 10 -> 20 -> ... item, footer "Semua data termuat."
```
