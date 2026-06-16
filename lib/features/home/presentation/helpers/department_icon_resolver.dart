import 'package:flutter/material.dart';
import '../constants/departments_icons.dart';

/// Utilitário para resolver ícones de departamento com base no código.
/// 
/// Seleciona automaticamente entre os temas claro e escuro
/// baseado no tema atual do aplicativo.
class DepartmentIconResolver {
  /// Retorna o caminho do ícone para um departamento.
  /// 
  /// [context] - Contexto Flutter para acesso ao tema
  /// [departmentCode] - Código do departamento (ex: 'calcados', 'moveis')
  /// 
  /// Retorna o caminho do asset ou um ícone padrão se não encontrado
  static String resolveDepartmentIcon(
    BuildContext context,
    String departmentCode,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final icons = isDarkMode ? departmentIconsDark : departmentIconsLight;

    // Retorna o ícone do departamento ou um padrão se não existir
    return icons[departmentCode] ?? 'assets/icons/default.png';
  }
}
