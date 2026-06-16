import 'package:agenda/app/app_routes.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/models/contact_model.dart';
import '../../domain/models/department_args.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../departments/domain/models/department_model.dart';
import '../../../departments/domain/repositories/i_department_repository.dart';
import '../../domain/repositories/i_supplier_repository.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../brands/domain/models/brand_model.dart';
import '../../../brands/domain/repositories/i_brand_repository.dart';
import '../../../products/domain/models/product_model.dart';
import '../../../products/domain/repositories/i_product_repository.dart';
import '../../../notifications/domain/repositories/i_notification_repository.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/constants/app_permissions.dart';

/// ViewModel responsável pelo cadastro e edição de contatos.
///
/// Gerencia o fluxo completo de registro de fornecedores, representantes,
/// distribuidoras e transportadoras.
///
/// Funcionalidades:
/// - Cadastro em duas etapas: informações básicas e adicionais
/// - Validação de CNPJ/CPF com verificação de duplicidade
/// - Seleção de departamentos, marcas, produtos e representantes
/// - Suporte a edição de contatos existentes
/// - Gerenciamento de múltiplos telefones (assistência, devolução, financeiro)
///
/// Comunica-se com múltiplos repositórios:
/// - [IDepartmentRepository] para departamentos
/// - [ISupplierRepository] para persistência de contatos
/// - [IBrandRepository] para marcas disponíveis
/// - [IProductRepository] para produtos disponíveis
class ContactRegistrationViewModel extends ChangeNotifier {
  // --- Repositórios ---
  final IDepartmentRepository _departmentRepository;
  final ISupplierRepository _supplierRepository;
  final IBrandRepository _brandRepository;
  final IProductRepository _productRepository;
  final INotificationRepository _notificationRepository;
  final IProfileRepository _profileRepository;

  // --- Constants/Finals ---
  final String registrationType;
  final ContactModel? contactToEdit;
  final GlobalKey<FormState> basicInfoFormKey = GlobalKey<FormState>();

  // --- Controllers (Basic Info) ---
  final nameController = TextEditingController();
  final socialNameController = TextEditingController();
  final cnpjController = TextEditingController();
  final emailController = TextEditingController();
  final boletoSiteController = TextEditingController();
  final regionController = TextEditingController();
  final addressController = TextEditingController();

  // --- Controllers (Additional Info) ---
  final birthdayController = TextEditingController();
  final personalityController = TextEditingController();
  final spouseNameController = TextEditingController();
  final childrenNamesController = TextEditingController();
  final turnoverCodeController = TextEditingController();
  final minDeliveryTimeController = TextEditingController();
  final billingTimeController = TextEditingController();
  final tenureValueController = TextEditingController();
  final tenureUnitController = TextEditingController(text: 'Anos');
  final mainSiteController = TextEditingController();

  // --- Estado Interno ---
  bool _isLoading = false; // Indica operação em andamento (salvar/carregar)
  bool _isLoadingDependencies = false; // Indica carregamento inicial de deps
  String? _errorMessage; // Mensagem de erro para feedback
  int _currentStep = 0; // Etapa atual do Stepper (0: Básico, 1: Adicional)
  Timer? _cnpjDebounce; // Timer para debounce da validação de CNPJ
  String? _cnpjError; // Erro específico de validação de CNPJ

  // --- Toggles ---
  bool _isMarried = false;
  bool _hasChildrenGroup = false;
  bool _hasAssistance = false;
  bool _hasInvoice = false;
  bool _hasBoletoSite = false;
  bool _hasDevolucao = false;

  // --- Collections (Selections) ---
  Set<String> _selectedDepartmentIds = {};
  Set<String> _selectedRepresentativeIds = {};
  Set<String> _selectedBrandIds = {};
  Set<String> _selectedProductIds = {};

  // --- Collections (Data loaded from backend) ---
  List<BrandModel> _availableBrands = [];
  List<ProductModel> _availableProducts = [];
  List<DepartmentModel> _departments = [];
  List<ContactModel> _representatives = [];
  List<ContactModel> _suppliersAndDistributors = [];

  // --- Phone Lists ---
  final List<String> _assistancePhones = [''];
  final List<String> _devolucaoPhones = [''];
  final List<String> _financeiroPhones = [''];

  // --- Getters ---
  bool get isEditing => contactToEdit != null;
  bool get isLoading => _isLoading;
  bool get isLoadingDependencies => _isLoadingDependencies;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;
  String? get cnpjError => _cnpjError;

