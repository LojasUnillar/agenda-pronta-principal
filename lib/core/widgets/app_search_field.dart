import 'package:flutter/material.dart';

/// Campo de busca padrão para AppBars.
/// Componente reutilizável para campos de pesquisa em listas.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;

  /// Cria um campo de busca.
  ///
  /// [controller] - Controlador do texto (opcional).
  /// [hint] - Texto de dica (padrão: 'Buscar...').
  /// [onChanged] - Callback chamado a cada alteração de texto.
  /// [onClear] - Callback chamado ao limpar o campo via botão 'X'.
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar...',
    this.onChanged,
    this.onClear,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        onChanged: onChanged,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: colors.onSurface.withOpacity(0.5),
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
