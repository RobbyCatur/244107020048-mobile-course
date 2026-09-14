import 'package:flutter/material.dart';

import '../providers/todo_provider.dart';

/// Satu baris tugas, dipisah dari TodoPage agar build TodoPage pendek,
/// fokus pada layout daftar, dan TodoTile mudah diuji sendiri.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onRemove,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
        title: Text(
          todo.title,
          style: TextStyle(
              decoration: todo.done ? TextDecoration.lineThrough : null),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemove,
        ),
      );
}
