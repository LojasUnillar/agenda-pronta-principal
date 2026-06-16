/// Modelo de domínio que representa um usuário autenticado no sistema.
///
/// Agrega informações provenientes de múltiplas fontes:
/// - Dados cadastrais (ID, nome, login).
/// - Sessão (token JWT).
/// - Controle de acesso (cargos e lista plana de permissões).
/// - Estado (ativo/inativo, avatar, data criação).
class UserModel {
  final String id;
  final String name;
  final String login; // Geralmente o email
  final String token; // Sessão ativa
  final List<String> roles; // Nomes dos cargos (ex: 'Administrador')
  final List<String>
  permissions; // Códigos de permissão (ex: 'contacts.create')
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;

  /// Cria uma instância imutável de usuário.
  ///
  /// [permissions] deve conter a lista única de códigos de permissão
  /// agregados de todos os cargos do usuário.
  UserModel({
    required this.id,
    required this.name,
    required this.login,
    required this.token,
    required this.roles,
    required this.permissions,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? login,
    String? token,
    List<String>? roles,
    List<String>? permissions,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      login: login ?? this.login,
      token: token ?? this.token,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Cria um usuário a partir dos dados do Supabase.
  ///
  /// [map] - Dados puros da tabela `tb_usuario` (nome, login, etc).
  /// [token] - Token JWT da sessão atual.
  /// [roles] - Lista de nomes dos cargos (opcional).
  /// [permissions] - Lista de códigos de permissão (opcional).
  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String token, {
    List<String>? roles,
    List<String>? permissions,
  }) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['nome'] ?? map['name'] ?? '', // Suporta 'nome' (banco) e legado
      login: map['login'] ?? '',
      token: token,
      roles: roles ?? List<String>.from(map['roles'] ?? []),
      permissions: permissions ?? List<String>.from(map['permissions'] ?? []),
      avatarUrl: map['avatar_url'],
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'login': login,
      'token': token,
      'roles': roles,
      'permissions': permissions,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cria um usuário a partir do JSON armazenado localmente.
  ///
  /// Utilizado para restaurar a sessão sem nova chamada ao banco.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      login: json['login'],
      token: json['token'],
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Verifica se o usuário possui explicitamente um código de permissão.
  bool hasPermission(String permissionCode) {
    return permissions.contains(permissionCode);
  }

  /// Verifica se o usuário possui cargo de Administrador.
  bool get isAdmin => roles.contains('Administrador');
}
