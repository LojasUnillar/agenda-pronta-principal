import 'package:flutter/material.dart';
import '../../../profile/domain/models/role_model.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// ViewModel responsável pela gestão de cargos/roles.
///
/// Gerencia o estado da tela de listagem de cargos, incluindo:
/// - Carregamento da lista de cargos (com filtro de administradores)
/// - Criação de novos cargos
/// - Atualização de permissões dos cargos
///
/// Comunica-se com [IProfileRepository] para persistência dos dados.
///
/// Nota: Cargos contendo 'administrador' ou 'admin' no nome são
/// filtrados e não aparecem na listagem por questões de segurança.
class ManageRolesViewModel extends ChangeNotifier {
  /// Repositório de perfil injetado via construtor
  final IProfileRepository _repository;

  /// Cria uma nova instância do ViewModel
  ///
  /// [repository] - Repositório obrigatório para operações de dados
  ManageRolesViewModel(this._repository);

  /// Indica se está carregando dados do backend
  bool _isLoading = false;

  /// Retorna o estado de carregamento atual
  bool get isLoading => _isLoading;

  /// Mensagem de erro em caso de falha nas operações
  String? _errorMessage;

  /// Retorna a mensagem de erro atual ou null se não houver erro
  String? get errorMessage => _errorMessage;

  /// Lista de cargos carregados do backend (filtrada)
  List<RoleModel> _roles = [];

  /// Retorna a lista atual de cargos (sem administradores)
  List<RoleModel> get roles => _roles;

  /// Carrega todos os cargos do repositório
  ///
  /// Atualiza [_roles] com os dados do backend, filtrando cargos
  /// administrativos, e notifica listeners.
  ///
  /// Filtro aplicado: exclui cargos com 'administrador' ou 'admin'
  /// no nome (case-insensitive).
  ///
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> loadRoles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roles = await _repository.getRoles();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao carregar cargos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza as permissões de um cargo
  ///
  /// [roleId] - Identificador do cargo a ser atualizado
  /// [permissions] - Lista de códigos de permissão a serem atribuídos
  ///
  /// Após atualização bem-sucedida, recarrega a lista de cargos.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> updatePermissions(
    String roleId,
    List<String> permissions,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateRolePermissions(roleId, permissions);
      // Recarrega para garantir dados atualizados
      await loadRoles();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao salvar permissões: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria um novo cargo
  ///
  /// [name] - Nome do cargo a ser criado
  /// [description] - Descrição do cargo
  ///
  /// Após criação bem-sucedida, recarrega a lista de cargos.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> createRole(String name, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createRole(name, description);
      await loadRoles();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao criar cargo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
