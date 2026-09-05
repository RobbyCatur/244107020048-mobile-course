| Key | Value |
|------|-----------------------|
| Nama | Robby Catur Wicaksono |
| NIM | 244107060014 |
| Kelas | TI - 3H |
| Mata Kuliah | Pemrograman Mobile |

# 1. Praktikum: layout sederhana (warm-up)

Sebelum dashboard responsif, latih dulu widget dasar dengan membuat kartu profil sederhana. Buat project baru atau ganti sementara isi `lib/main.dart`:

Kode Program : 

```dart
import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: ProfileCard()),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nama Mahasiswa',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Robby Catur Wicaksono'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: Text('NIM')),
            Text('244107020048'),
          ]),
          const Row(children: [
            Expanded(child: Text('Kelas')),
            Text('TI-3H'),
          ]),
        ],
      ),
    );
  }
}
```

Hasil: 

<div style="display: flex; gap: 16px;">
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>5 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_5inch.png" height="500px">
  </figure>
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>10 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_10inch.png" height="500px">
  </figure>
</div>

### Penjelasan

- 5 Inch (ponsel): layar sempit, kartu 320px hampir memenuhi lebar layar, margin kiri-kanan tipis.
- 10 Inch (tablet): layar lebar, kartu tetap 320px sehingga di-center dengan ruang kosong besar di kiri dan kanan
- Perbedaan ini disebabkan oleh kode `width: 320` yang mengunci lebar kartu tetap berukuran 320px tanpa melihat ukuran device pengguna

## Eksperimen warm-up
1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.

<div style="display: flex; gap: 16px;">
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>5 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no1_5inch.png" height="500px">
  </figure>
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>10 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no1_10inch.png" height="500px">
  </figure>
</div>

**Penjelasan:**
Pada gambar, terlihat bahwa teks keluar dari Row yang sudah disiapkan, bahkan melebihi dari ukuran layar. Overflow terjadi karena saat Expanded dihapus, Column nama dibiarkan memakai lebar aslinya sehingga begitu teksnya terlalu panjang melebihi sisa ruang Row, Flutter tidak bisa menyusutkannya dan teks keluar dari batas.

Setelah `Expanded` dikembalikan

<div style="display: flex; gap: 16px;">
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>5 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no1_expanded_5inch.png" height="500px">
  </figure>
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>10 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no1_expanded_10inch.png" height="500px">
  </figure>
</div>

**Penjelasan:**
Teks sekarang sudah tidak keluar dari row yang sudah disiapkan karena ada `Expanded` sehingga `Flutter` bisa menyusutkan teks tersebut mengikuti ukuran `Row` yang sudah disiapkan

2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu.

<div style="display: flex; gap: 16px;">
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>5 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no2_5inch.png" height="500px">
  </figure>
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>10 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no2_10inch.png" height="500px">
  </figure>
</div>

**Penjelasan:**

- MainAxisSize.min: Column hanya setinggi isinya, sehingga kartu profil pendek/ringkas (sesuai tinggi teks + avatar).
- MainAxisSize.max: Column mengisi seluruh ruang vertikal pada layar, sehingga kartu memanjang mengikuti tinggi layar dengan konten tetap di bagian atas.

3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.

<div style="display: flex; gap: 16px;">
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>5 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no3_5inch.png" height="500px">
  </figure>
  <figure style="margin: 0; text-align: center;">
    <figcaption><strong>10 Inch</strong></figcaption>
    <img src="./screenshots/praktikum1_no3_10inch.png" height="500px">
  </figure>
</div>

**Penjelasan:**
Membuat satu baris data baru menggunakan pola Row dan Expanded yang sama dengan yang sebelumnya, masih dalam satu baris yang sama dengan NIM dan Kelas.