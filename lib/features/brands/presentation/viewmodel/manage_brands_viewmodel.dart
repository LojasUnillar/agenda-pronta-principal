import 'package:flutter/material.dart';
import '../../domain/models/brand_model.dart';
import '../../domain/repositories/i_brand_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// ViewModel responsável pela gestão de marcas.
/// 
/// Gerencia o estado da tela de listagem de marcas, incluindo:
/// - Carregamento da lista de marcas
/// - Criação de novas marcas
/// - Edição de marcas existentes
/// - Exclusão de marcas
/// 
/// Comunica-se com [IBrandRepository] para persistência dos dados.
class ManageBrandsViewModel extends ChangeNotifier {
  /// Repositório de marcas injetado via construtor
  final IBrandRepository _repository;

  /// Cria uma nova instância do ViewModel
  /// 
  /// [repository] - Repositório obrigatório para operações de dados
  ManageBrandsViewModel(this._repository);

  /// Indica se está carregando dados do backend
  bool _isLoading = false;
  
  /// Retorna o estado de carregamento atual
  bool get isLoading => _isLoading;

  /// Mensagem de erro em caso de falha nas operações
  String? _errorMessage;
  
  /// Retorna a mensagem de erro atual ou null se não houver erro
  String? get errorMessage => _errorMessage;

  /// Lista de marcas carregadas do backend
  List<BrandModel> _brands = [];
  
  /// Retorna a lista atual de marcas
  List<BrandModel> get brands => _brands;

  /// Carrega todas as marcas do repositório
  /// 
  /// Atualiza [_brands] com os dados do backend e notifica listeners.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  /// Define [_isLoading] como true durante a operação.
  Future<void> loadBrands() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _brands = await _repository.getAllBrands();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao carregar marcas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria uma nova marca
  /// 
  /// [name] - Nome da marca a ser criada
  /// 
  /// Após criação bem-sucedida, recarrega a lista de marcas.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> createBrand(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createBrand(name);
      await loadBrands();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao criar marca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza uma marca existente
  /// 
  /// [id] - Identificador da marca a ser atualizada
  /// [name] - Novo nome da marca
  /// 
  /// Após atualização bem-sucedida, recarrega a lista de marcas.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> updateBrand(String id, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateBrand(id, name);
      await loadBrands();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar marca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui uma marca
  /// 
  /// [id] - Identificador da marca a ser excluída
  /// 
  /// Após exclusão bem-sucedida, recarrega a lista de marcas.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> deleteBrand(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteBrand(id);
      await loadBrands();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao excluir marca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
