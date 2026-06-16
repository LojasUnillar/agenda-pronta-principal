import 'package:flutter/material.dart';

/// Serviço para exibição de SnackBars customizados.
/// 
/// Fornece métodos estáticos para exibir feedback visual ao usuário
/// em três variações: sucesso, erro e informação.
/// Utilizado para confirmar ações, alertar erros ou fornecer informações.
class CustomSnackBar {
  /// Exibe um SnackBar de sucesso (verde).
  /// 
  /// [context] - Contexto do Flutter para exibir o SnackBar
  /// [message] - Mensagem a ser exibida
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green.shade600,
    );
  }

  /// Exibe um SnackBar de erro (vermelho).
  /// 
  /// [context] - Contexto do Flutter para exibir o SnackBar
  /// [message] - Mensagem de erro a ser exibida
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade600,
    );
  }

  /// Exibe um SnackBar de informação (cor primária do tema).
  /// 
  /// [context] - Contexto do Flutter para exibir o SnackBar
  /// [message] - Mensagem informativa a ser exibida
  static void showInfo(BuildContext context, String message) {
    final theme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      icon: Icons.info_outline,
      backgroundColor: theme.primary,
    );
  }

  /// Método privado que cria e exibe o SnackBar.
  /// 
  /// [context] - Contexto do Flutter
  /// [message] - Texto da mensagem
  /// [icon] - Ícone a ser exibido
  /// [backgroundColor] - Cor de fundo do SnackBar
  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 4,
      ),
    );
  }
}
