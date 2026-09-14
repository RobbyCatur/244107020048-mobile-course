import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

/// Override deterministik: tanpa delay, selalu sukses.
class _SucceedsStats extends StatsNotifier {
  @override
  Duration get latency => Duration.zero;

  @override
  double get failureRate => 0;
}

/// Override deterministik: tanpa delay, selalu gagal (memicu AsyncError).
class _FailsStats extends StatsNotifier {
  @override
  Duration get latency => Duration.zero;

  @override
  double get failureRate => 1;
}

ProviderContainer _containerWith(StatsNotifier Function() create) {
  final container = ProviderContainer(
    overrides: [statsProvider.overrideWith(create)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('StatsNotifier', () {
    test('sukses mengembalikan 3 entri statistik', () async {
      final container = _containerWith(_SucceedsStats.new);

      final entries = await container.read(statsProvider.future);

      expect(entries, hasLength(3));
      expect(entries.map((e) => e.label),
          ['Total tugas', 'Selesai', 'Tenggat hari ini']);
      expect(container.read(statsProvider).hasValue, isTrue);
    });

    test('saat fetch gagal, provider berada pada state error', () async {
      final container = _containerWith(_FailsStats.new);

      // Baca sekali untuk memicu build(), lalu flush microtask/timer
      // sampai AsyncValue mencapai state terminal (AsyncError).
      container.read(statsProvider);
      await pumpEventQueue();

      final state = container.read(statsProvider);
      expect(state.hasError, isTrue);
      expect(state.hasValue, isFalse);
    });

    test('invalidate menjalankan ulang build()', () async {
      final container = _containerWith(_SucceedsStats.new);

      final first = await container.read(statsProvider.future);
      container.invalidate(statsProvider);
      final second = await container.read(statsProvider.future);

      expect(second, hasLength(first.length));
      expect(container.read(statsProvider).hasValue, isTrue);
    });
  });
}
