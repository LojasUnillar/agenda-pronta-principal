import '../models/product_model.dart';

/// Interface para operações de persistência de Produtos.
/// 
/// Define o contrato para CRUD de produtos no sistema,
/// permitindo diferentes implementações (Supabase, mock, etc).
abstract class IProductRepository {
  /// Retorna todos os produtos cadastrados.
  /// 
  /// Os produtos são ordenados alfabeticamente pelo nome.
  Future<List<ProductModel>> getAllProducts();

  /// Cria um novo produto.
  /// 
  /// [name] - Nome do produto a ser criado
  Future<void> createProduct(String name);

  /// Atualiza o nome de um produto existente.
  /// 
  /// [id] - ID do produto a ser atualizado
  /// [name] - Novo nome do produto
  Future<void> updateProduct(String id, String name);

  /// Exclui um produto.
  /// 
  /// [id] - ID do produto a ser excluído
  Future<void> deleteProduct(String id);
}
