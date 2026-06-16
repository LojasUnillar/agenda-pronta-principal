import 'package:flutter/material.dart';

/// Campo de texto padrão do aplicativo.
/// Wrapper em torno do TextFormField com estilização unificada.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  /// Cria um campo de texto estilizado.
  ///
  /// [label] - Rótulo flutuante do campo.
  /// [hint] - Dica interna do campo.
  /// [keyboardType] - Tipo de teclado (email, number, text, etc).
  /// [obscureText] - Se true, oculta o texto (para senhas).
  /// [validator] - Função de validação de formulário.
  /// [readOnly] - Se true, impede edição manual.
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autofillHints: autofillHints,
      readOnly: readOnly,
      onTap: onTap,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
