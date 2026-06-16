import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/permission_metadata.dart';
import '../../../../core/di/service_locator.dart';
import '../../../profile/domain/models/role_model.dart';
import '../viewmodel/manage_roles_viewmodel.dart';

/// Página de edição de permissões de um cargo.
///
/// Exibe todas as permissões disponíveis agrupadas por categoria.
/// Permite ativar/desativar permissões individualmente via switches.
///
/// Funcionalidades:
/// - Listagem de permissões agrupadas por categoria (visual, gestão, cadastro)
/// - Switches para ativar/desativar cada permissão
/// - Exibição de ícone, título e descrição de cada permissão
/// - Salvamento em lote das alterações
/// - Loading state durante o salvamento
///
/// Recebe o [RoleModel] via construtor para editar suas permissões.
class EditRolePermissionsPage extends StatefulWidget {
  /// Cargo cujas permissões serão editadas
  final RoleModel role;

  /// Cria uma nova instância da página de edição de permissões
  ///
  /// [role] - Cargo obrigatório para edição
  const EditRolePermissionsPage({super.key, required this.role});

  @override
  State<EditRolePermissionsPage> createState() =>
      _EditRolePermissionsPageState();
}

/// Estado interno da página de permissões
///
/// Gerencia a lista de permissões selecionadas e sincroniza com o ViewModel.
/// Mantém estado local das permissões até o salvamento.
class _EditRolePermissionsPageState extends State<EditRolePermissionsPage> {
  /// ViewModel de cargos injetado via GetIt
  final ManageRolesViewModel viewModel = getIt<ManageRolesViewModel>();
  
  /// Lista local de permissões selecionadas
  late List<String> _selectedPermissions;

  /// Inicializa o estado com as permissões atuais do cargo
  @override
  void initState() {
    super.initState();
    _selectedPermissions = List.from(widget.role.permissions);
  }

  void _togglePermission(String key, bool value) {
    setState(() {
      if (value) {
        if (!_selectedPermissions.contains(key)) {
          _selectedPermissions.add(key);
        }
      } else {
        _selectedPermissions.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = PermissionMetadata.grouped;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ManageRolesViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Permissões: ${widget.role.name}"),
              actions: [
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      await vm.updatePermissions(
                        widget.role.id,
                        _selectedPermissions,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Permissões salvas!")),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                final groupName = entry.key;
                final items = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          groupName.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      ...items.map((meta) {
                        final isSelected = _selectedPermissions.contains(
                          meta.key,
                        );
                        return Column(
                          children: [
                            SwitchListTile.adaptive(
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              title: Text(
                                meta.label,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                              value: isSelected,
                              onChanged: (val) =>
                                  _togglePermission(meta.key, val),
                            ),
                            if (meta != items.last)
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                indent: 16,
                                endIndent: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
