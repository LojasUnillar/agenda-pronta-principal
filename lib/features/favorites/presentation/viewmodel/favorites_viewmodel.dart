import 'package:flutter/material.dart';
import 'package:agenda/features/contacts/domain/models/contact_model.dart';
import 'package:agenda/features/favorites/domain/repositories/i_favorite_repository.dart';
import 'package:agenda/features/auth/domain/repositories/i_auth_repository.dart';

/// ViewModel para a tela de Favoritos Pessoais.
class FavoritesViewModel extends ChangeNotifier {
  final IFavoriteRepository _favoriteRepository;
  final IAuthRepository _authRepository;

  FavoritesViewModel(this._favoriteRepository, this._authRepository);

  List<ContactModel> _favorites = [];
  bool _isLoading = false;
  String? _error;

  // Cache local: set de IDs favoritados pelo usuário atual
  final Set<String> _favoritedIds = {};

  List<ContactModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _userId => _authRepository.currentUser?.id;

  /// Carrega a lista de favoritos do usuário.
  Future<void> loadFavorites() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoriteRepository.getFavorites(userId);
      _favoritedIds
        ..clear()
        ..addAll(_favorites.map((c) => c.id));
    } catch (e) {
      _error = 'Erro ao carregar favoritos.';
      debugPrint('FavoritesViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica — via cache local — se um contato está favoritado.
  bool isFavorited(String contactId) => _favoritedIds.contains(contactId);

  /// Alterna o favorito. Atualiza cache e lista localmente (otimista).
  Future<bool> toggleFavorite(String contactId, ContactModel contact) async {
    final userId = _userId;
    if (userId == null) return false;

    final wasFavorited = _favoritedIds.contains(contactId);

    // Atualização otimista
    if (wasFavorited) {
      _favoritedIds.remove(contactId);
      _favorites.removeWhere((c) => c.id == contactId);
    } else {
      _favoritedIds.add(contactId);
      _favorites.insert(0, contact);
    }
    notifyListeners();

    try {
      final nowFavorited = await _favoriteRepository.toggleFavorite(
        userId,
        contactId,
      );
      // Reconcilia caso o servidor discorde (segurança)
      if (nowFavorited != !wasFavorited) {
        await loadFavorites();
      }
      return nowFavorited;
    } catch (e) {
      // Reverte em caso de erro
      if (wasFavorited) {
        _favoritedIds.add(contactId);
        _favorites.insert(0, contact);
      } else {
        _favoritedIds.remove(contactId);
        _favorites.removeWhere((c) => c.id == contactId);
      }
      notifyListeners();
      return wasFavorited;
    }
  }

  /// Inicializa o cache de IDs favoritados para uso na tela de perfil.
  Future<void> initCache() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      final list = await _favoriteRepository.getFavorites(userId);
      _favoritedIds
        ..clear()
        ..addAll(list.map((c) => c.id));
      notifyListeners();
    } catch (_) {}
  }
}
