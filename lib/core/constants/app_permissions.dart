/// Define todas as permissões disponíveis no sistema.
///
/// Esta classe contém as constantes de permissões utilizadas
/// para controle de acesso baseado em roles (RBAC).
/// As permissões são verificadas em tempo de execução para
/// habilitar/desabilitar funcionalidades na UI.
abstract class AppPermissions {
  // ================== GESTÃO DE USUÁRIOS ==================

  /// Permite alterar o status (ativo/inativo) de usuários
  static const alterStatusUser = 'alterstatususer';

  /// Permite alterar o avatar do usuário
  static const alterAvatar = 'alteravatar';

  /// Permite deletar o avatar do usuário
  static const deleteAvatar = 'deleteavatar';

  /// Permite alterar o tipo/cargo do usuário
  static const alterTipoUser = 'altertipouser';

  /// Permite acessar a tela de cadastro de usuários
  static const accessCadUser = 'accesscaduser';

  /// Permite alterar o próprio cadastro de usuário
  static const alterCadUser = 'altercaduser';

  // ================== NAVEGAÇÃO / ACESSO ==================

  /// Permite acessar a tela de notificações
  static const accessNotifi = 'accessnotifi';

  /// Permite acessar a tela de favoritos
  static const accessFav = 'accessfav';

  /// Permite acessar a tela de perfil
  static const accessProfile = 'accessprofile';

  /// Permite acessar a tela de configurações
  static const accessConfig = 'accessconfig';

  /// Permite acessar a aba de Usuários na navegação
  static const accessUsersTab = 'accessuserstab';

  // ================== CONTATOS ==================

  /// Permite criar novos contatos
  static const createContact = 'createcontact';

  /// Permite editar contatos existentes
  static const editContact = 'editcontact';

  /// Permite excluir contatos
  static const deleteContact = 'deletecontact';

  // ================== AVALIAÇÕES DE FORNECEDOR ==================

  /// Permite avaliar um fornecedor com estrelas
  static const evaluateSupplier = 'evaluatesupplier';

  /// Permite adicionar um comentário/observação no fornecedor
  static const commentSupplier = 'commentsupplier';

  // ================== NOTIFICAÇÕES ==================

  /// Permite enviar notificações
  static const sendNotification = 'sendnotification';

  /// Recebe notificação quando um novo contato é adicionado
  static const receiveNewContactNotif = 'receivenewcontactnotif';

  /// Recebe notificação quando um contato é atualizado
  static const receiveContactUpdateNotif = 'receivecontactupdatenotif';

  /// Recebe notificação quando uma anotação é adicionada em um contato
  static const receiveContactAnnotationNotif = 'receivecontactannotationnotif';

  // ================== OPERAÇÕES ESPECÍFICAS ==================

  /// Permite criar novos usuários no sistema
  static const createUser = 'createuser';

  /// Permite editar usuários existentes
  static const editUser = 'edituser';

  /// Permite excluir usuários
  static const deleteUser = 'deleteuser';
}
