import '../models/notification_model.dart';

/// Interface que define o contrato para operações de Notificações.
///
/// Permite buscar, marcar como lida e excluir notificações,
/// com suporte a streams para atualizações em tempo real.
abstract class INotificationRepository {
  /// Stream de notificações para o usuário.
  ///
  /// [userId] - ID do usuário logado
  /// [userRoles] - Cargos do usuário (para notificações por perfil)
  ///
  /// Retorna um stream que emite a lista de notificações atualizada
  Stream<List<NotificationModel>> getNotificationsStream(
    String userId,
    List<String> userRoles,
  );

  /// Marca uma notificação específica como lida.
  ///
  /// [notificationId] - ID da notificação
  /// [userId] - ID do usuário que está lendo
  Future<void> markAsRead(String notificationId, String userId);

  /// Marca todas as notificações do usuário como lidas.
  ///
  /// [userId] - ID do usuário
  Future<void> markAllAsRead(String userId);

  /// Exclui uma notificação.
  ///
  /// [notificationId] - ID da notificação a excluir
  Future<void> deleteNotification(String notificationId);

  /// Cria uma notificação para um usuário específico.
  ///
  /// [userId] - ID do destinatário
  /// [title] - Título da notificação
  /// [body] - Corpo da mensagem
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
  });
}
