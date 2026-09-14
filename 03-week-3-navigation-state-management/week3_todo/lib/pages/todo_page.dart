import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/todo_provider.dart';
import 'product_page.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Lihat Produk'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProductPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: products.when(
              loading: () => Container(
                height: 80,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              error: (error, _) => Container(
                height: 80,
                alignment: Alignment.center,
                child: Text('Gagal memuat produk: $error'),
              ),
              data: (items) => Container(
                height: 80,
                alignment: Alignment.center,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: items
                      .map((product) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Chip(label: Text(product)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Belum ada tugas'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: Checkbox(
                        value: todos[index].done,
                        onChanged: (_) =>
                            ref.read(todoListProvider.notifier).toggle(index),
                      ),
                      title: Text(
                        todos[index].title,
                        style: TextStyle(
                            decoration: todos[index].done
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            ref.read(todoListProvider.notifier).remove(index),
                      ),
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