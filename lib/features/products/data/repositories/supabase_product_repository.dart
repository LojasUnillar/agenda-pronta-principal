import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';

/// Implementação do repositório de Produtos usando Supabase.
/// 
/// Realiza operações CRUD na tabela 'tb_produtos' do Supabase.
class SupabaseProductRepository implements IProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final response = await _supabase
        .from('tb_produtos')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<void> createProduct(String name) async {
    await _supabase.from('tb_produtos').insert({'name': name});
  }

  @override
  Future<void> updateProduct(String id, String name) async {
    await _supabase.from('tb_produtos').update({'name': name}).eq('id', id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _supabase.from('tb_produtos').delete().eq('id', id);
  }
}
