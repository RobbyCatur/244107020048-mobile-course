# Refleksi Minggu 1

## 1. Kapan native lebih tepat daripada cross-platform?
Native lebih tepat dipilih ketika aplikasi menuntut performa sangat tinggi atau akses langsung ke fitur perangkat keras. Native juga menjadi pilihan ketika ukuran aplikasi harus sekecil mungkin. Cross-platform seperti Flutter lebih cocok untuk efisiensi tim, satu basis kode untuk banyak platform, dan pengembangan MVP yang cepat.

## 2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?
Widget tree dibangun berdasarkan nilai state saat itu. Ketika state berubah, Flutter membandingkan widget tree lama dengan yang baru dan hanya merender ulang bagian yang berbeda, sehingga UI selalu sinkron dengan data. Alur yang benar adalah: ubah state melalui mekanisme state management, lalu biarkan framework membangun ulang widget tree secara otomatis, bukan memanipulasi tampilan secara langsung.

## 3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi tim dan portfolio?
Commit yang kecil dan fokus pada satu perubahan memudahkan proses code review, mengurangi risiko konflik saat merge. Pesan yang jelas menjelaskan alasan di balik perubahan, bukan sekadar apa yang diubah, sehingga anggota tim lain mudah memahami histori. Bagi portfolio, riwayat commit yang rapi dan terstruktur menunjukkan cara kerja yang profesional dan disiplin, sehingga rekruter dapat melihat progres serta logika pengembangan secara bertahap.