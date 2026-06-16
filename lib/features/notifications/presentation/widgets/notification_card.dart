import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/notification_model.dart';

/// Card de exibição de uma notificação na lista.
/// 
/// Suporta modo de seleção múltipla e exibe visualmente
/// o estado de leitura (lida/não lida) da notificação.
class NotificationCard extends StatelessWidget {
  /// Dados da notificação
  final NotificationModel notification;
  
  /// Indica se está selecionada (modo seleção)
  final bool isSelected;
  
  /// Indica se o modo de seleção está ativo
  final bool isSelectionMode;
  
  /// Callback ao tocar no card
  final VoidCallback onTap;
  
  /// Callback ao pressionar longamente (ativa seleção)
  final VoidCallback onLongPress;

  /// Cria um card de notificação
  /// 
  /// [notification] - Dados da notificação
  /// [isSelected] - Estado de seleção
  /// [isSelectionMode] - Modo de seleção ativo
  /// [onTap] - Ação ao tocar
  /// [onLongPress] - Ação ao pressionar longamente
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        // Cor diferente para notificações não lidas
        color: notification.isRead
            ? colors.surfaceContainerLow
            : colors.primaryContainer.withValues(
                alpha: 0.2,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Borda destacada quando selecionada
          side: isSelected
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox no modo de seleção ou indicador de não lida
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                )
              else if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.circle, size: 10, color: colors.primary),
                ),

              // Ícone de notificação
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: colors.onSecondaryContainer,
                  size: 24,
                ),
              ),

              // Conteúdo da notificação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Título
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 16,
                              color: colors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Data
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      "Toque para mais detalhes",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formata a data para exibição (dd/MM)
  String _formatDate(DateTime date) {
    return DateFormat("dd/MM").format(date);
  }
}
