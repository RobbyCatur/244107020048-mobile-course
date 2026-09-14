import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

/// Halaman daftar tugas. Filter aktif dibaca dari [visibleTodosProvider]
/// (provider turunan), bukan difilter manual di dalam build.
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(visibleTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text('Lihat Statistik'),
            onPressed: () => context.go('/stats'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                    value: TodoFilter.semua, label: Text('Semua')),
                ButtonSegment(
                    value: TodoFilter.belum, label: Text('Belum')),
                ButtonSegment(
                    value: TodoFilter.selesai, label: Text('Selesai')),
              ],
              selected: {filter},
              onSelectionChanged: (selection) =>
                  ref.read(todoFilterProvider.notifier).select(selection.first),
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Belum ada tugas'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) => TodoTile(
                      todo: todos[index],
                      onToggle: () => ref
                          .read(todoListProvider.notifier)
                          .toggle(todos[index].id),
                      onRemove: () => ref
                          .read(todoListProvider.notifier)
                          .remove(todos[index].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
