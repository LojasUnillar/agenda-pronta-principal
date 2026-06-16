import 'package:flutter/material.dart';
import 'custom_loader.dart';

/// Botão padrão do aplicativo.
/// Wrapper em torno do ElevatedButton com suporte a estado de carregamento.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;

  /// Cria um botão customizado.
  ///
  /// [label] - Texto exibido no botão.
  /// [onPressed] - Função de callback. Se null, o botão fica desabilitado.
  /// [isLoading] - Se true, exibe um loader no lugar do texto e desabilita o clique.
  /// [icon] - Ícone opcional exibido à esquerda do texto.
  /// [backgroundColor] - Cor de fundo (sobrescreve o tema se fornecido).
  /// [width] - Largura fixa (opcional). Se null, ocupa largura máxima.
  /// [height] - Altura fixa do botão. Padrão é 48.0.
  /// [foregroundColor] - Cor do texto e ícone (sobrescreve o tema se fornecido).
  /// [padding] - Preenchimento interno do botão. Padrão é vertical 16.
  /// [shape] - Forma do botão. Padrão é um retângulo arredondado com raio 12.
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48.0,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CustomLoader(size: 20, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
