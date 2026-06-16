/// Modelo que representa um cargo/perfil de acesso no sistema.
/// 
/// Cargos definem o nível de acesso de um usuário através
/// de um conjunto de permissões associadas.
/// 
/// Exemplos: Administrador, Gerente, Vendedor, etc.
class RoleModel {
  /// ID único do cargo
  final String id;
  
  /// Nome do cargo
  final String name;
  
  /// Descrição opcional do cargo
  final String? description;
  
  /// Lista de códigos de permissões associadas
  final List<String> permissions;

  /// Cria um novo cargo
  /// 
  /// [id] - Identificador único
  /// [name] - Nome do cargo
  /// [description] - Descrição detalhada (opcional)
  /// [permissions] - Lista de permissões (padrão: vazia)
  RoleModel({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }
}
