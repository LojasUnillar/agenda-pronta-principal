import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_action_dialog.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../viewmodel/manage_brands_viewmodel.dart';
import '../../domain/models/brand_model.dart';

/// Tela de gerenciamento de Marcas.
///
/// Permite listar, criar, editar e excluir marcas.
/// Funcionalidades administrativas acessadas via configurações.
class ManageBrandsPage extends StatefulWidget {
  const ManageBrandsPage({super.key});

  @override
  State<ManageBrandsPage> createState() => _ManageBrandsPageState();
}

class _ManageBrandsPageState extends State<ManageBrandsPage> {
  final ManageBrandsViewModel viewModel = getIt<ManageBrandsViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta reativa do ViewModel
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ManageBrandsViewModel>(
        builder: (context, vm, child) {
          final colors = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(title: const Text("Gerenciar Marcas")),
            // Estado de Carregamento vs Conteúdo
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.brands.isEmpty
                // Estado Vazio (Zero Empty State)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.branding_watermark_outlined,
                          size: 60,
                          color: colors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nenhuma marca encontrada",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                // Lista de Marcas
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.brands.length,
                    itemBuilder: (context, index) {
                      final brand = vm.brands[index];
                      // Card individual de Marca com ações
                      return AppListCard(
                        title: brand.name,
                        actions: [
                          // Botão Editar
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showEditBrandDialog(context, vm, brand),
                          ),
                          // Botão Excluir (Destrutivo)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _showDeleteConfirmDialog(context, vm, brand),
                          ),
                        ],
                      );
                    },
                  ),
            // FAB para criar nova marca
            floatingActionButton: AppFab(
              label: "Nova Marca",
              icon: Icons.add,
              onPressed: () => _showCreateBrandDialog(context, vm),
            ),
          );
        },
      ),
    );
  }

  // Dialogs Auxiliares

  void _showCreateBrandDialog(
    BuildContext context,
    ManageBrandsViewModel vm,
  ) async {
    // Exibe dialog com campo único de texto
    final name = await AppActionDialog.show(
      context: context,
      title: "Nova Marca",
      fieldLabel: "Nome da Marca",
      actionLabel: "Criar",
    );
    if (name != null && name.isNotEmpty) {
      await vm.createBrand(name);
    }
  }

  void _showEditBrandDialog(
    BuildContext context,
    ManageBrandsViewModel vm,
    BrandModel brand,
  ) async {
    final name = await AppActionDialog.show(
      context: context,
      title: "Editar Marca",
      fieldLabel: "Nome da Marca",
      actionLabel: "Salvar",
      initialValue: brand.name,
    );
    if (name != null && name.isNotEmpty) {
      await vm.updateBrand(brand.id, name);
    }
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ManageBrandsViewModel vm,
    BrandModel brand,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: "Excluir Marca",
      message: "Tem certeza que deseja excluir '${brand.name}'?",
      confirmLabel: "Excluir",
      isDanger: true,
    );
    if (confirmed) {
      await vm.deleteBrand(brand.id);
    }
  }
}
