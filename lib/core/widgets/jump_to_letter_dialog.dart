import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Dialog para navegação rápida por letra em listas ordenadas.
/// 
/// Exibe um grid com o alfabeto completo (A-Z + #), permitindo ao usuário
/// saltar diretamente para itens que começam com uma letra específica.
/// Letras não disponíveis ficam desabilitadas visualmente.
/// Utilizado em listas grandes de contatos ou usuários.
class JumpToLetterDialog extends StatelessWidget {
  /// Lista de letras disponíveis para seleção
  /// (ex: ['A', 'B', 'C'] se há itens começando com essas letras)
  final List<String> availableLetters;
  
  /// Callback chamado quando uma letra é selecionada
  /// Recebe a letra escolhida como parâmetro
  final Function(String) onLetterSelected;

  /// Cria o dialog de navegação por letra
  /// 
  /// [availableLetters] - Lista de letras que possuem itens correspondentes
  /// [onLetterSelected] - Função a ser chamada ao selecionar uma letra
  const JumpToLetterDialog({
    super.key,
    required this.availableLetters,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Alfabeto completo mais o caractere # para itens especiais
    const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          // Aplica blur no fundo para efeito visual
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: alphabet.split('').map((letter) {
                  final isAvailable = availableLetters.contains(letter);
                  return InkWell(
                    onTap: isAvailable
                        ? () {
                            Navigator.pop(context);
                            onLetterSelected(letter);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? colors.primaryContainer
                            : colors.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: isAvailable
                            ? Border.all(color: colors.primary, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: isAvailable
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                          color: isAvailable
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
