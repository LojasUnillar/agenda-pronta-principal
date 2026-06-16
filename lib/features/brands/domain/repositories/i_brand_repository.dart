import '../models/brand_model.dart';

/// Interface para operações de persistência de Marcas.
/// 
/// Define o contrato para CRUD de marcas no sistema,
/// permitindo diferentes implementações (Supabase, mock, etc).
abstract class IBrandRepository {
  /// Retorna todas as marcas cadastradas.
  /// 
  /// As marcas são ordenadas alfabeticamente pelo nome.
  Future<List<BrandModel>> getAllBrands();

  /// Cria uma nova marca.
  /// 
  /// [name] - Nome da marca a ser criada
  Future<void> createBrand(String name);

  /// Atualiza o nome de uma marca existente.
  /// 
  /// [id] - ID da marca a ser atualizada
  /// [name] - Novo nome da marca
  Future<void> updateBrand(String id, String name);

  /// Exclui uma marca.
  /// 
  /// [id] - ID da marca a ser excluída
  Future<void> deleteBrand(String id);
}
