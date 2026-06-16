import 'package:flutter/material.dart';
import '../models/quick_access_item.dart';
import '../helpers/department_icon_resolver.dart';

/// Card de acesso rápido a um departamento na Home.
///
/// Exibe o ícone e nome do departamento para navegação
/// rápida à lista de contatos do departamento.
class QuickAccessCard extends StatelessWidget {
  /// Item de acesso rápido (departamento)
  final QuickAccessItem item;

  /// Callback ao tocar no card
  final VoidCallback onTap;

  /// Cria um card de acesso rápido
  ///
  /// [item] - Dados do departamento
  /// [onTap] - Ação ao tocar no card
  const QuickAccessCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Resolve o ícone baseado no código do departamento
    final iconPath = DepartmentIconResolver.resolveDepartmentIcon(
      context,
      item.code,
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 48, height: 48),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
