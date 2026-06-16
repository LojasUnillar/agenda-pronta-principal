import 'package:flutter/material.dart';

/// Widget de carregamento personalizado com animação.
/// Exibe um CircularProgressIndicator animado para indicar carregamento.
class CustomLoader extends StatefulWidget {
  /// Tamanho do indicador de carregamento
  final double? size;
  
  /// Cor do indicador (usa tema se não especificado)
  final Color? color;

  /// Cria um widget de loading animado
  /// 
  /// [size] - Tamanho em pixels (padrão: usa tamanho do pai)
  /// [color] - Cor do loader (padrão: cor do tema)
  const CustomLoader({super.key, this.size, this.color});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {});
          });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.onSecondary;

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: CircularProgressIndicator(
        value: _controller.value,
        color: widget.color ?? themeColor,
        strokeWidth: 3.0,
      ),
    );
  }
}
