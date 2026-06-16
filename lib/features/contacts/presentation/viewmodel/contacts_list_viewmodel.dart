import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../brands/domain/models/brand_model.dart';
import '../../../brands/domain/repositories/i_brand_repository.dart';
import '../../../products/domain/models/product_model.dart';
import '../../../products/domain/repositories/i_product_repository.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/repositories/i_supplier_repository.dart';

/// ViewModel para listagem de fornecedores.

/// Opções de ordenação da lista de contatos.
enum ContactSortOption {
  /// Ordem alfabética crescente (A-Z)
  alphabetical,

  /// Ordem alfabética decrescente (Z-A)
  alphabeticalReverse,

  /// Adicionados mais recentemente primeiro
  recent,

  /// Adicionados há mais tempo primeiro
  oldest,

  /// Mais acessados (maior [usageCount]) primeiro
  mostFrequent,

  /// Menos acessados (menor [usageCount]) primeiro
  leastFrequent,
}

/// Filtro de status para a lista de contatos.
enum ContactStatusFilter {
  /// Exibe todos os contatos (ativos e inativos)
  all,

  /// Exibe apenas contatos ativos
  active,

  /// Exibe apenas contatos inativos
  inactive,
}

/// ViewModel gerenciador de estado para a listagem de contatos.
///
/// Responsável por:
/// - Buscar contatos do repositório por departamento.
/// - Gerenciar estados de carregamento e erro.
/// - Aplicar lógica de filtros complexos (texto, status, tipos, marcas, produtos).
/// - Gerenciar ordenação e agrupamento alfabético da lista.
class ContactsListViewModel extends ChangeNotifier {
  final ISupplierRepository _repository;
  final IBrandRepository _brandRepository;
  final IProductRepository _productRepository;

  /// Cria o ViewModel injetando os repositórios.
  ContactsListViewModel(
    this._repository,
    this._brandRepository,
    this._productRepository,
  );

  bool isLoading = true;
  String _departmentId = '';
  List<ContactModel> _allContacts = [];
  List<ContactModel> _filteredContacts = [];

  final searchController = TextEditingController();

  // Filtros atuais
  ContactSortOption _sortOption = ContactSortOption.alphabetical;
  ContactStatusFilter _statusFilter = ContactStatusFilter.all;
  bool _filterByEmail = false;
  bool _filterByCnpj = false;
  final Set<String> _selectedTypes = {};

  // Filtros Dropdown
  List<BrandModel> _brands = [];
  List<ProductModel> _products = [];
  String? _selectedBrand;
  String? _selectedProduct;

  ContactSortOption get sortOption => _sortOption;
  ContactStatusFilter get statusFilter => _statusFilter;
  bool get filterByEmail => _filterByEmail;
  bool get filterByCnpj => _filterByCnpj;
  Set<String> get selectedTypes => _selectedTypes;
  List<BrandModel> get brands => _brands;
  List<ProductModel> get products => _products;
  String? get selectedBrand => _selectedBrand;
  String? get selectedProduct => _selectedProduct;

