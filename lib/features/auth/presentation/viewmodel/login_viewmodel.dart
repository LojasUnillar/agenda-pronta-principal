import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';

import '../../domain/repositories/i_auth_repository.dart';
import '../../../../core/services/biometric_service.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/services/connectivity_service.dart';

/// ViewModel responsável pela lógica da tela de Login.
///
/// Gerencia estado de carregamento, autenticação via senha e biometria,
/// além do estado do formulário de autenticação e comunicação com o repositório.
class LoginViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final BiometricService _biometricService;
  final ConnectivityService _connectivityService;

  LoginViewModel(
    this._authRepository,
    this._biometricService,
    this._connectivityService,
  );

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  String? errorMessage;
  bool obscurePassword = true;

  bool canUseBiometrics = false;
  UserModel? storedUser;

  /// Inicializa o ViewModel.
  ///
  /// Verifica:
  /// 1. Conectividade com a internet.
  /// 2. Se há um usuário previamente logado (para exibir saudação).
  /// 3. Suporte do dispositivo para biometria (se houver usuário salvo).
  Future<void> init() async {
    // Verificação imediata para feedback visual
    if (!await _connectivityService.isConnected) {
      errorMessage = 'Sem conexão com a internet';
      // Não retornamos aqui para permitir que a lógica biométrica prossiga (pode se desativar sozinha)
    }

    final user = _authRepository.currentUser;

    if (user != null) {
      storedUser = user;

      loginController.text = user.login;

      final deviceSupported = await _biometricService.isDeviceSupported();

      if (deviceSupported) {
        canUseBiometrics = true;
      } else {
        await _authRepository.logout();
        canUseBiometrics = false;
      }
    } else {
      canUseBiometrics = false;
    }

    notifyListeners();
  }

  /// Tenta realizar autenticação biométrica.
  ///
  /// Requisitos:
  /// - Conectividade ativa.
  /// - Autenticação local bem-sucedida (Face ID / Touch ID).
  /// - Credenciais salvas no SecureStorage.
  Future<bool> authenticateWithBiometrics() async {
    errorMessage = null;
    notifyListeners();

    // Verifica conectividade primeiro
    if (!await _connectivityService.isConnected) {
      errorMessage = 'Sem conexão com a internet';
      notifyListeners();
      return false;
    }

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return false;

    try {
      final credentials = await _authRepository.getStoredCredentials();

      if (credentials == null) {
        throw AuthException(
          'Credenciais não encontradas. Faça login com senha.',
        );
      }

      return await login(login: credentials.$1, password: credentials.$2);
    } on AuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    } on ServerException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Erro inesperado na biometria: $e';
      notifyListeners();
      return false;
    }
  }

  /// Alterna a visibilidade da senha no campo de texto.
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  /// Realiza o login com usuário e senha.
  ///
  /// Se [login] e [password] não forem fornecidos, utiliza os valores dos controllers.
  /// Valida conectividade e campos vazios antes de chamar o repositório.
  Future<bool> login({String? login, String? password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Verifica conectividade
    if (!await _connectivityService.isConnected) {
      errorMessage = 'Sem conexão com a internet';
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final loginInput = login ?? loginController.text.trim();
      final passInput = password ?? passwordController.text.trim();

      if (loginInput.isEmpty || passInput.isEmpty) {
        throw AuthException('Informe o usuário e senha');
      }

      await _authRepository.login(loginInput, passInput);
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } on ServerException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Ocorreu um erro inesperado: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
