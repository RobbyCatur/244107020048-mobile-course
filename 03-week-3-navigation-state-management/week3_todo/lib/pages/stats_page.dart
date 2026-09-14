import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

/// ConsumerWidget: bisa memakai ref untuk watch/read tanpa StatefulWidget.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch di dalam build: UI ikut ter-rebuild saat state provider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Tugas')),
      // when() memaksa ketiga kemungkinan AsyncValue ditangani, bukan
      // hanya success seperti jika memakai .value.
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
                // Invalidate di callback -> build() provider dijalankan ulang.
                onPressed: () => ref.invalidate(statsProvider),
              ),
            ],
          ),
        ),
        data: (entries) => ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) => ListTile(
            leading: Icon(entries[index].icon),
            title: Text(entries[index].label),
            trailing: Text(
              entries[index].value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
