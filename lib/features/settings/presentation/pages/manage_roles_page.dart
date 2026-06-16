import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_multi_field_dialog.dart';
import '../viewmodel/manage_roles_viewmodel.dart';
import 'edit_role_permissions_page.dart';

/// Página de gerenciamento de cargos/roles.
///
/// Exibe lista de cargos disponíveis no sistema.
/// Permite criar novos cargos e editar permissões.
///
/// Funcionalidades:
/// - Listagem de cargos (filtro automático de administradores)
/// - Visualização de nome e descrição em cards
/// - Criação de novo cargo via dialog multi-campos
/// - Navegação para edição de permissões do cargo
/// - Ícone temático por cargo
class ManageRolesPage extends StatefulWidget {
  /// Cria uma nova instância da página de gerenciamento de cargos
  const ManageRolesPage({super.key});

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

/// Estado interno da página de cargos
///
/// Gerencia o ciclo de vida e interações com [ManageRolesViewModel].
/// Inicializa carregamento dos cargos ao criar o estado.
class _ManageRolesPageState extends State<ManageRolesPage> {
  /// ViewModel de cargos injetado via GetIt
  final ManageRolesViewModel viewModel = getIt<ManageRolesViewModel>();

  /// Inicializa o estado e carrega os cargos
  @override
  void initState() {
    super.initState();
    viewModel.loadRoles();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ManageRolesViewModel>(
        builder: (context, vm, child) {
          final colors = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(title: const Text("Gerenciar Cargos")),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.roles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          size: 60,
                          color: colors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nenhum cargo encontrado",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: vm.roles.length,
                    itemBuilder: (context, index) {
                      final role = vm.roles[index];
                      return AppListCard(
                        title: role.name,
                        subtitle: role.description,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditRolePermissionsPage(role: role),
                            ),
                          ).then((_) => vm.loadRoles());
                        },
                      );
                    },
                  ),
            floatingActionButton: AppFab(
              label: "Novo Cargo",
              icon: Icons.add,
              onPressed: () => _showCreateRoleDialog(context, vm),
            ),
          );
        },
      ),
    );
  }

  void _showCreateRoleDialog(
    BuildContext context,
    ManageRolesViewModel vm,
  ) async {
    final result = await AppMultiFieldDialog.show(
      context: context,
      title: "Novo Cargo",
      fields: const [
        DialogFieldConfig(label: "Nome do Cargo", hint: "Digite o nome..."),
        DialogFieldConfig(label: "Descrição", hint: "Digite a descrição..."),
      ],
      actionLabel: "Criar",
    );

    if (result != null && result.isNotEmpty) {
      final name = result[0];
      final desc = result.length > 1 ? result[1] : '';
      if (name.isNotEmpty) {
        await vm.createRole(name, desc);
      }
    }
  }
}
