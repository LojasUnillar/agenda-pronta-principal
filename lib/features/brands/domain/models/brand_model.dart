/// Modelo que representa uma marca de produtos.
/// 
/// Marcas são utilizadas para categorizar fornecedores
/// e produtos no sistema.
class BrandModel {
  /// ID único da marca
  final String id;
  
  /// Nome da marca
  final String name;
  
  /// Data de criação (opcional)
  final DateTime? createdAt;

  /// Cria uma nova instância de BrandModel
  /// 
  /// [id] - Identificador único
  /// [name] - Nome da marca
  /// [createdAt] - Data de criação no banco
  BrandModel({required this.id, required this.name, this.createdAt});

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  /// Converte a instância para um mapa (para envio ao Supabase)
  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
