import 'package:flutter/material.dart';

/// Dialog de confirmação padrão (ex: excluir, sair).
///
/// Componente visual para solicitar confirmação do usuário antes de ações críticas.
/// Suporta estilo de "perigo" (botão vermelho) para ações destrutivas.
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final bool isDanger;

  /// Cria um dialog de confirmação.
  ///
  /// [title] - Título do alerta.
  /// [message] - Mensagem explicativa.
  /// [isDanger] - Se true, estiliza o botão de confirmação como destrutivo (vermelho).
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.confirmColor,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: isDanger ? Colors.red : confirmColor,
            foregroundColor: isDanger ? Colors.white : null,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Exibe o dialog de confirmação.
  ///
  /// Retorna `true` se o usuário confirmar, `false` se cancelar ou fechar.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }
}
