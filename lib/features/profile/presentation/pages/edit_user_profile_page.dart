import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../home/presentation/viewmodel/home_viewmodel.dart';
import '../../../auth/domain/models/user_model.dart';
import '../viewmodel/edit_profile_viewmodel.dart';
import '../widgets/profile_avatar.dart';

/// Página para edição do perfil do usuário logado.
class EditUserProfilePage extends StatefulWidget {
  final UserModel user;

  const EditUserProfilePage({super.key, required this.user});

  @override
  State<EditUserProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditUserProfilePage> {
  final EditProfileViewModel viewModel = getIt<EditProfileViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.init(widget.user);
  }

  void _onSavePressed(BuildContext context) async {
    final success = await viewModel.saveProfile(widget.user);

    if (context.mounted) {
      if (success) {
        await getIt<HomeViewModel>().reloadUser();
        CustomSnackBar.showSuccess(context, 'Perfil atualizado com sucesso!');
        Navigator.pop(context);
      } else {
        CustomSnackBar.showError(context, 'Erro: ${viewModel.errorMessage}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final double headerHeight = 60;
    final double avatarRadius = 50;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: colors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Editar Perfil",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: Consumer<EditProfileViewModel>(
          builder: (context, vm, child) {
            return Stack(
              children: [
                // --- Formulário ---
                Positioned(
                  top: headerHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: vm.formKey,
                        child: ListView(
                          padding: EdgeInsets.only(top: avatarRadius + 20),
                          children: [
                            const SizedBox(height: 60),

                            AppTextField(
                              label: "Nome Completo",
                              hint: "Digite seu nome...",
                              controller: vm.nameController,
                              prefixIcon: Icons.badge_outlined,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nome é obrigatório.'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              label: "Usuário",
                              hint: "Digite seu usuário...",
                              controller: vm.loginController,
                              prefixIcon: Icons.person_outlined,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Usuário é obrigatório.'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              label: "Senha",
                              hint: "Digite nova senha (opcional)...",
                              controller: vm.passwordController,
                              prefixIcon: Icons.password_outlined,
                              obscureText: vm.obscurePassword,
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

                            AppButton(
                              height: 55,
                              isLoading: vm.isLoading,
                              label: "Salvar",
                              onPressed: () {
                                if (vm.formKey.currentState!
                                    .validate()) {
                                  _onSavePressed(context);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: headerHeight - avatarRadius,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ProfileAvatar(
                      radius: avatarRadius,
                      selectedImage: vm.selectedImage,
                      avatarUrl: vm.userAvatarUrl,
                      initials: vm.nameController.text,
                      onTap: () => _openAvatarModal(context, vm),
                      onPickImage: () => vm.pickImage(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openAvatarModal(BuildContext context, EditProfileViewModel vm) {
    final colors = Theme.of(context).colorScheme;

    final ImageProvider? provider = vm.selectedImage != null
        ? FileImage(vm.selectedImage!)
        : (vm.userAvatarUrl != null ? NetworkImage(vm.userAvatarUrl!) : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // “handle”
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: colors.surfaceContainerHighest,
                      child: provider == null
                          ? Center(
                              child: Icon(
                                Icons.person,
                                size: 72,
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          : InteractiveViewer(
                              minScale: 1,
                              maxScale: 4,
                              child: Image(image: provider, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await vm.pickImage();
                          final file = vm.selectedImage;
                          if (file != null) {
                            getIt<HomeViewModel>().setTempAvatar(file);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Trocar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          vm.removeAvatar();
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remover foto'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
