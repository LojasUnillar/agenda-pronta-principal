import 'package:flutter/material.dart';
import '../viewmodel/search_profile_viewmodel.dart';
import 'users_filter_bottom_sheet.dart';

/// Barra de filtros para a tela de busca de usuários.
/// 
/// Exibe a contagem de usuários encontrados e um botão
/// para abrir o bottom sheet de filtros avançados.
class ProfileFilterBar extends StatelessWidget {
  /// ViewModel que gerencia o estado da busca
  final SearchProfileViewModel viewModel;

  /// Cria a barra de filtros
  /// 
  /// [viewModel] - ViewModel da tela de busca
  const ProfileFilterBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Contagem de usuários
          Text(
            viewModel.isLoading
                ? "Carregando..."
                : "${viewModel.groupedUsers.values.fold(0, (sum, list) => sum + list.length)} usuários encontrados",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),

          // Botão Filtros
          FilledButton.tonalIcon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => UsersFilterBottomSheet(viewModel: viewModel),
              );
            },
            icon: Icon(Icons.filter_list, color: colors.onSurface),
            label: Text("Filtros", style: TextStyle(color: colors.onSurface)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              elevation: 3,
              backgroundColor: colors.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }
}
