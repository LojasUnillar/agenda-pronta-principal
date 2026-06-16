import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/login_form.dart';

/// Tela de Login da aplicação.
///
/// Responsabilidades:
/// - Exibir formulário de credenciais (E-mail e Senha).
/// - Exibir feedback de erro em caso de falha.
/// - Suporte à funcionalidade de "Lembrar usuário" (exibindo mensagem de boas-vindas).
/// - Gerenciar o preenchimento automático ([AutofillGroup]).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginViewModel viewModel = getIt<LoginViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.init();
  }

  void _handleLoginResult(bool success) {
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            body: SafeArea(
              child: Consumer<LoginViewModel>(
                builder: (context, vm, child) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              isDarkMode
                                  ? 'assets/images/logo_dark.png'
                                  : 'assets/images/logo.png',
                              height: 100,
                            ),

                            if (vm.storedUser != null) ...[
                              Column(
                                children: [
                                  Text(
                                    "Olá, ${vm.storedUser?.name ?? 'Usuário'}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Seja bem vindo(a) de volta!",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ] else ...[
                              const SizedBox(height: 20),
                            ],

                            if (vm.errorMessage != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  vm.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 15),
                            ],

                            LoginForm(onLoginResult: _handleLoginResult),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.register),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: const [
                                    TextSpan(text: 'Não tem uma conta? '),
                                    TextSpan(
                                      text: 'Criar Conta',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