  // Inicializa a tela com o ID do departamento vindo da Home
  Future<void> init(String departmentId) async {
    _departmentId = departmentId;

    // Reseta filtros ao entrar em uma nova lista de contatos
    _sortOption = ContactSortOption.alphabetical;
    _statusFilter = ContactStatusFilter.all;
    _filterByEmail = false;
    _filterByCnpj = false;
    _selectedTypes.clear();
    _selectedBrand = null;
    _selectedProduct = null;
    searchController.clear();

    isLoading = true;
    notifyListeners();

    try {
      _allContacts = await _repository.getByDepartment(_departmentId);

      // Carregar opções de filtro do banco de dados
      await _loadFilterOptions();

      _applyFilters();
    } on ServerException catch (e) {
      debugPrint("Erro na busca: ${e.message}");
    } catch (e) {
      debugPrint("Erro desconhecido: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lógica de Busca (Search)
  void onSearchChanged(String query) {
    _applyFilters();
  }

  /// Define a opção de ordenação atual e reaplica os filtros.
  void setSortOption(ContactSortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  /// Define o filtro de status (Ativo/Inativo/Todos) e reaplica os filtros.
  void setStatusFilter(ContactStatusFilter filter) {
    _statusFilter = filter;
    _applyFilters();
  }

  /// Define filtros avançados (Email e CNPJ preenchidos).
  void setAdvancedFilters({required bool byEmail, required bool byCnpj}) {
    _filterByEmail = byEmail;
    _filterByCnpj = byCnpj;
    _applyFilters();
  }

  /// Alterna a seleção de um tipo de contato (ex: Fornecedor, Representante).
  ///
  /// Permite múltipla seleção.
  void toggleTypeFilter(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    _applyFilters();
  }

  /// Verifica se um tipo de contato está selecionado.
  bool isTypeSelected(String type) => _selectedTypes.contains(type);

  /// Define múltiplos tipos de contato selecionados de uma vez.
  void setTypeFilters(Set<String> types) {
    _selectedTypes.clear();
    _selectedTypes.addAll(types);
    _applyFilters();
  }

  /// Limpa todos os filtros de tipo selecionados.
  void clearTypeFilters() {
    _selectedTypes.clear();
    _applyFilters();
  }

  /// Define o filtro de marca selecionada.
  void setBrandFilter(String? brand) {
    _selectedBrand = brand;
    _applyFilters();
  }

  /// Define o filtro de produto selecionado.
  void setProductFilter(String? product) {
    _selectedProduct = product;
    _applyFilters();
  }

  Future<void> _loadFilterOptions() async {
    try {
      _brands = await _brandRepository.getAllBrands();
    } catch (e) {
      _brands = [];
      debugPrint("Erro ao carregar marcas: $e");
    }
    try {
      _products = await _productRepository.getAllProducts();
    } catch (e) {
      _products = [];
      debugPrint("Erro ao carregar produtos: $e");
    }
    notifyListeners();
  }

  void _applyFilters() {
    List<ContactModel> temp = List.from(_allContacts);

    // 1. Filtro de Texto (Busca)
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      temp = temp.where((s) => s.name.toLowerCase().contains(query)).toList();
    }

    // 2. Filtro de Status
    if (_statusFilter != ContactStatusFilter.all) {
      final bool isActiveFilter = _statusFilter == ContactStatusFilter.active;
      temp = temp.where((s) {
        final supplierActive = s.status.toLowerCase() == 'ativo';
        return supplierActive == isActiveFilter;
      }).toList();
    }

    // 2.1 Filtros Avançados (Email/CNPJ)
    if (_filterByEmail) {
      temp = temp
          .where((s) => s.email != null && s.email!.trim().isNotEmpty)
          .toList();
    }
    if (_filterByCnpj) {
      temp = temp
          .where((s) => s.cnpj != null && s.cnpj!.trim().isNotEmpty)
          .toList();
    }

    // 2.2 Filtro por Tipo
    if (_selectedTypes.isNotEmpty) {
      temp = temp.where((s) {
        final type = s.type.trim().toLowerCase();
        if (type.isEmpty) return false;

        return _selectedTypes.any((selected) {
          final filter = selected.trim().toLowerCase();
          if (filter.startsWith('forneced') && type.startsWith('forneced')) {
            return true;
          }
          if (filter.startsWith('distribui') && type.startsWith('distribui')) {
            return true;
          }
          if (filter.startsWith('transport') && type.startsWith('transport')) {
            return true;
          }
          if (filter.startsWith('representa') &&
              type.startsWith('representa')) {
            return true;
          }
          return type == filter;
        });
      }).toList();
    }

    // 2.3 Filtro por Marca
    if (_selectedBrand != null) {
      temp = temp.where((s) => s.brandIds.contains(_selectedBrand)).toList();
    }

    // 2.4 Filtro por Produto
    if (_selectedProduct != null) {
      temp = temp
          .where((s) => s.productIds.contains(_selectedProduct))
          .toList();
    }

    // 3. Ordenação
    switch (_sortOption) {
      case ContactSortOption.alphabetical:
        temp.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ContactSortOption.alphabeticalReverse:
        temp.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ContactSortOption.recent:
        temp.sort((a, b) {
          final dateA = a.lastUpdate ?? DateTime(0);
          final dateB = b.lastUpdate ?? DateTime(0);
          return dateB.compareTo(dateA); // Decrescente
        });
        break;
      case ContactSortOption.oldest:
        temp.sort((a, b) {
          final dateA = a.lastUpdate ?? DateTime(0);
          final dateB = b.lastUpdate ?? DateTime(0);
          return dateA.compareTo(dateB); // Crescente
        });
        break;
      case ContactSortOption.mostFrequent:
        temp.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case ContactSortOption.leastFrequent:
        temp.sort((a, b) => a.usageCount.compareTo(b.usageCount));
        break;
    }

    _filteredContacts = temp;
    notifyListeners();
  }

  Map<String, List<ContactModel>> get groupedContacts {
    final Map<String, List<ContactModel>> map = {};

    for (var contact in _filteredContacts) {
      if (contact.name.isEmpty) continue;

      final initial = contact.name[0].toUpperCase();
      if (!map.containsKey(initial)) {
        map[initial] = [];
      }
      map[initial]!.add(contact);
    }
    return map;
  }
}
