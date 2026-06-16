import 'package:agenda/features/contacts/domain/models/contact_model.dart';

/// Contrato para o repositório de Favoritos por Usuário.
abstract class IFavoriteRepository {
  /// Retorna todos os contatos favoritados pelo usuário.
  Future<List<ContactModel>> getFavorites(String userId);

  /// Adiciona ou remove o contato dos favoritos.
  /// Retorna `true` se estiver favoritado após a operação.
  Future<bool> toggleFavorite(String userId, String contactId);

  /// Verifica se um contato está favoritado pelo usuário.
  Future<bool> isFavorite(String userId, String contactId);
}
