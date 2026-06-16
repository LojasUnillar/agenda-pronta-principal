import 'package:agenda/core/constants/app_permissions.dart';
import 'package:agenda/core/widgets/custom_snackbar.dart';
import 'package:agenda/core/widgets/app_button.dart';
import 'package:agenda/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/models/user_model.dart';
import '../viewmodel/create_profile_viewmodel.dart';
import '../widgets/profile_avatar.dart';
import '../../../home/presentation/viewmodel/home_viewmodel.dart';

/// Página para criação e edição de perfis de usuário.
class CreateProfilePage extends StatefulWidget {
  final UserModel? user;

  const CreateProfilePage({super.key, this.user});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final CreateProfileViewModel viewModel = getIt<CreateProfileViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.init(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const double headerHeight = 60;
    const double avatarRadius = 50;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CreateProfileViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: colors.primary,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                vm.isEditing ? "Editar Usuário" : "Cadastro de Usuário",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
            ),
            body: Stack(
              children: [
                // Fundo branco arredondado
                Positioned(
                  top: headerHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: avatarRadius + 20,
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Form(
                            key: vm.formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 60),
                                AppTextField(
                                  controller: vm.nameController,
                                  textInputAction: TextInputAction.next,
                                  label: "Nome Completo",
                                  hint: "Digite o nome...",
                                  prefixIcon: Icons.badge_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe o nome.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: vm.loginController,
                                  textInputAction: TextInputAction.next,
                                  label: "Usuário",
                                  hint: "Digite o login...",
                                  prefixIcon: Icons.person_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe o usuário.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Dropdown Role
                                _buildRoleDropdown(vm),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: colors.surface,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        vm.isActive
                                            ? Icons.check_circle_outline
                                            : Icons.block_outlined,
                                        color: vm.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          vm.isActive ? 'Ativo' : 'Inativo',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value:
                                            vm.isActive ||
                                            !(vm.user?.hasPermission(
                                                  AppPermissions
                                                      .alterStatusUser,
                                                ) ??
                                                false),
                                        onChanged: vm.isLoading
                                            ? null
                                            : vm.setActive,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: vm.passwordController,
                                  obscureText: vm.obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  label: vm.isEditing
                                      ? "Senha (vazio para manter)"
                                      : "Senha",
                                  hint: vm.isEditing
                                      ? "Digite para alterar..."
                                      : "Digite a senha...",
                                  prefixIcon: Icons.password_outlined,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      vm.obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: vm.togglePasswordVisibility,
                                  ),
                                  validator: (value) {
                                    if (!vm.isEditing &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Senha é obrigatória para novos usuários.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                AppButton(
                                  height: 55,
                                  isLoading: vm.isLoading,
                                  label: vm.isEditing
                                      ? "Salvar Alterações"
                                      : "Cadastrar",
                                  onPressed: () async {
                                    if (vm.formKey.currentState!
                                        .validate()) {
                                      if (vm.selectedRoleId == null) {
                                        CustomSnackBar.showError(
                                          context,
                                          'Selecione um tipo de usuário.',
                                        );
                                        return;
                                      }

                                      final ok = await vm.save();

                                      if (!context.mounted) return;

                                      if (ok) {
                                        // Se estivermos editando o próprio usuário logado (ex: admin se editando), atualiza a home
                                        final currentUser =
                                            getIt<HomeViewModel>().user;
                                        if (vm.isEditing &&
                                            currentUser != null &&
                                            vm.loginController.text ==
                                                currentUser.login) {
                                          await getIt<HomeViewModel>()
                                              .reloadUser();
                                        }

                                        CustomSnackBar.showSuccess(
                                          context,
                                          'Usuário ${vm.isEditing ? 'editado' : 'criado'} com sucesso!',
                                        );
                                        Navigator.pop(context, true);
                                      } else {
                                        CustomSnackBar.showError(
                                          context,
                                          'Erro: ${vm.errorMessage}',
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Avatar
                Positioned(
                  top: headerHeight - avatarRadius,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ProfileAvatar(
                      radius: avatarRadius,
                      selectedImage: vm.selectedImage,
                      avatarUrl: vm.avatarUrl,
                      initials: _initialsFrom(vm.nameController.text),
                      onTap: () => _openAvatarModal(context, vm),
                      onPickImage:
                          vm.user?.hasPermission(AppPermissions.alterAvatar) ??
                              false
                          ? () => vm.pickImage()
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _initialsFrom(String name) {
    final t = name.trim();
    if (t.isEmpty) return '-';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  Widget _buildRoleDropdown(CreateProfileViewModel vm) {
    final hasItems = vm.rolesFromDb.isNotEmpty;

    final valueIsValid =
        vm.selectedRoleId != null &&
        vm.rolesFromDb.any((r) => r.id == vm.selectedRoleId);

    final safeValue = valueIsValid ? vm.selectedRoleId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: safeValue,
          decoration: InputDecoration(
            labelText: "Tipo de Usuário",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.security_outlined),
          ),
          items: vm.rolesFromDb
              .map(
                (r) =>
                    DropdownMenuItem<String>(value: r.id, child: Text(r.name)),
              )
              .toList(),
          onChanged:
              (!hasItems ||
                  vm.isLoadingRoles ||
                  !(vm.user?.hasPermission(AppPermissions.alterTipoUser) ??
                      false))
              ? null
              : vm.setRoleId,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecione um tipo de usuário.';
            }
            return null;
          },
        ),
        if (vm.isLoadingRoles) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (!vm.isLoadingRoles && !hasItems) ...[
          const SizedBox(height: 8),
          const Text(
            "Nenhum tipo de usuário encontrado.",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }

  void _openAvatarModal(BuildContext context, CreateProfileViewModel vm) {
    final colors = Theme.of(context).colorScheme;

    final bool hasUrl = vm.avatarUrl != null && vm.avatarUrl!.trim().isNotEmpty;

    final ImageProvider? provider = vm.selectedImage != null
        ? FileImage(vm.selectedImage!)
        : (hasUrl ? NetworkImage(vm.avatarUrl!.trim()) : null);

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
                // handle
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
                        onPressed:
                            vm.user?.hasPermission(
                                  AppPermissions.alterAvatar,
                                ) ??
                                false
                            ? () async {
                                await vm.pickImage();
                                if (context.mounted) Navigator.pop(context);
                              }
                            : null,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Trocar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            vm.user?.hasPermission(
                                  AppPermissions.deleteAvatar,
                                ) ??
                                false
                            ? () {
                                vm.removeAvatar();
                                if (context.mounted) {
                                  Navigator.pop(
                                    context,
                                    true,
                                  ); // Retorna true para atualizar a lista
                                }
                              }
                            : null,
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
