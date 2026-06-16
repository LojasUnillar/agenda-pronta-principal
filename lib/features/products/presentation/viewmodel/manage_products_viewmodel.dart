import 'package:flutter/material.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// ViewModel responsável pela gestão de produtos.
/// 
/// Gerencia o estado da tela de listagem de produtos, incluindo:
/// - Carregamento da lista de produtos
/// - Criação de novos produtos
/// - Edição de produtos existentes
/// - Exclusão de produtos
/// 
/// Comunica-se com [IProductRepository] para persistência dos dados.
class ManageProductsViewModel extends ChangeNotifier {
  /// Repositório de produtos injetado via construtor
  final IProductRepository _repository;

  /// Cria uma nova instância do ViewModel
  /// 
  /// [repository] - Repositório obrigatório para operações de dados
  ManageProductsViewModel(this._repository);

  /// Indica se está carregando dados do backend
  bool _isLoading = false;
  
  /// Retorna o estado de carregamento atual
  bool get isLoading => _isLoading;

  /// Mensagem de erro em caso de falha nas operações
  String? _errorMessage;
  
  /// Retorna a mensagem de erro atual ou null se não houver erro
  String? get errorMessage => _errorMessage;

  /// Lista de produtos carregados do backend
  List<ProductModel> _products = [];
  
  /// Retorna a lista atual de produtos
  List<ProductModel> get products => _products;

  /// Carrega todos os produtos do repositório
  /// 
  /// Atualiza [_products] com os dados do backend e notifica listeners.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  /// Define [_isLoading] como true durante a operação.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao carregar produtos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria um novo produto
  /// 
  /// [name] - Nome do produto a ser criado
  /// 
  /// Após criação bem-sucedida, recarrega a lista de produtos.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> createProduct(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createProduct(name);
      await loadProducts();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao criar produto: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza um produto existente
  /// 
  /// [id] - Identificador do produto a ser atualizado
  /// [name] - Novo nome do produto
  /// 
  /// Após atualização bem-sucedida, recarrega a lista de produtos.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> updateProduct(String id, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProduct(id, name);
      await loadProducts();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar produto: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui um produto
  /// 
  /// [id] - Identificador do produto a ser excluído
  /// 
  /// Após exclusão bem-sucedida, recarrega a lista de produtos.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      await loadProducts();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao excluir produto: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
