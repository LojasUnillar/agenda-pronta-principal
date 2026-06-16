import 'package:flutter/material.dart';

/// Widget para exibir estado de lista vazia de forma consistente.
/// Utilizado quando não há dados para exibir em listas.
class AppEmptyState extends StatelessWidget {
  /// Mensagem principal a ser exibida
  final String message;
  
  /// Ícone a ser exibido acima da mensagem
  final IconData icon;
  
  /// Mensagem secundária opcional (mais detalhada)
  final String? subMessage;

  /// Cria um widget de estado vazio
  /// 
  /// [message] - Texto principal (padrão: 'Nenhum item encontrado')
  /// [icon] - Ícone a ser exibido (padrão: Icons.search_off)
  /// [subMessage] - Texto secundário opcional
  const AppEmptyState({
    super.key,
    this.message = 'Nenhum item encontrado',
    this.icon = Icons.search_off,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: TextStyle(
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
