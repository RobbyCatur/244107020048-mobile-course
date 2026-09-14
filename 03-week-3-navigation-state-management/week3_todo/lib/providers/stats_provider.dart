import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Satu item statistik: label, nilai, ikon. Immutable.
class StatEntry {
  const StatEntry({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

/// Simulasi fetch statistik: delay [latency], lalu [failureRate] peluang gagal.
/// Getter dibuat virtual supaya unit test bisa menurunkannya menjadi
/// deterministik (delay 0, sukses/gagal 100%) tanpa mengubah kode produksi.
class StatsNotifier extends AsyncNotifier<List<StatEntry>> {
  Duration get latency => const Duration(seconds: 2);

  double get failureRate => 0.3;

  Random get random => Random();

  @override
  Future<List<StatEntry>> build() async {
    await Future.delayed(latency);

    if (random.nextDouble() < failureRate) {
      throw Exception('Gagal memuat statistik: server tidak merespons');
    }

    return const [
      StatEntry(label: 'Total tugas', value: '12', icon: Icons.checklist),
      StatEntry(label: 'Selesai', value: '7', icon: Icons.task_alt),
      StatEntry(label: 'Tenggat hari ini', value: '2', icon: Icons.alarm),
    ];
  }
}

/// Provider bertipe eksplisit, pola AsyncNotifier (Riverpod 3).
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatEntry>>(StatsNotifier.new);
