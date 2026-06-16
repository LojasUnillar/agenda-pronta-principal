/// Modelo que representa um departamento da empresa.
/// 
/// Departamentos são utilizados para agrupar fornecedores
/// e organizar o acesso rápido na tela inicial.
/// 
/// Exemplos: Calcados, Moveis, Eletros, etc.
class DepartmentModel {
  /// ID único do departamento
  final String id;
  
  /// Código do departamento (para mapeamento de ícone)
  final String code;
  
  /// Nome do departamento
  final String name;

  /// Cria um novo departamento
  /// 
  /// [id] - Identificador único
  /// [code] - Código para resolução de ícone
  /// [name] - Nome descritivo
  DepartmentModel({required this.id, required this.code, required this.name});

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id']?.toString() ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
