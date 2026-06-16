import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/notification_model.dart';

/// Dialog de exibição dos detalhes de uma notificação.
/// 
/// Exibe o título, data/hora completa e corpo da mensagem
/// em um design modal elegante.
class NotificationDetailDialog extends StatelessWidget {
  /// Dados da notificação a ser exibida
  final NotificationModel notification;

  /// Cria o dialog de detalhes
  /// 
  /// [notification] - Notificação a ser exibida
  const NotificationDetailDialog({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com ícone
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.secondary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: colors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Detalhes da Notificação",
                      style: TextStyle(
                        color: colors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da notificação
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Data e hora
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 14,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          "dd 'de' MMMM 'às' HH:mm",
                          "pt_BR",
                        ).format(notification.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Corpo da mensagem
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer com Botão
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AppButton(
                label: "Fechar",
                backgroundColor: colors.secondary.withValues(alpha: 0.1),
                foregroundColor: colors.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
