import 'dart:io';
import 'package:agenda/core/errors/exceptions.dart';
import 'package:agenda/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/role_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// ViewModel responsável pela criação de novos usuários.
/// Gerencia formulário, upload de avatar e atribuição de cargos.
/// ViewModel para criação de novos perfis de usuário.
/// Gerencia formulário de cadastro, validação e chamada ao repositório.
class CreateProfileViewModel extends ChangeNotifier {
  final IProfileRepository _repository;
  final IAuthRepository _authRepository;

  CreateProfileViewModel(this._repository, this._authRepository);

  // Controllers
  final nameController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  // Edit state
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String? _userId;
  UserModel? get user => _authRepository.currentUser;

  bool _isActive = true;
  bool get isActive => _isActive;

  // Roles
  bool _isLoadingRoles = false;
  bool get isLoadingRoles => _isLoadingRoles;

  List<RoleModel> _rolesFromDb = [];
  List<RoleModel> get rolesFromDb => _rolesFromDb;

  String? _selectedRoleId;
  String? get selectedRoleId => _selectedRoleId;

  // Avatar (uma única fonte de verdade)
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  void setAvatarUrl(String? url) {
    _avatarUrl = (url?.trim().isEmpty ?? true) ? null : url!.trim();
    notifyListeners();
  }

  void removeAvatar() {
    _selectedImage = null;
    _avatarUrl = null; // Envia null para limpar
    notifyListeners();
  }

  // Init
  void init(UserModel? user) {
    _errorMessage = null;

    if (user != null) {
      _isEditing = true;
      _userId = user.id;

      nameController.text = user.name;
      loginController.text = user.login;

      _avatarUrl = (user.avatarUrl?.trim().isNotEmpty ?? false)
          ? user.avatarUrl!.trim()
          : null;
      _selectedImage = null;

      _isActive = user.isActive;

      final roleName = user.roles.whereType<String>().isNotEmpty
          ? user.roles.whereType<String>().first
          : null;

      passwordController.clear();
      loadRoles(userRoleName: roleName);
    } else {
      _isEditing = false;
      _userId = null;

      nameController.clear();
      loginController.clear();
      passwordController.clear();

      _isActive = true;
      _selectedRoleId = null;

      _avatarUrl = null;
      _selectedImage = null;

      loadRoles();
    }

    notifyListeners();
  }

  Future<void> loadRoles({String? userRoleName}) async {
    _isLoadingRoles = true;
    notifyListeners();

    try {
      _rolesFromDb = await _repository.getRoles();

      if (userRoleName != null && (_selectedRoleId == null)) {
        final match = _rolesFromDb
            .where((r) => r.name == userRoleName)
            .toList();
        if (match.isNotEmpty) {
          _selectedRoleId = match.first.id;
        }
      }
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao carregar cargos: $e';
    } finally {
      _isLoadingRoles = false;
      notifyListeners();
    }
  }

  void setRoleId(String? id) {
    _selectedRoleId = id;
    notifyListeners();
  }

  void setActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      _selectedImage = File(picked.path);

      _avatarUrl = null;

      notifyListeners();
    }
  }

  Future<bool> save() async {
    _errorMessage = null;

    final name = nameController.text.trim();
    final login = loginController.text.trim();
    final pass = passwordController.text.trim();

    if (_selectedRoleId == null || _selectedRoleId!.isEmpty) {
      _errorMessage = 'Selecione um tipo de usuário.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1) Create ou Update
      if (_isEditing) {
        final userModel = UserModel(
          id: _userId!,
          name: name,
          login: login,
          token: '',
          roles: const [],
          permissions: const [],
          avatarUrl: _avatarUrl,
        );

        await _repository.updateUser(
          userModel,
          password: pass.isEmpty ? null : pass,
          roleId: _selectedRoleId!,
          isActive: _isActive,
        );
      } else {
        final userModel = UserModel(
          id: '',
          name: name,
          login: login,
          token: '',
          roles: const [],
          permissions: const [],
          avatarUrl: null,
        );

        final id = await _repository.createUserReturningId(
          userModel,
          pass,
          roleId: _selectedRoleId!,
          isActive: _isActive,
        );

        _userId = id;
      }

      // 2) Avatar (serve para create e edit)
      if (_selectedImage != null && _userId != null && _userId!.isNotEmpty) {
        final avatarUrl = await _authRepository.uploadAvatarImage(
          _selectedImage!,
          _userId!,
        );

        await _repository.updateUserAvatar(
          userId: _userId!,
          avatarUrl: avatarUrl,
        );

        _avatarUrl = avatarUrl;
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado ao salvar perfil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
