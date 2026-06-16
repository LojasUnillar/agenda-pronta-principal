import '../models/department_model.dart';

/// Interface para acesso a dados de Departamentos.
/// 
/// Define o contrato para obtenção da lista de departamentos
/// ativos no sistema.
abstract class IDepartmentRepository {
  /// Retorna todos os departamentos ativos.
  /// 
  /// Os departamentos são ordenados alfabeticamente pelo nome.
  Future<List<DepartmentModel>> getActiveDepartments();
}
