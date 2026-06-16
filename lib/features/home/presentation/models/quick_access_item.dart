/// Modelo de apresentação para itens de menu na Home.
/// 
/// Representa um departamento na seção de acesso rápido,
/// contendo informações necessárias para navegação e exibição.
class QuickAccessItem {
  /// ID do departamento
  final String id;
  
  /// Código do departamento (para resolução de ícone)
  final String code;
  
  /// Nome/label do departamento
  final String label;

  /// Cria um item de acesso rápido
  /// 
  /// [id] - Identificador do departamento
  /// [code] - Código para mapeamento de ícone
  /// [label] - Nome exibido ao usuário
  const QuickAccessItem({
    required this.id,
    required this.code,
    required this.label,
  });
}
