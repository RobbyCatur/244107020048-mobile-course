# Responsive Dashboard

Dashboard yang menampilkan kartu profil mahasiswa sebagai latihan declarative UI dan responsive design menggunakan Flutter.

## Tujuan

Mempelajari konsep dasar declarative UI dengan widget Flutter dan responsive design. Fokusnya adalah memahami bagaimana layout menyesuaikan diri terhadap berbagai ukuran layar (ponsel dan tablet) serta menguasai widget dasar seperti `Container`, `Row`, `Column`, dan `Expanded`.

## Fitur Utama

- Menampilkan kartu profil mahasiswa (nama, NIM, kelas) dalam satu `Card`.
- Layout yang dapat menyesuaikan diri terhadap ukuran layar perangkat.

## Stack Teknologi

- **Flutter** — framework UI multi-platform.
- **Dart** — bahasa pemrograman yang digunakan Flutter.

## Cara Menjalankan

Aplikasi dapat dijalankan di emulator, simulator, atau perangkat fisik. Pastikan Flutter SDK sudah terpasang, lalu jalankan perintah berikut di dalam folder `responsive_dashboard`:

```bash
flutter pub get
flutter run
```

## Hasil yang Dicapai

- Memahami konsep declarative UI dan widget dasar Flutter (`Container`, `Row`, `Column`, `Expanded`).
- Mampu membaca perilaku layout, termasuk mengamati peringatan overflow saat `Expanded` dihapus.
- Mampu membuat kartu profil sederhana dan membandingkan tampilannya pada layar 5 inch dan 10 inch.