import 'app_permissions.dart';

/// Metadados descritivos para cada permissão do sistema.
///
/// Fornece labels e agrupamentos amigáveis para exibição
/// na UI de gerenciamento de permissões.
class PermissionMetadata {
  /// Código técnico da permissão (referência a AppPermissions)
  final String key;

  /// Label amigável para exibição
  final String label;

  /// Grupo ao qual a permissão pertence
  final String group;

  /// Cria metadados de permissão
  ///
  /// [key] - Código da permissão
  /// [label] - Descrição amigável
  /// [group] - Categoria/Grupo
  const PermissionMetadata({
    required this.key,
    required this.label,
    required this.group,
  });

  /// Lista de todas as permissões com seus metadados.
  ///
  /// Mantida em ordem lógica de grupos.
  static const List<PermissionMetadata> all = [
    // ================== GESTÃO DE USUÁRIOS ==================
    PermissionMetadata(
      key: AppPermissions.accessCadUser,
      label: 'Acessar Cadastro de Usuários',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.createUser,
      label: 'Criar Novos Usuários',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.alterCadUser,
      label: 'Editar Próprio Perfil',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.alterStatusUser,
      label: 'Ativar/Desativar Usuários',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.alterTipoUser,
      label: 'Alterar Cargo de Usuários',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.alterAvatar,
      label: 'Alterar Avatar',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.deleteAvatar,
      label: 'Deletar Avatar',
      group: 'Gestão de Usuários',
    ),
    PermissionMetadata(
      key: AppPermissions.deleteUser,
      label: 'Excluir Usuários',
      group: 'Gestão de Usuários',
    ),

    // ================== CONTATOS ==================
    PermissionMetadata(
      key: AppPermissions.createContact,
      label: 'Criar Contatos',
      group: 'Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.editContact,
      label: 'Editar Contatos',
      group: 'Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.deleteContact,
      label: 'Excluir Contatos',
      group: 'Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.evaluateSupplier,
      label: 'Avaliar Contato c/ Estrelas',
      group: 'Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.commentSupplier,
      label: 'Anotar/Comentar no Contato',
      group: 'Contatos',
    ),

    // ================== NAVEGAÇÃO / GERAL ==================
    PermissionMetadata(
      key: AppPermissions.accessNotifi,
      label: 'Acessar Notificações',
      group: 'Geral',
    ),
    PermissionMetadata(
      key: AppPermissions.sendNotification,
      label: 'Enviar Notificações',
      group: 'Geral',
    ),
    PermissionMetadata(
      key: AppPermissions.accessFav,
      label: 'Acessar Favoritos',
      group: 'Geral',
    ),
    PermissionMetadata(
      key: AppPermissions.accessProfile,
      label: 'Botão Rapido Perfil',
      group: 'Geral',
    ),
    PermissionMetadata(
      key: AppPermissions.accessConfig,
      label: 'Acessar Configurações',
      group: 'Geral',
    ),
    PermissionMetadata(
      key: AppPermissions.accessUsersTab,
      label: 'Acessar Aba de Usuários',
      group: 'Geral',
    ),

    // ================== NOTIFICAÇÕES DE CONTATOS ==================
    PermissionMetadata(
      key: AppPermissions.receiveNewContactNotif,
      label: 'Receber notificação de novo contato',
      group: 'Notificações de Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.receiveContactUpdateNotif,
      label: 'Receber notificação de atualização de contato',
      group: 'Notificações de Contatos',
    ),
    PermissionMetadata(
      key: AppPermissions.receiveContactAnnotationNotif,
      label: 'Receber notificação de nova anotação em contato',
      group: 'Notificações de Contatos',
    ),
  ];

  /// Retorna as permissões agrupadas por categoria.
  ///
  /// Útil para exibição em UI com seções agrupadas.
  static Map<String, List<PermissionMetadata>> get grouped {
    final map = <String, List<PermissionMetadata>>{};
    for (var p in all) {
      if (!map.containsKey(p.group)) {
        map[p.group] = [];
      }
      map[p.group]!.add(p);
    }
    return map;
  }
}
