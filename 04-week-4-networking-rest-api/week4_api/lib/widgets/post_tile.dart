import 'package:flutter/material.dart';
import '../data/models/post.dart';

/// Baris post untuk ListView.builder.
/// Dulu inline di dua halaman; diekstrak agar list pendek dan tile
/// bisa diuji sendiri (widget test cukup pump PostTile).
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onTap,
    this.showBody = false,
  });

  final Post post;

  /// Aksi saat tile diklik (mis. navigasi ke halaman detail).
  /// Null = tile tampil statis tanpa efek ripple interaktif.
  final VoidCallback? onTap;

  /// true  -> tampilkan subtitle `body` (halaman non-paged).
  /// false -> hanya judul (halaman paged).
  final bool showBody;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showBody
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