  bool get isMarried => _isMarried;
  bool get hasChildrenGroup => _hasChildrenGroup;
  bool get hasAssistance => _hasAssistance;
  bool get hasInvoice => _hasInvoice;
  bool get hasBoletoSite => _hasBoletoSite;
  bool get hasDevolucao => _hasDevolucao;

  Set<String> get selectedDepartmentIds => _selectedDepartmentIds;
  Set<String> get selectedRepresentativeIds => _selectedRepresentativeIds;
  Set<String> get selectedBrandIds => _selectedBrandIds;
  Set<String> get selectedProductIds => _selectedProductIds;

  List<BrandModel> get availableBrands => _availableBrands;
  List<ProductModel> get availableProducts => _availableProducts;
  List<DepartmentModel> get departments => _departments;
  List<ContactModel> get representatives => _representatives;
  List<ContactModel> get suppliersAndDistributors => _suppliersAndDistributors;

  List<String> get assistancePhones => _assistancePhones;
  List<String> get devolucaoPhones => _devolucaoPhones;
  List<String> get financeiroPhones => _financeiroPhones;

  /// Cria uma nova instância do ViewModel.
  ///
  /// Injeta os repositórios necessários e inicia o carregamento de
  /// dependências (marcas, produtos, departamentos).
  /// Se houver um [contactToEdit], preenche os formulários para edição.
  ContactRegistrationViewModel({
    required this.registrationType,
    required IDepartmentRepository departmentRepository,
    required ISupplierRepository supplierRepository,
    required IBrandRepository brandRepository,
    required IProductRepository productRepository,
    INotificationRepository? notificationRepository,
    IProfileRepository? profileRepository,
    this.contactToEdit,
  })  : _departmentRepository = departmentRepository,
        _supplierRepository = supplierRepository,
        _brandRepository = brandRepository,
        _productRepository = productRepository,
        _notificationRepository =
            notificationRepository ?? getIt<INotificationRepository>(),
        _profileRepository = profileRepository ?? getIt<IProfileRepository>() {
    if (isEditing) {
      _initializeEditMode();
    }
    loadDependencies();
  }

  /// Inicializa o formulário com os dados do contato em edição
  void _initializeEditMode() {
    final contact = contactToEdit!;
    nameController.text = contact.name;
    socialNameController.text = contact.socialName ?? '';
    cnpjController.text = contact.cnpj ?? '';
    emailController.text = contact.email ?? '';
    addressController.text = contact.address ?? '';

    _selectedDepartmentIds = Set.from(contact.departments);
    _selectedRepresentativeIds = Set.from(contact.representativeIds);
    _selectedBrandIds = Set.from(contact.brandIds);
    _selectedProductIds = Set.from(contact.productIds);

    turnoverCodeController.text = contact.turnoverCode ?? '';
    minDeliveryTimeController.text = contact.minDeliveryTime ?? '';
    billingTimeController.text = contact.billingTime ?? '';
    tenureValueController.text = contact.tenureValue?.toString() ?? '';
    tenureUnitController.text = contact.tenureUnit ?? 'Anos';
    mainSiteController.text = contact.mainSite ?? '';

    _hasAssistance = contact.hasAssistance;
    _assistancePhones.clear();
    if (contact.assistancePhones.isNotEmpty) {
      _assistancePhones.addAll(contact.assistancePhones);
    } else {
      _assistancePhones.add('');
    }

    _devolucaoPhones.clear();
    if (contact.devolucaoPhones.isNotEmpty) {
      _devolucaoPhones.addAll(contact.devolucaoPhones);
    } else {
      _devolucaoPhones.add('');
    }

    _financeiroPhones.clear();
    if (contact.financeiroPhones.isNotEmpty) {
      _financeiroPhones.addAll(contact.financeiroPhones);
    } else {
      _financeiroPhones.add('');
    }

    _hasBoletoSite = contact.hasBoletoSite;
    boletoSiteController.text = contact.boletoSiteLink ?? '';
    regionController.text = contact.regionOfActivity ?? '';
    birthdayController.text = contact.birthday ?? '';
    personalityController.text = contact.personality ?? '';
    _isMarried = contact.isMarried ?? false;
    spouseNameController.text = contact.spouseName ?? '';
    _hasChildrenGroup = contact.hasChildren ?? false;
    childrenNamesController.text = contact.childrenNames ?? '';

    // Additional toggles specific properties
    _hasInvoice = contact.hasInvoice;
    _hasDevolucao =
        contact.devolucaoPhones.isNotEmpty; // Usually consistent with flag
  }

