import 'dart:async';
import 'package:agenda/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/models/user_status_filter.dart';
import '../../domain/models/role_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// ViewModel para busca e listagem de usuários.
/// Suporta filtros por status (ativo/inativo) e busca por nome.
/// ViewModel para busca e listagem de perfis.
/// Suporta filtros por nome, status e paginação.

enum ProfileSortOption { alphabetical, alphabeticalReverse, recent, oldest }

class SearchProfileViewModel extends ChangeNotifier {
  final IProfileRepository _repository;
  final IAuthRepository _authRepository;

  SearchProfileViewModel(this._repository, this._authRepository);

  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  UserModel? get user => _authRepository.currentUser;

  StreamSubscription<void>? _changesSub;
  Timer? _debounceReload;
  bool _initialized = false;

  UserStatusFilter _statusFilter = UserStatusFilter.active;
  UserStatusFilter get statusFilter => _statusFilter;

  String? _filterByRoleId;
  String? get filterByRoleId => _filterByRoleId;

  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;

  bool _isLoadingRoles = false;
  bool get isLoadingRoles => _isLoadingRoles;

  ProfileSortOption _sortOption = ProfileSortOption.alphabetical;
  ProfileSortOption get sortOption => _sortOption;

  void setStatusFilter(UserStatusFilter value) {
    _statusFilter = value;
    load(query: searchController.text);
  }

  void setAdvancedFilters({String? roleId}) {
    _filterByRoleId = roleId;
    load(query: searchController.text);
  }

  void setSortOption(ProfileSortOption value) {
    _sortOption = value;
    notifyListeners();
  }

  Future<void> init() async {
    if (_roles.isEmpty && !_isLoadingRoles) {
      _loadRoles();
    }

    if (_initialized) return;
    _initialized = true;

    await load(query: searchController.text);

    // Carrega roles separadamente sem travar a lista principal
    _loadRoles();

    _changesSub?.cancel();
    _changesSub = _repository.watchUsersChanges().listen(
      (_) {
        _debounceReload?.cancel();
        _debounceReload = Timer(const Duration(milliseconds: 300), () {
          load(query: searchController.text);
        });
      },
      onError: (e) {
        // não derruba a tela por erro de realtime
        debugPrint('watchUsersChanges error: $e');
      },
    );
  }

  Future<void> _loadRoles() async {
    _isLoadingRoles = true;
    notifyListeners();

    try {
      _roles = await _repository.getRoles();
    } catch (e) {
      debugPrint("Erro ao carregar roles: $e");
    } finally {
      _isLoadingRoles = false;
      notifyListeners();
    }
  }

  Future<void> load({String query = ''}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Pequeno delay para garantir que a Edge Function já processou a escrita
      await Future.delayed(const Duration(milliseconds: 300));

      var results = await _repository.searchUsers(
        query: query,
        isActive: _statusFilter.isActiveParam,
      );

      // Fallback: Filtragem local caso o backend ignore o parâmetro
      if (_statusFilter.isActiveParam != null) {
        results = results
            .where((u) => u.isActive == _statusFilter.isActiveParam)
            .toList();
      }

      if (_filterByRoleId != null) {
        try {
          final roleName = _roles
              .firstWhere((r) => r.id == _filterByRoleId)
              .name;
          results = results.where((u) => u.roles.contains(roleName)).toList();
        } catch (_) {
          // Role não encontrada ou lista vazia, ignora filtro
        }
      }

      _users = results;
    } on AuthException catch (e) {
      _error = e.message;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('502') || errorMsg.contains('Bad Gateway')) {
        _error =
            'Servidor indisponível temporariamente (502). Tente novamente.';
      } else if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Network')) {
        _error = 'Sem conexão com a internet.';
      } else {
        _error = 'Erro inesperado ao carregar usuários.';
      }
      debugPrint('SearchProfileViewModel load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<UserModel>> get groupedUsers {
    final sorted = [..._users];

    if (_sortOption == ProfileSortOption.alphabetical) {
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (_sortOption == ProfileSortOption.alphabeticalReverse) {
      // Z-A
      sorted.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    } else if (_sortOption == ProfileSortOption.recent) {
      // Mais recentes primeiro (Decrescente)
      sorted.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(0);
        final dateB = b.createdAt ?? DateTime(0);
        return dateB.compareTo(dateA);
      });
    } else {
      // Mais antigos primeiro (Crescente)
      sorted.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(0);
        final dateB = b.createdAt ?? DateTime(0);
        return dateA.compareTo(dateB);
      });
    }

    final map = <String, List<UserModel>>{};

    for (final u in sorted) {
      final nameTrimmed = u.name.trim();
      final letter = nameTrimmed.isEmpty ? '#' : nameTrimmed[0].toUpperCase();
      map.putIfAbsent(letter, () => []);
      map[letter]!.add(u);
    }
    return map;
  }

  void onSearchChanged(String value) {
    _debounceReload?.cancel();
    _debounceReload = Timer(const Duration(milliseconds: 300), () {
      load(query: value);
    });
  }

  String initialsFromName(String name) {
    final n = name.trim();
    if (n.isEmpty) return "-";

    final parts = n.split(RegExp(r"\s+"));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  @override
  void dispose() {
    _debounceReload?.cancel();
    _changesSub?.cancel();
    _repository.disposeUsersWatcher().catchError((_) {});

    searchController.dispose();
    super.dispose();
  }
}
