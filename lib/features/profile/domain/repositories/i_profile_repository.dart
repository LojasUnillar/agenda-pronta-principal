import '../../../auth/domain/models/user_model.dart';
import '../models/role_model.dart';

/// Interface para operações de Perfil e Gestão de Usuários.
///
/// Permite criar, editar, listar e gerenciar perfis de usuário,
/// incluindo suas permissões e cargos.
abstract class IProfileRepository {
  /// Busca usuários com filtros opcionais.
  ///
  /// [query] - Termo de busca por nome/login (opcional)
  /// [isActive] - Filtro por status (opcional)
  Future<List<UserModel>> searchUsers({String query, bool? isActive});

  /// Stream de mudanças na tabela de usuários.
  ///
  /// Útil para atualizações em tempo real na lista.
  Stream<void> watchUsersChanges();

  /// Libera recursos do watcher de usuários.
  Future<void> disposeUsersWatcher();

  /// Retorna todos os cargos disponíveis.
  Future<List<RoleModel>> getRoles();

  /// Cria um novo usuário retornando seu ID.
  ///
  /// [user] - Dados do usuário
  /// [password] - Senha inicial
  /// [roleId] - ID do cargo a ser atribuído
  /// [isActive] - Status inicial
  Future<String> createUserReturningId(
    UserModel user,
    String password, {
    required String roleId,
    required bool isActive,
  });

  /// Atualiza dados de um usuário existente.
  ///
  /// [user] - Dados atualizados
  /// [password] - Nova senha (opcional)
  /// [roleId] - Novo cargo
  /// [isActive] - Novo status
  Future<void> updateUser(
    UserModel user, {
    String? password,
    required String roleId,
    required bool isActive,
  });

  /// Atualiza apenas o avatar do usuário.
  ///
  /// [userId] - ID do usuário
  /// [avatarUrl] - URL da nova imagem
  Future<void> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  });

  /// Atualiza as permissões de um cargo.
  ///
  /// [roleId] - ID do cargo
  /// [permissions] - Lista de códigos de permissões
  Future<void> updateRolePermissions(String roleId, List<String> permissions);

  /// Cria um novo cargo.
  ///
  /// [name] - Nome do cargo
  /// [description] - Descrição do cargo
  Future<void> createRole(String name, String description);

  /// Retorna os IDs de todos os usuários ativos de um determinado cargo.
  ///
  /// [roleName] - Nome exato do cargo (ex: 'Comprador', 'Gerente')
  Future<List<String>> getUserIdsByRole(String roleName);

  /// Retorna os IDs de todos os usuários cujo cargo tem uma determinada permissão.
  ///
  /// [permissionCode] - Código da permissão (ex: AppPermissions.receiveNewContactNotif)
  Future<List<String>> getUserIdsByPermission(String permissionCode);
}
