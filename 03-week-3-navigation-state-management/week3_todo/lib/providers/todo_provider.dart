import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Satu tugas. Immutable: perubahan dilakukan lewat [copyWith],
/// bukan mutasi field, agar deteksi perubahan state Riverpod andal.
class Todo {
  const Todo(this.id, this.title, {this.done = false});

  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id, title ?? this.title, done: done ?? this.done);
}

/// Pilihan filter daftar tugas.
enum TodoFilter { semua, selesai, belum }

/// Penyimpanan daftar tugas. ID unik tiap item agar toggle/remove tetap benar
/// walaupun UI menampilkan daftar hasil filter.
class TodoListNotifier extends Notifier<List<Todo>> {
  int _nextId = 1;

  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(_nextId++, title)];

  void toggle(int id) => state = [
        for (final todo in state)
          if (todo.id == id) todo.copyWith(done: !todo.done) else todo,
      ];

  void remove(int id) => state = [
        for (final todo in state)
          if (todo.id != id) todo,
      ];
}

/// Filter aktif, terpisah dari data agar mudah diuji dan di-extend.
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.semua;

  void select(TodoFilter filter) => state = filter;
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Provider turunan: daftar tugas yang benar-benar tampil di layar.
/// Menggabungkan data ([todoListProvider]) + filter ([todoFilterProvider]);
/// otomatis dihitung ulang saat salah satu berubah.
final visibleTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return switch (ref.watch(todoFilterProvider)) {
    TodoFilter.semua => todos,
    TodoFilter.selesai => todos.where((t) => t.done).toList(growable: false),
    TodoFilter.belum => todos.where((t) => !t.done).toList(growable: false),
  };
});
