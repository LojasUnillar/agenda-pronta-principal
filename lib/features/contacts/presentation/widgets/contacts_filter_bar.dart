import 'package:flutter/material.dart';
import '../viewmodel/contacts_list_viewmodel.dart';
import 'contacts_filter_bottom_sheet.dart';

/// Barra de filtros para a tela de listagem de contatos.
/// 
/// Exibe a contagem de contatos encontrados e um botão
/// para abrir o bottom sheet de filtros avançados.
class ContactsFilterBar extends StatelessWidget {
  /// ViewModel que gerencia o estado da lista
  final ContactsListViewModel viewModel;

  /// Cria a barra de filtros
  /// 
  /// [viewModel] - ViewModel da tela de contatos
  const ContactsFilterBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Contagem de resultados
          Text(
            viewModel.isLoading
                ? "Carregando..."
                : "${viewModel.groupedContacts.values.fold(0, (sum, list) => sum + list.length)} contatos encontrados",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),

          // Botão de Filtro
          FilledButton.tonalIcon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) =>
                    ContactsFilterBottomSheet(viewModel: viewModel),
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
