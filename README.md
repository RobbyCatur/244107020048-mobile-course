# 244107020048-mobile-course

| Key | Value |
|------|-----------------------|
| Nama | Robby Catur Wicaksono |
| NIM | 244107060014 |
| Kelas | TI - 3H |
| Mata Kuliah | Pemrograman Mobile |

Repository ini berisi rencana dan dokumentasi pembelajaran **Pemrograman Mobile** selama **16 minggu**. Fokus utama perkuliahan menggunakan **Flutter & Dart** dengan pendekatan praktik langsung, mulai dari persiapan lingkungan kerja hingga pengembangan aplikasi mobile akhir (final project).

## Daftar Minggu (Kurikulum)

| Minggu | Topik | Folder |
|--------|-------|--------|
| 1 | Mobile Development Ecosystem & Flutter Refresh | [`01-week-1-mobile-development-ecosystem-flutter-refresh`](./01-week-1-mobile-development-ecosystem-flutter-refresh) |
| 2 | Declarative UI & Responsive Design | [`02-week-2-declarative-ui-responsive-design`](./02-week-2-declarative-ui-responsive-design) |
| 3 | Navigation & State Management | [`03-week-3-navigation-state-management`](./03-week-3-navigation-state-management) |
| 4 | Networking & REST API | [`04-week-4-networking-rest-api`](./04-week-4-networking-rest-api) |
| 5 | Local Storage & Offline-First | [`05-week-5-local-storage-offline-first`](./05-week-5-local-storage-offline-first) |
| 6 | Authentication, Security & FCM | [`06-week-6-authentication-security-fcm`](./06-week-6-authentication-security-fcm) |
| 7 | Clean Architecture | [`07-week-7-clean-architecture`](./07-week-7-clean-architecture) |
| 8 | Mid Project Review | [`08-week-8-mid-project-review`](./08-week-8-mid-project-review) |
| 9 | AI-Assisted Development | [`09-week-9-ai-assisted-development`](./09-week-9-ai-assisted-development) |
| 10 | AI Feature Integration | [`10-week-10-ai-feature-integration`](./10-week-10-ai-feature-integration) |
| 11 | Performance Optimization | [`11-week-11-performance-optimization`](./11-week-11-performance-optimization) |
| 12 | Testing & Quality Assurance | [`12-week-12-testing-quality-assurance`](./12-week-12-testing-quality-assurance) |
| 13 | CI/CD Automation | [`13-week-13-ci-cd-automation`](./13-week-13-ci-cd-automation) |
| 14 | Deployment & Monitoring | [`14-week-14-deployment-monitoring`](./14-week-14-deployment-monitoring) |
| 15 | Secure Mobile Development | [`15-week-15-secure-mobile-development`](./15-week-15-secure-mobile-development) |
| 16 | Final Project Expo | [`16-week-16-final-project-expo`](./16-week-16-final-project-expo) |

## Struktur Repository

```
.
├── 01-week-1-.../          # Praktikum & catatan tiap minggu
├── ...
├── 16-week-16-.../
├── notes/                  # Catatan tambahan pembelajaran
│   ├── learning-journal/   # Jurnal harian / mingguan
│   ├── reflections/        # Refleksi pembelajaran
│   └── resources/          # Materi & referensi pendukung
└── README.md               # Dokumen ini
```

## Prasyarat Lingkungan

- Git ([git-scm.com](https://git-scm.com))
- Visual Studio Code + ekstensi Flutter/Dart
- Flutter SDK ([flutter.dev](https://docs.flutter.dev/get-started/install))
- Android Studio + Android SDK & emulator

Verifikasi instalasi:

```bash
flutter --version
flutter doctor
flutter devices
```

## Cara Menggunakan

1. Ikuti materi minggu ke-`N` pada folder `NN-week-N-...`.
2. Kerjakan praktikum dan simpan hasilnya di folder tersebut.
3. Tulis jurnal & refleksi di [`notes/`](./notes).
4. Commit dan push perubahan ke repository ini secara berkala.

```bash
git add .
git commit -m "feat: week N - <topik>"
git push
```

## Konvensi Commit

Mengikuti gaya *Conventional Commits*:

- `feat:` fitur/praktikum baru
- `docs:` dokumentasi & README
- `fix:` perbaikan kode
- `refactor:` perubahan struktur tanpa ubah perilaku
- `chore:` tugas rutin/setup
