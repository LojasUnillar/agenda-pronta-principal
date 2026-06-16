import 'package:flutter/material.dart';
import 'package:agenda/core/constants/app_permissions.dart';
import '../viewmodel/home_viewmodel.dart';

/// Barra de navegação inferior customizada da Home.
///
/// Exibe ícones de navegação condicionalmente baseado
/// nas permissões do usuário logado.
///
/// Itens disponíveis:
/// - Favoritos (se tiver permissão)
/// - Home (sempre visível)
/// - Cadastro de Usuários (se tiver permissão)
/// - Configurações (se tiver permissão)
class HomeBottomNav extends StatelessWidget {
  /// ViewModel da Home
  final HomeViewModel vm;

  /// Cria a barra de navegação
  ///
  /// [vm] - ViewModel para acesso aos dados e ações
  const HomeBottomNav({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (vm.user == null) return const SizedBox.shrink();

    return Container(
      color: colors.surfaceContainer,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home (sempre visível - primeira posição)
            _navItem(context, 0, Icons.home, Icons.home_outlined, "Home"),

            // Favoritos (condicional - segunda posição)
            if (vm.user!.hasPermission(AppPermissions.accessFav))
              _navItem(context, 1, Icons.star, Icons.star_outline, "Favoritos"),

            // Aba de Usuários (condicional)
            if (vm.user!.hasPermission(AppPermissions.accessUsersTab))
              _navItem(
                context,
                2,
                Icons.person_add_alt_1,
                Icons.person_add_alt_1_outlined,
                "Usuários",
              ),

            // Configurações (condicional)
            if (vm.user!.hasPermission(AppPermissions.accessConfig))
              _navItem(
                context,
                3,
                Icons.settings,
                Icons.settings_outlined,
                "Config",
              ),
          ],
        ),
      ),
    );
  }

  /// Cria um item de navegação animado
  ///
  /// [context] - Contexto Flutter
  /// [index] - Índice do item
  /// [selectedIcon] - Ícone quando selecionado
  /// [unselectedIcon] - Ícone quando não selecionado
  /// [label] - Texto do item
  Widget _navItem(
    BuildContext context,
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = vm.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container animado do ícone
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.secondary.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 25,
                  color: isSelected
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
              ),
            ),
            // Label animado (aparece apenas quando selecionado)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
