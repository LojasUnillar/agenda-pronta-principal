import 'package:flutter/material.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../../../contacts/domain/models/department_args.dart';
import '../viewmodel/home_viewmodel.dart';
import 'quick_access_card.dart';

/// Seção de acesso rápido na tela Home.
///
/// Exibe um grid de departamentos para navegação rápida.
/// Durante o carregamento, exibe skeleton placeholders.
class QuickAccessSection extends StatelessWidget {
  /// ViewModel da Home
  final HomeViewModel vm;

  /// Padding superior para posicionamento
  final double topPadding;

  /// Cria a seção de acesso rápido
  ///
  /// [vm] - ViewModel para acesso aos dados
  /// [topPadding] - Espaçamento superior em pixels
  const QuickAccessSection({
    super.key,
    required this.vm,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              // Título da seção
              Text(
                "Acesso Rápido",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),

              // GRID DE ACESSO RÁPIDO
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    // Exibe skeleton ou conteúdo baseado no estado
                    child: vm.isLoadingDepartments
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: 12,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (context, index) =>
                                const SkeletonGridCard(),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: vm.quickAccessItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (context, index) {
                              final item = vm.quickAccessItems[index];
                              return QuickAccessCard(
                                item: item,
                                onTap: () {
                                  // Navega para a lista de contatos do departamento
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.searchContacts,
                                    arguments: DepartmentArgs(
                                      id: item.id,
                                      name: item.label,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
