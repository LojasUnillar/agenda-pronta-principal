import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/department_model.dart';
import '../../domain/repositories/i_department_repository.dart';

/// Implementação do repositório de Departamentos via Supabase.
/// 
/// Realiza cache local após o primeiro carregamento para
/// melhorar a performance em acessos subsequentes.
class DepartmentRepositorySupabase implements IDepartmentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cache local dos departamentos
  List<DepartmentModel>? _cache;

  @override
  Future<List<DepartmentModel>> getActiveDepartments() async {
    // Retorna do cache se disponível
    if (_cache != null) return _cache!;

    // Busca no Supabase
    final response = await _supabase
        .from('tb_departamento')
        .select('id, code, name')
        .order('name', ascending: true);

    // Converte para modelos
    final list = (response as List)
        .map((e) => DepartmentModel.fromMap(e))
        .toList();
    
    // Armazena no cache
    _cache = list;
    return list;
  }
}
