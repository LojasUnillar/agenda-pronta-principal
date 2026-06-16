/// Argumentos de navegação para a tela de lista de fornecedores.
/// 
/// Encapsula o ID e nome do departamento selecionado
/// para passagem entre rotas.
class DepartmentArgs {
  /// ID do departamento no banco de dados
  final String id;
  
  /// Nome do departamento para exibição
  final String name;

  /// Cria os argumentos de departamento
  /// 
  /// [id] - Identificador único do departamento
  /// [name] - Nome descritivo do departamento
  DepartmentArgs({required this.id, required this.name});
}
