import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/brand_model.dart';
import '../../domain/repositories/i_brand_repository.dart';

/// Implementação do repositório de Marcas utilizando Supabase.
///
/// Responsável pela persistência e recuperação de dados na tabela `tb_marcas`.
class SupabaseBrandRepository implements IBrandRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna a lista completa de marcas, ordenadas alfabeticamente.
  @override
  Future<List<BrandModel>> getAllBrands() async {
    final response = await _supabase
        .from('tb_marcas')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => BrandModel.fromMap(e)).toList();
  }

  /// Cria uma nova marca com o [name] fornecido.
  @override
  Future<void> createBrand(String name) async {
    await _supabase.from('tb_marcas').insert({'name': name});
  }

  /// Atualiza o nome de uma marca existente pelo [id].
  @override
  Future<void> updateBrand(String id, String name) async {
    await _supabase.from('tb_marcas').update({'name': name}).eq('id', id);
  }

  /// Remove uma marca permanentemente pelo [id].
  @override
  Future<void> deleteBrand(String id) async {
    await _supabase.from('tb_marcas').delete().eq('id', id);
  }
}
