import 'dart:io';
import 'package:agenda/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../auth/domain/models/user_model.dart';

/// ViewModel para edição do perfil do usuário logado.
/// Permite alterar nome, senha e avatar.
/// ViewModel para edição de perfis existentes.
/// Carrega dados do usuário, permite alterações e salva no banco.
class EditProfileViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  EditProfileViewModel(this._authRepository);

  final nameController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  bool obscurePassword = true;

  UserModel? get user => _authRepository.currentUser;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  bool _isImageRemoved = false;
  bool get isImageRemoved => _isImageRemoved;

  void init(UserModel user) {
    nameController.text = user.name;
    loginController.text = user.login;
    passwordController.clear();
    _selectedImage = null;
    _isImageRemoved = false;
    errorMessage = null;
    obscurePassword = true;
  }

  int _avatarVersion = DateTime.now().millisecondsSinceEpoch;

  String? get userAvatarUrl {
    if (_isImageRemoved) return null;
    final url = user?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    return url.contains('?')
        ? '$url&v=$_avatarVersion'
        : '$url?v=$_avatarVersion';
  }

  void bumpAvatarVersion() {
    _avatarVersion = DateTime.now().millisecondsSinceEpoch;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _selectedImage = File(image.path);
        _isImageRemoved = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  void removeAvatar() {
    _selectedImage = null;
    _isImageRemoved = true;
    notifyListeners();
  }

  Future<bool> saveProfile(UserModel currentUser) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? finalAvatarUrl;

      // 1. Se selecionou nova imagem, faz upload
      if (_selectedImage != null) {
        finalAvatarUrl = await _authRepository.uploadAvatarImage(
          _selectedImage!,
          currentUser.id,
        );
      }
      // 2. Se removeu imagem, define como "" (string vazia) para limpar no banco
      else if (_isImageRemoved) {
        finalAvatarUrl = null;
      }
      // 3. Caso contrário, mantém a atual
      else {
        finalAvatarUrl = currentUser.avatarUrl;
      }

      final nameInput = nameController.text.trim();
      final loginInput = loginController.text.trim();
      final passInput = passwordController.text.trim();

      await _authRepository.updateProfile(
        userId: currentUser.id,
        name: nameInput,
        login: loginInput,
        password: passInput.isNotEmpty ? passInput : null,
        avatarUrl: finalAvatarUrl,
        token: currentUser.token,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } on ServerException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Erro inesperado: $e';
      isLoading = false;
      notifyListeners();
      return false;
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
