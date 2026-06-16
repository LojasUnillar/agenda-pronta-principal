import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/contact_model.dart';
import '../domain/models/evaluation_model.dart';
import '../domain/repositories/i_supplier_repository.dart';

///
/// Responsável por todas as operações de banco de dados relacionadas a contatos,
/// fornecedores, distribuidores e representantes.
class SupabaseContactsRepository implements ISupplierRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseContactsRepository();

  /// Busca contatos filtrados por Departamento.
  ///
  /// Utiliza operador `contains` do Postgres para buscar em array de departamentos.
  @override
  Future<List<ContactModel>> getByDepartment(String departmentId) async {
    try {
      debugPrint(
        'ContactsRepo: Buscando contatos do departamento $departmentId',
      );
      final data = await _supabase
          .from('tb_contatos')
          .select()
          .contains('departamentos', '{$departmentId}');

      final List items = data as List;
      debugPrint('ContactsRepo: Encontrados ${items.length} itens');

      return items.map((json) => ContactModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint(
        'Erro ao buscar fornecedores do departamento $departmentId: $e',
      );
      throw ServerException(message: 'Falha ao carregar fornecedores');
    }
  }

  /// Busca todos os contatos que são Fornecedores ou Distribuidoras.
  ///
  /// Filtra por `tipo_contato` (Fornecedor, Fornecedora, Distribuidora, Distribuidor)
  /// e considera apenas contatos ativos (`is_actived = true`).
  /// Ordena alfabeticamente pelo `nome_fantasia`.
  @override
  Future<List<ContactModel>> getSuppliersAndDistributors() async {
    try {
      final data = await _supabase
          .from('tb_contatos')
          .select()
          .or(
            'tipo_contato.eq.Fornecedor,tipo_contato.eq.Fornecedora,tipo_contato.eq.Distribuidora,tipo_contato.eq.Distribuidor',
          )
          .eq('is_actived', true)
          .order('nome_fantasia', ascending: true);

      final List items = data as List;
      return items.map((json) => ContactModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar fornecedores e distribuidoras: $e');
      throw ServerException(
        message: 'Falha ao carregar fornecedores e distribuidoras',
      );
    }
  }

  /// Busca todos os contatos classificados como Representantes.
  @override
  Future<List<ContactModel>> getRepresentatives() async {
    try {
      final data = await _supabase
          .from('tb_contatos')
          .select()
          .eq('tipo_contato', 'Representante');

      final List items = data as List;
      return items.map((json) => ContactModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar representantes: $e');
      throw ServerException(message: 'Falha ao carregar representantes');
    }
  }

  /// Cria um novo contato na tabela `tb_contatos`.
  ///
  /// - Valida se há pelo menos um departamento vinculado.
  /// - Remove o ID antes de inserir (gerado pelo banco).
  @override
  Future<void> createContact(ContactModel contact) async {
    try {
      final departments = contact.departments;
      if (departments.isEmpty) {
        throw Exception('Ao menos um departamento é obrigatório');
      }

      final map = contact.toMap()..remove('id');
      await _supabase.from('tb_contatos').insert(map);
    } catch (e) {
      debugPrint('Erro ao criar contato: $e');
      throw ServerException(message: 'Falha ao criar contato');
    }
  }

  /// Atualiza os dados de um contato existente.
  ///
  /// - Valida a presença de departamentos.
  /// - Remove campo `created_at` para não sobrescrever.
  /// - Utiliza o ID para identificar o registro.
  @override
  Future<void> updateContact(ContactModel contact) async {
    try {
      final departments = contact.departments;
      if (departments.isEmpty) {
        throw Exception('Ao menos um departamento é obrigatório');
      }

      final map = contact.toMap();
      map.remove('created_at');

      await _supabase.from('tb_contatos').update(map).eq('id', contact.id);
    } catch (e) {
      debugPrint('Erro ao atualizar contato: $e');
      throw ServerException(message: 'Falha ao atualizar contato');
    }
  }

  /// Verifica existência de CNPJ no banco.
  ///
  /// Retorna `true` se encontrar algum registro (contagem > 0).
  /// Retorna `false` em caso de erro ou inexistência.
  @override
  Future<bool> checkCnpjExists(String cnpj) async {
    try {
      final count = await _supabase
          .from('tb_contatos')
          .count(CountOption.exact)
          .eq('cnpj', cnpj);
      return count > 0;
    } catch (e) {
      debugPrint('Erro ao verificar CNPJ: $e');
      return false;
    }
  }

  @override
  Future<ContactModel?> getContactById(String id) async {
    try {
      final data = await _supabase
          .from('tb_contatos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return ContactModel.fromMap(data);
    } catch (e) {
      debugPrint('Erro ao buscar contato por ID: $e');
      return null;
    }
  }

  @override
  Future<List<EvaluationModel>> getContactEvaluations(String contactId) async {
    try {
      final data = await _supabase
          .from('tb_avaliacoes_fornecedor')
          .select('*, tb_usuario(nome)')
          .eq('contact_id', contactId)
          .order('created_at', ascending: false);

      final List items = data as List;
      return items.map((json) => EvaluationModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar avaliações do fornecedor $contactId: $e');
      throw ServerException(
        message: 'Falha ao carregar avaliações/comentários',
      );
    }
  }

  @override
  Future<void> addEvaluation(EvaluationModel evaluation) async {
    try {
      final map = evaluation.toMap()..remove('id');
      await _supabase.from('tb_avaliacoes_fornecedor').insert(map);
    } catch (e) {
      debugPrint('Erro ao adicionar avaliação: $e');
      throw ServerException(message: 'Falha ao adicionar avaliação/comentário');
    }
  }
}
