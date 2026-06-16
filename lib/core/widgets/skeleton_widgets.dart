import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget de skeleton para tiles de lista.
/// 
/// Exibe um placeholder animado com efeito shimmer para representar
/// um item de lista enquanto os dados estão sendo carregados.
/// Utilizado como loading state para listas de contatos, usuários, etc.
class SkeletonListTile extends StatelessWidget {
  /// Cria um widget skeleton para tile de lista
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Cores para o Shimmer (conteúdo placeholder)
    final baseColor = colors.onSurfaceVariant.withValues(alpha: 0.1);
    final highlightColor = colors.onSurfaceVariant.withValues(alpha: 0.05);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Row(
            children: [
              // Avatar Placeholder
              const CircleAvatar(radius: 28, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              // Text Placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de skeleton para cards em grid.
/// 
/// Exibe um placeholder animado com efeito shimmer para representar
/// um card em layout de grade enquanto os dados estão sendo carregados.
/// Ideal para grids de departamentos, categorias, etc.
class SkeletonGridCard extends StatelessWidget {
  /// Cria um widget skeleton para card em grid
  const SkeletonGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final baseColor = colors.onSurfaceVariant.withValues(alpha: 0.1);
    final highlightColor = colors.onSurfaceVariant.withValues(alpha: 0.05);

    return Card(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
