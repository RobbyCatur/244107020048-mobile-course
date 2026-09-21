/// Model data untuk satu komentar dari endpoint
/// GET https://jsonplaceholder.typicode.com/comments?postId={id}.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// Parser null-safe: tidak pernah melempar exception meski field
  /// JSON hilang, bertipe lain, atau bernilai null.
  /// - [_asInt]/[_asString] menormalisasi tipe tak terduga
  ///   (mis. angka dikirim sebagai string) ke nilai default.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: _asInt(json['postId']),
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      body: _asString(json['body']),
    );
  }

  /// Ambil nilai integer apa pun isinya: null -> 0; num -> toInt();
  /// String angka ("7") -> 7; String bukan angka -> 0.
  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Ambil nilai string apa pun isinya: null -> ''; selain itu
  /// toString() agar tidak crash pada tipe yang salah.
  static String _asString(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
