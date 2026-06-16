/// Modelo que representa um produto.
/// 
/// Produtos são utilizados para categorizar fornecedores
/// e definir quais itens cada fornecedor atende.
class ProductModel {
  /// ID único do produto
  final String id;
  
  /// Nome do produto
  final String name;
  
  /// Data de criação (opcional)
  final DateTime? createdAt;

  /// Cria uma nova instância de ProductModel
  /// 
  /// [id] - Identificador único
  /// [name] - Nome do produto
  /// [createdAt] - Data de criação no banco
  ProductModel({required this.id, required this.name, this.createdAt});

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
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
