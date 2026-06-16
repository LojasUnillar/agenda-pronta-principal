import 'package:flutter/material.dart';

import 'app_button.dart';

/// Widget para exibir erros com opção de "Tentar novamente".
/// Utilizado quando ocorre falha no carregamento de dados.
class AppErrorState extends StatelessWidget {
  /// Mensagem de erro a ser exibida
  final String message;
  
  /// Callback executado ao pressionar o botão de retry
  final VoidCallback? onRetry;
  
  /// Ícone a ser exibido acima da mensagem
  final IconData icon;

  /// Cria um widget de estado de erro
  /// 
  /// [message] - Texto obrigatório descrevendo o erro
  /// [onRetry] - Callback opcional para ação de retry
  /// [icon] - Ícone a ser exibido (padrão: Icons.error_outline)
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.error),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: "Tentar novamente",
                onPressed: onRetry,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
