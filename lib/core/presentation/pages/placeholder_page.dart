import 'package:flutter/material.dart';
import '../../widgets/app_empty_state.dart';

/// Página placeholder para funcionalidades em desenvolvimento.
/// 
/// Exibe uma mensagem indicando que a tela está sendo construída.
/// Útil durante o desenvolvimento para rotas ainda não implementadas.
class PlaceholderPage extends StatelessWidget {
  /// Título da página
  final String title;
  
  /// Ícone a ser exibido
  final IconData icon;

  /// Cria uma página placeholder
  /// 
  /// [title] - Título da funcionalidade em desenvolvimento
  /// [icon] - Ícone representativo (padrão: Icons.construction_outlined)
  const PlaceholderPage({
    super.key,
    required this.title,
    this.icon = Icons.construction_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppEmptyState(
        message: 'Em desenvolvimento',
        subMessage: 'A tela de $title está sendo construída.',
        icon: icon,
      ),
    );
  }
}
