import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda/core/di/service_locator.dart';
import 'package:agenda/features/favorites/presentation/viewmodel/favorites_viewmodel.dart';
import 'package:agenda/features/contacts/presentation/pages/supplier_details_page.dart';

/// Tela de favoritos pessoais do usuário.
///
/// Lista os contatos que o usuário marcou como favoritos.
/// Cada usuário tem sua própria lista independente.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesViewModel _viewModel = getIt<FavoritesViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              backgroundColor: colors.primary,
              title: const Text(
                'Favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            body: _buildBody(context, vm, colors),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FavoritesViewModel vm,
    ColorScheme colors,
  ) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(vm.error!, style: TextStyle(color: colors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadFavorites,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (vm.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 80,
              color: colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum favorito ainda.',
              style: TextStyle(
                fontSize: 18,
                color: colors.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Abra um perfil e toque na estrela ⭐ para favoritar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadFavorites,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final contact = vm.favorites[index];
          return _FavoriteCard(
            name: contact.name,
            type: contact.type,
            status: contact.status,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupplierDetailsPage(contact: contact),
                ),
              ).then((_) => vm.loadFavorites());
            },
            onUnfavorite: () => vm.toggleFavorite(contact.id, contact),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _FavoriteCard({
    required this.name,
    required this.type,
    required this.status,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isActive = status.toLowerCase() == 'ativo';

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Ícone/Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botão desfavoritar
              IconButton(
                icon: Icon(Icons.star_rounded, color: colors.primary),
                tooltip: 'Remover dos favoritos',
                onPressed: onUnfavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
