import 'package:flutter/material.dart';

/// FloatingActionButton padronizado do aplicativo.
/// Componente reutilizável para ações principais em telas de listagem.
class AppFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool extended;
  final bool mini;

  /// Cria um FAB customizado.
  ///
  /// [label] - Texto exibido (apenas se [extended] for true).
  /// [icon] - Ícone do botão.
  /// [onPressed] - Ação ao clicar.
  /// [extended] - Se true, exibe ícone + texto (padrão). Se false, apenas ícone.
  /// [mini] - Se true, renderiza uma versão menor do botão.
  const AppFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.extended = true,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (extended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: colors.secondary,
        foregroundColor: colors.onSecondary,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors.secondary,
      foregroundColor: colors.onSecondary,
      mini: mini,
      child: Icon(icon),
    );
  }
}
