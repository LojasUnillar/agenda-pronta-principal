import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../viewmodel/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel viewModel = getIt<RegisterViewModel>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text("Criar Conta"), centerTitle: true),
        body: Consumer<RegisterViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vm.errorMessage != null)
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

                  AppTextField(
                    controller: vm.nameController,
                    label: "Nome Completo",
                    hint: "Digite seu nome",
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: vm.emailController,
                    label: "E-mail",
                    hint: "Digite seu e-mail",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: vm.passwordController,
                    label: "Senha",
                    hint: "Crie uma senha",
                    prefixIcon: Icons.lock_outline,
                    obscureText: vm.obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: vm.togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: vm.confirmPasswordController,
                    label: "Confirmar Senha",
                    hint: "Repita a senha",
                    prefixIcon: Icons.lock_outline,
                    obscureText: vm.obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(vm),
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: vm.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    label: "CADASTRAR",
                    onPressed: () => _submit(vm),
                    isLoading: vm.isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(RegisterViewModel vm) async {
    final success = await vm.register();
    if (success && mounted) {
      CustomSnackBar.showSuccess(context, "Conta criada com sucesso!");
      Navigator.pop(context); // Voltar para login
    }
  }
}
