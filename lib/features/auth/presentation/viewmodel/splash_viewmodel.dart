import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../app/app_routes.dart';

/// ViewModel da Splash Screen.
/// Verifica se existe uma sessão válida ao abrir o app e redireciona o usuário.
class SplashViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final ConnectivityService _connectivityService;

  SplashViewModel(this._authRepository, this._connectivityService);

  bool isLoading = false;

  /// Verifica o status atual da sessão de login.
  ///
  /// 1. Verifica conectividade (redireciona para Login se offline).
  /// 2. Valida a sessão no repositório ([AuthRepository]).
  /// 3. Aguarda um delay mínimo para exibição da marca.
  ///
  /// Retorna a rota de destino: [AppRoutes.home] se válido, [AppRoutes.login] caso contrário.
  Future<String> checkLoginStatus() async {
    isLoading = true;
    notifyListeners();

    // Verifica a conectividade primeiro
    if (!await _connectivityService.isConnected) {
      debugPrint("Splash: Sem conectividade. Redirecionando para Login.");
      isLoading = false;
      notifyListeners();
      return AppRoutes.login;
    }

    final isValid = await _authRepository.isSessionValid();

    await Future.delayed(const Duration(seconds: 3));

    isLoading = false;
    notifyListeners();

    return isValid ? AppRoutes.home : AppRoutes.login;
  }
}
