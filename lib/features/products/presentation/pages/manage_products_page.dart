import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_action_dialog.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../viewmodel/manage_products_viewmodel.dart';
import '../../domain/models/product_model.dart';

/// Página de gerenciamento de produtos.
///
/// Exibe lista de produtos cadastrados com opções de CRUD.
/// Interface similar à [ManageBrandsPage].
///
/// Funcionalidades:
/// - Listagem de produtos em cards estilizados
/// - Criação via dialog com AppActionDialog
/// - Edição de produtos existentes
/// - Exclusão com confirmação via AppConfirmDialog
/// - Feedback visual de estados (loading, erro, vazio)
class ManageProductsPage extends StatefulWidget {
  /// Cria uma nova instância da página de gerenciamento de produtos
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

/// Estado interno da página de produtos
///
/// Gerencia o ciclo de vida da página e interações com o ViewModel.
/// Inicializa o carregamento dos produtos ao criar o estado.
class _ManageProductsPageState extends State<ManageProductsPage> {
  /// ViewModel injetado via GetIt
  final ManageProductsViewModel viewModel = getIt<ManageProductsViewModel>();

  /// Inicializa o estado e carrega os produtos
  @override
  void initState() {
    super.initState();
    viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ManageProductsViewModel>(
        builder: (context, vm, child) {
          final colors = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(title: const Text("Gerenciar Produtos")),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: colors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nenhum produto encontrado",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.products.length,
                    itemBuilder: (context, index) {
                      final product = vm.products[index];
                      return AppListCard(
                        title: product.name,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showEditProductDialog(context, vm, product),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _showDeleteConfirmDialog(context, vm, product),
                          ),
                        ],
                      );
                    },
                  ),
            floatingActionButton: AppFab(
              label: "Novo Produto",
              icon: Icons.add,
              onPressed: () => _showCreateProductDialog(context, vm),
            ),
          );
        },
      ),
    );
  }

  void _showCreateProductDialog(
    BuildContext context,
    ManageProductsViewModel vm,
  ) async {
    final name = await AppActionDialog.show(
      context: context,
      title: "Novo Produto",
      fieldLabel: "Nome do Produto",
      actionLabel: "Criar",
    );
    if (name != null && name.isNotEmpty) {
      await vm.createProduct(name);
    }
  }

  void _showEditProductDialog(
    BuildContext context,
    ManageProductsViewModel vm,
    ProductModel product,
  ) async {
    final name = await AppActionDialog.show(
      context: context,
      title: "Editar Produto",
      fieldLabel: "Nome do Produto",
      actionLabel: "Salvar",
      initialValue: product.name,
    );
    if (name != null && name.isNotEmpty) {
      await vm.updateProduct(product.id, name);
    }
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ManageProductsViewModel vm,
    ProductModel product,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: "Excluir Produto",
      message: "Tem certeza que deseja excluir '${product.name}'?",
      confirmLabel: "Excluir",
      isDanger: true,
    );
    if (confirmed) {
      await vm.deleteProduct(product.id);
    }
  }
}
