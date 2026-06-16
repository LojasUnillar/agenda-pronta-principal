import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agenda/features/contacts/domain/models/contact_model.dart';
import '../domain/repositories/i_favorite_repository.dart';

/// Implementação da [IFavoriteRepository] usando Supabase.
///
/// Persiste favoritos na tabela `tb_favoritos` com RLS por `user_id`.
class FavoriteRepositorySupabase implements IFavoriteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<ContactModel>> getFavorites(String userId) async {
    try {
      final data = await _supabase
          .from('tb_favoritos')
          .select('contact_id, tb_contatos(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List items = data as List;
      return items
          .map(
            (row) => ContactModel.fromMap(
              row['tb_contatos'] as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar favoritos: $e');
      return [];
    }
  }

  @override
  Future<bool> toggleFavorite(String userId, String contactId) async {
    try {
      final existing = await _supabase
          .from('tb_favoritos')
          .select('id')
          .eq('user_id', userId)
          .eq('contact_id', contactId)
          .maybeSingle();

      if (existing != null) {
        // já favoritado → remove
        await _supabase
            .from('tb_favoritos')
            .delete()
            .eq('user_id', userId)
            .eq('contact_id', contactId);
        return false;
      } else {
        // não favoritado → adiciona
        await _supabase.from('tb_favoritos').insert({
          'user_id': userId,
          'contact_id': contactId,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorite(String userId, String contactId) async {
    try {
      final data = await _supabase
          .from('tb_favoritos')
          .select('id')
          .eq('user_id', userId)
          .eq('contact_id', contactId)
          .maybeSingle();
      return data != null;
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return false;
    }
  }
}
