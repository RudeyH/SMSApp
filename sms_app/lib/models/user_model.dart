class User {
  final int id;
  final String username;
  final String email;
  final DateTime? subsValidUntil;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.subsValidUntil,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    subsValidUntil: json['subsValidUntil'] != null
        ? DateTime.parse(json['subsValidUntil'])
        : null,
  );
}
