import 'package:agenda/core/di/service_locator.dart';
import 'package:agenda/core/services/update_service.dart';
import 'package:agenda/features/auth/presentation/viewmodel/splash_viewmodel.dart';
import 'package:flutter/material.dart';

/// Tela de apresentação inicial (Splash Screen).
///
/// Fluxo:
/// 1. Exibe animação do logo (FadeIn + Scale).
/// 2. Verifica status de autenticação (Token válido/Biometria?).
/// 3. Redireciona para [Home] ou [Login].
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final SplashViewModel viewModel = getIt<SplashViewModel>();
  late AnimationController _animationController;
  late Animation<double> _fadeLogoAnimation;
  late Animation<double> _scaleLogoAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _fadeLogoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleLogoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _executeSplash();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _executeSplash() async {
    final updateService = getIt<UpdateService>();

    // Mostra o popup de atualização. Se for "obrigatório", ele trava e retorna true.
    final isBlocked = await updateService.checkForUpdates(context);

    // Se for bloqueado por update obrigatório, para por aqui
    if (isBlocked) return;

    final nextRoute = await viewModel.checkLoginStatus();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleLogoAnimation,
              child: FadeTransition(
                opacity: _fadeLogoAnimation,
                child: Image.asset(
                  isDarkMode
                      ? 'assets/images/logo_dark.png'
                      : 'assets/images/logo.png',
                  height: 115,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
