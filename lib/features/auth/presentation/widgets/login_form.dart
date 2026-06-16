import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../viewmodel/login_viewmodel.dart';

/// Widget responsável pelo formulário de Login.
///
/// Contém os campos de usuário e senha, e opcionalmente o botão de biometria.
/// Gerencia a interação do usuário com o [LoginViewModel].
class LoginForm extends StatelessWidget {
  /// Callback executado após a tentativa de login (seja por senha ou biometria).
  final Function(bool) onLoginResult;

  /// Cria o formulário de login.
  ///
  /// [onLoginResult] é obrigatório para decidir o redirecionamento após o login.
  const LoginForm({super.key, required this.onLoginResult});

  @override
  Widget build(BuildContext context) {
    // Acesso ao ViewModel via Consumer para atualizações granulares de estado
    return Consumer<LoginViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            // Campo de usuário
            AppTextField(
              controller: vm.loginController,
              label: 'Usuário',
              hint: 'Digite seu Usuário...',
              prefixIcon: Icons.person_outlined,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Campo de senha
            AppTextField(
              controller: vm.passwordController,
              label: 'Senha',
              hint: 'Digite sua Senha...',
              prefixIcon: Icons.password_outlined,
              obscureText: vm.obscurePassword,
              autofillHints: const [AutofillHints.password],
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) async => onLoginResult(await vm.login()),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: vm.togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 24),

            // Botão de login
            AppButton(
              label: vm.canUseBiometrics ? "ENTRAR COM SENHA" : "ENTRAR",
              onPressed: () async => onLoginResult(await vm.login()),
              isLoading: vm.isLoading,
            ),

            // Seção de biometria (quando disponível)
            if (vm.canUseBiometrics) ...[
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OU", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async =>
                    onLoginResult(await vm.authenticateWithBiometrics()),
                icon: const Icon(Icons.fingerprint, size: 30),
                label: const Text('Entrar com biometria'),
              ),
            ],
          ],
        );
      },
    );
  }
}
