import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_permissions.dart';
import '../../../home/presentation/viewmodel/home_viewmodel.dart';

/// Página de configurações do aplicativo.
///
/// Exibe opções de configuração baseadas nas permissões do usuário logado,
/// como gerenciamento de cargos e permissões.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Configurações")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (vm.user?.hasPermission(AppPermissions.alterTipoUser) ??
                  false) ...[
                _buildConfigCard(
                  context,
                  icon: Icons.security,
                  title: "Gerenciar Cargos e Permissões",
                  subtitle: "Definir o que cada grupo pode fazer",
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.manageRoles);
                  },
                ),
                _buildConfigCard(
                  context,
                  icon: Icons.branding_watermark,
                  title: "Gerenciar Marcas",
                  subtitle: "Cadastrar e editar marcas de fornecedores",
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.manageBrands);
                  },
                ),
                _buildConfigCard(
                  context,
                  icon: Icons.inventory_2,
                  title: "Gerenciar Produtos",
                  subtitle: "Cadastrar e editar produtos atendidos",
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.manageProducts);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colors.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
