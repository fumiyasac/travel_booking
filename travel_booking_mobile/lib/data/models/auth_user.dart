class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    token: json['token'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    if (token != null) 'token': token,
  };

  AuthUser copyWith({String? id, String? email, String? name, String? token}) =>
      AuthUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        token: token ?? this.token,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
