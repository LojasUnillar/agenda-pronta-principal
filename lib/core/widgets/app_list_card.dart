import 'package:flutter/material.dart';

/// Card padronizado para itens de lista.
/// Componente reutilizável para listas de produtos, marcas, etc.
class AppListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  /// Cria um card de lista.
  ///
  /// [title] - Título principal (obrigatório).
  /// [subtitle] - Subtítulo opcional (ex: descrição, data).
  /// [leading] - Widget à esquerda (ex: Avatar, Ícone).
  /// [actions] - Lista de widgets à direita (ex: botões de ação).
  /// [onTap] - Ação ao clicar no card inteiro.
  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...[
                const SizedBox(width: 8),
                Row(mainAxisSize: MainAxisSize.min, children: actions!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