  /// Callback executado quando o CNPJ/CPF é alterado.
  ///
  /// Implementa um debounce de 500ms para evitar chamadas excessivas.
  /// Realiza validações:
  /// 1. Formato (CPF 11 dígitos ou CNPJ 14 dígitos).
  /// 2. Validação de algoritmo de CPF/CNPJ.
  /// 3. Verificação de duplicidade no backend via [_supplierRepository].
  void onCnpjChanged(String value) {
    if (_cnpjDebounce?.isActive ?? false) _cnpjDebounce!.cancel();
    _cnpjError = null;
    notifyListeners();

    if (value.isEmpty) return;

    _cnpjDebounce = Timer(const Duration(milliseconds: 500), () async {
      final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

      bool isValid = false;
      String docLabel = 'Documento';

      if (cleanValue.length == 11) {
        isValid = AppValidators.isValidCPF(value);
        docLabel = 'CPF';
      } else if (cleanValue.length == 14) {
        isValid = AppValidators.isValidCNPJ(value);
        docLabel = 'CNPJ';
      }

      if (!isValid) {
        _cnpjError = '$docLabel inválido.';
        notifyListeners();
        return;
      }

      try {
        final exists = await _supplierRepository.checkCnpjExists(value);
        if (exists) {
          _cnpjError = '$docLabel já cadastrado.';
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Erro ao validar $docLabel: $e');
      }
    });
  }

  /// Libera recursos do ViewModel
  @override
  void dispose() {
    _cnpjDebounce?.cancel();
    nameController.dispose();
    socialNameController.dispose();
    cnpjController.dispose();
    emailController.dispose();
    boletoSiteController.dispose();
    regionController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    personalityController.dispose();
    spouseNameController.dispose();
    childrenNamesController.dispose();
    turnoverCodeController.dispose();
    minDeliveryTimeController.dispose();
    billingTimeController.dispose();
    tenureValueController.dispose();
    tenureUnitController.dispose();
    mainSiteController.dispose();
    super.dispose();
  }

  /// Carrega todas as dependências necessárias para o formulário.
  ///
  /// Busca em paralelo:
  /// - Departamentos ativos.
  /// - Representantes ou Fornecedores (dependendo do tipo de cadastro).
  /// - Marcas disponíveis.
  /// - Produtos disponíveis.
  ///
  /// Em caso de erro parcial, acumula os erros e exibe uma mensagem unificada.
  Future<void> loadDependencies() async {
    _isLoadingDependencies = true;
    _errorMessage = null;
    notifyListeners();

    final List<String> errors = [];

    try {
      _departments = await _departmentRepository.getActiveDepartments();
    } catch (e) {
      debugPrint('Erro ao carregar departamentos: $e');
      errors.add('Departamentos');
    }

    try {
      if (registrationType.contains('Representante')) {
        _suppliersAndDistributors =
            await _supplierRepository.getSuppliersAndDistributors();
      } else {
        _representatives = await _supplierRepository.getRepresentatives();
      }
    } catch (e) {
      debugPrint('Erro ao carregar vínculos: $e');
      errors.add('Vínculos');
    }

    try {
      _availableBrands = await _brandRepository.getAllBrands();
    } catch (e) {
      debugPrint('Erro ao carregar marcas: $e');
      errors.add('Marcas');
    }

    try {
      _availableProducts = await _productRepository.getAllProducts();
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      errors.add('Produtos');
    }

    if (errors.isNotEmpty) {
      _errorMessage = 'Erro ao carregar: ${errors.join(", ")}';
    }

    _isLoadingDependencies = false;
    notifyListeners();
  }

  /// Altera a etapa atual do formulário
  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  /// Alterna o estado de assistência técnica
  void toggleAssistance(bool value) {
    _hasAssistance = value;
    notifyListeners();
  }

  /// Alterna o estado de nota fiscal
  void toggleInvoice(bool value) {
    _hasInvoice = value;
    notifyListeners();
  }

  /// Alterna o estado de site para boleto
  void toggleBoletoSite(bool value) {
    _hasBoletoSite = value;
    notifyListeners();
  }

  /// Alterna o estado de telefone de devolução
  void toggleDevolucao(bool value) {
    _hasDevolucao = value;
    notifyListeners();
  }

  /// Atualiza a unidade de tempo de empresa
  void updateTenureUnit(String value) {
    tenureUnitController.text = value;
    notifyListeners();
  }

  /// Alterna o estado civil do representante
  void toggleMarried(bool value) {
    _isMarried = value;
    notifyListeners();
  }

  /// Alterna se possui filhos
  void toggleChildren(bool value) {
    _hasChildrenGroup = value;
    notifyListeners();
  }

  // --- Gerenciamento de Telefones ---

  void updateAssistancePhone(int index, String value) {
    if (index >= 0 && index < _assistancePhones.length) {
      _assistancePhones[index] = value;
    }
  }

  void addAssistancePhone() {
    _assistancePhones.add('');
    notifyListeners();
  }

  void removeAssistancePhone(int index) {
    if (_assistancePhones.length > 1) {
      _assistancePhones.removeAt(index);
      notifyListeners();
    }
  }

  void updateDevolucaoPhone(int index, String value) {
    if (index >= 0 && index < _devolucaoPhones.length) {
      _devolucaoPhones[index] = value;
    }
  }

  void addDevolucaoPhone() {
    _devolucaoPhones.add('');
    notifyListeners();
  }

  void removeDevolucaoPhone(int index) {
    if (_devolucaoPhones.length > 1) {
      _devolucaoPhones.removeAt(index);
      notifyListeners();
    }
  }

  void updateFinanceiroPhone(int index, String value) {
    if (index >= 0 && index < _financeiroPhones.length) {
      _financeiroPhones[index] = value;
    }
  }

  void addFinanceiroPhone() {
    _financeiroPhones.add('');
    notifyListeners();
  }

  void removeFinanceiroPhone(int index) {
    if (_financeiroPhones.length > 1) {
      _financeiroPhones.removeAt(index);
      notifyListeners();
    }
  }

  // --- Setters de Seleção ---

  void toggleDepartment(String id) {
    if (_selectedDepartmentIds.contains(id)) {
      _selectedDepartmentIds.remove(id);
    } else {
      _selectedDepartmentIds.add(id);
    }
    notifyListeners();
  }

  void toggleRepresentative(String id) {
    if (_selectedRepresentativeIds.contains(id)) {
      _selectedRepresentativeIds.remove(id);
    } else {
      _selectedRepresentativeIds.add(id);
    }
    notifyListeners();
  }

  void toggleBrand(String id) {
    if (_selectedBrandIds.contains(id)) {
      _selectedBrandIds.remove(id);
    } else {
      _selectedBrandIds.add(id);
    }
    notifyListeners();
  }

  void toggleProduct(String id) {
    if (_selectedProductIds.contains(id)) {
      _selectedProductIds.remove(id);
    } else {
      _selectedProductIds.add(id);
    }
    notifyListeners();
  }

  // --- Navegação e Submissão ---

  /// Valida o formulário básico e avança para a próxima etapa.
  void submitBasicInfo(BuildContext context) {
    if (basicInfoFormKey.currentState?.validate() ?? false) {
      setStep(1);
    }
  }

  /// Submete o cadastro completo (criação ou edição).
  ///
  /// 1. Coleta dados de todos os controllers e toggles.
  /// 2. Monta o objeto [ContactModel].
  /// 3. Chama [createContact] ou [updateContact] no repositório.
  /// 4. Exibe feedback de sucesso ou erro (via SnackBar).
  /// 5. Navega de volta para a lista em caso de sucesso.
  Future<void> submitFullRegistration(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newContact = ContactModel(
        id: '',
        name: nameController.text.trim(),
        socialName: socialNameController.text.trim(),
        cnpj: cnpjController.text.trim(),
        email: emailController.text.trim(),
        departments: selectedDepartmentIds.toList(),
        representativeIds: selectedRepresentativeIds.toList(),
        brandIds: selectedBrandIds.toList(),
        productIds: selectedProductIds.toList(),
        type: registrationType,
        status: 'Ativo',
        turnoverCode: turnoverCodeController.text.trim(),
        minDeliveryTime: minDeliveryTimeController.text.trim(),
        billingTime: billingTimeController.text.trim(),
        tenureValue: int.tryParse(tenureValueController.text.trim()),
        tenureUnit: tenureUnitController.text.trim(),
        hasAssistance: hasAssistance,
        assistancePhones: assistancePhones.where((p) => p.isNotEmpty).toList(),
        devolucaoPhones: devolucaoPhones.where((p) => p.isNotEmpty).toList(),
        financeiroPhones: financeiroPhones.where((p) => p.isNotEmpty).toList(),
        outroPhones: contactToEdit?.outroPhones ?? [],
        outroLabel: contactToEdit?.outroLabel,
        hasInvoice: hasInvoice,
        mainSite: mainSiteController.text.trim(),
        hasBoletoSite: hasBoletoSite,
        boletoSiteLink: boletoSiteController.text.trim(),
        regionOfActivity: regionController.text.trim(),
        birthday: birthdayController.text.trim(),
        personality: personalityController.text.trim(),
        isMarried: isMarried,
        spouseName: spouseNameController.text.trim(),
        hasChildren: hasChildrenGroup,
        childrenNames: childrenNamesController.text.trim(),
        address: addressController.text.trim(),
      );

      if (isEditing) {
        final updatedContact = ContactModel(
          id: contactToEdit!.id,
          name: newContact.name,
          socialName: newContact.socialName,
          cnpj: newContact.cnpj,
          departments: newContact.departments,
          representativeIds: newContact.representativeIds,
          brandIds: newContact.brandIds,
          productIds: newContact.productIds,
          type: newContact.type,
          status: contactToEdit!.status,
          turnoverCode: newContact.turnoverCode,
          minDeliveryTime: newContact.minDeliveryTime,
          billingTime: newContact.billingTime,
          tenureValue: newContact.tenureValue,
          tenureUnit: newContact.tenureUnit,
          hasAssistance: newContact.hasAssistance,
          assistancePhones: newContact.assistancePhones,
          devolucaoPhones: newContact.devolucaoPhones,
          financeiroPhones: newContact.financeiroPhones,
          outroPhones: newContact.outroPhones,
          outroLabel: newContact.outroLabel,
          hasInvoice: newContact.hasInvoice,
          mainSite: newContact.mainSite,
          hasBoletoSite: newContact.hasBoletoSite,
          boletoSiteLink: newContact.boletoSiteLink,
          email: newContact.email,
          regionOfActivity: newContact.regionOfActivity,
          birthday: newContact.birthday,
          personality: newContact.personality,
          isMarried: newContact.isMarried,
          spouseName: newContact.spouseName,
          hasChildren: newContact.hasChildren,
          childrenNames: newContact.childrenNames,
          address: newContact.address,
        );
        await _supplierRepository.updateContact(updatedContact);

        // --- Notificar usuários com permissão de update ---
        _sendNotificationsToPermission(
          permissionCode: AppPermissions.receiveContactUpdateNotif,
          title: '${updatedContact.type} atualizado',
          body: '${updatedContact.name} foi atualizado.',
        );

        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Contato atualizado com sucesso!',
          );
        }
      } else {
        await _supplierRepository.createContact(newContact);

        // --- Notificar usuários com permissão de novo contato ---
        _sendNotificationsToPermission(
          permissionCode: AppPermissions.receiveNewContactNotif,
          title: 'Novo ${newContact.type} adicionado',
          body: '${newContact.name} foi adicionado à agenda.',
        );

        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Cadastro realizado com sucesso!',
          );
        }
      }

      if (!context.mounted) return;

      String deptName = 'Departamento';
      if (_selectedDepartmentIds.isNotEmpty) {
        final dept = _departments.firstWhere(
          (d) => d.id == _selectedDepartmentIds.first,
          orElse: () => DepartmentModel(id: '', code: '', name: 'Departamento'),
        );
        deptName = dept.name;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.searchContacts,
        (route) => route.settings.name == AppRoutes.home,
        arguments: DepartmentArgs(
          id: selectedDepartmentIds.isNotEmpty
              ? selectedDepartmentIds.first
              : '',
          name: deptName,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      String msg = 'Erro ao cadastrar: $e';
      if (e.toString().contains('23505')) {
        if (e.toString().contains('codigo_erp_key')) {
          msg = 'Código ERP já cadastrado.';
        } else if (e.toString().contains('cnpj_key')) {
          msg = 'CNPJ já cadastrado.';
        }
      }

      CustomSnackBar.showError(context, msg);
    } finally {
      if (hasListeners) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Envia notificações para todos os usuários que têm uma permissão específica.
  ///
  /// [permissionCode] - Código da permissão (AppPermissions)
  /// [title] - Título da notificação
  /// [body] - Corpo da mensagem
  void _sendNotificationsToPermission({
    required String permissionCode,
    required String title,
    required String body,
  }) {
    // Executa em background sem bloquear o fluxo principal
    Future(() async {
      try {
        final userIds = await _profileRepository.getUserIdsByPermission(
          permissionCode,
        );
        for (final userId in userIds) {
          await _notificationRepository.createNotification(
            userId: userId,
            title: title,
            body: body,
          );
        }
        debugPrint(
          'Notificações enviadas para ${userIds.length} usuário(s) com permissão "$permissionCode"',
        );
      } catch (e) {
        debugPrint(
          'Erro ao enviar notificações para permissão "$permissionCode": \$e',
        );
      }
    });
  }
}
