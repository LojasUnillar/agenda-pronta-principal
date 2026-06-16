import '../models/contact_model.dart';
import '../models/evaluation_model.dart';

/// Contrato para o repositório de Contatos/Fornecedores.
///
/// Define as operações disponíveis para gestão de contatos na camada de domínio.
abstract class ISupplierRepository {
  /// Busca contatos por departamento.
  ///
  /// [departmentId] - ID do departamento para filtrar
  Future<List<ContactModel>> getByDepartment(String departmentId);

  /// Busca todos os contatos marcados como representantes.
  Future<List<ContactModel>> getRepresentatives();

  /// Busca todos os contatos marcados como Fornecedor ou Distribuidora.
  Future<List<ContactModel>> getSuppliersAndDistributors();

  /// Cria um novo contato.
  ///
  /// [contact] - Dados do contato a ser criado
  Future<void> createContact(ContactModel contact);

  /// Atualiza um contato existente.
  ///
  /// [contact] - Dados atualizados do contato
  Future<void> updateContact(ContactModel contact);

  /// Verifica se um CNPJ já existe no sistema.
  ///
  /// [cnpj] - CNPJ a verificar
  /// Retorna `true` se já existir, `false` caso contrário
  Future<bool> checkCnpjExists(String cnpj);

  /// Busca um contato pelo seu ID.
  ///
  /// [id] - ID do contato
  Future<ContactModel?> getContactById(String id);

  /// Busca as avaliações de um fornecedor.
  ///
  /// [contactId] - ID do fornecedor
  Future<List<EvaluationModel>> getContactEvaluations(String contactId);

  /// Adiciona uma avaliação ou anotação para o fornecedor.
  ///
  /// [evaluation] - Modelo da avaliação
  Future<void> addEvaluation(EvaluationModel evaluation);
}
