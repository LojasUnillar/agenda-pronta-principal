import 'dart:io';
import 'package:flutter/material.dart';

/// Widget que exibe o avatar de um usuário.
/// 
/// Suporta três modos de exibição:
/// 1. Imagem de arquivo local ([imageFile])
/// 2. Imagem de URL remota ([avatarUrl])
/// 3. Iniciais do nome (fallback quando não há imagem)
/// 
/// Também suporta visualização de status ativo/inativo
/// alterando as cores de fundo.
class UserAvatar extends StatelessWidget {
  /// URL da imagem do avatar (remota)
  final String? avatarUrl;
  
  /// Arquivo de imagem local
  final File? imageFile;
  
  /// Nome do usuário (para gerar as iniciais)
  final String name;
  
  /// Raio do círculo do avatar
  final double radius;
  
  /// Indica se o usuário está ativo (afeta as cores)
  final bool isActive;
  
  /// Callback ao tocar no avatar
  final VoidCallback? onTap;
  
  /// Cor de fundo personalizada
  final Color? backgroundColor;
  
  /// Cor do texto personalizada
  final Color? textColor;
  
  /// Tamanho da fonte das iniciais
  final double? fontSize;

  /// Cria um widget de avatar de usuário
  /// 
  /// [name] - Nome obrigatório para gerar iniciais
  /// [avatarUrl] - URL opcional da imagem remota
  /// [imageFile] - Arquivo opcional de imagem local
  /// [radius] - Raio do avatar (padrão: 24)
  /// [isActive] - Status do usuário (padrão: true)
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.imageFile,
    this.radius = 24,
    this.isActive = true,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  /// Gera as iniciais a partir do nome
  String get _initials {
    final trimName = name.trim();
    if (trimName.isEmpty) return '-';
    final parts = trimName.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first.toUpperCase()}${parts.last.characters.first.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    // Definição de cores padrão baseada no status ativo/inativo
    final bgColor =
        backgroundColor ??
        (isActive ? theme.primaryContainer : theme.surfaceContainerHighest);

    final txtColor =
        textColor ??
        (isActive ? theme.onPrimaryContainer : theme.onSurfaceVariant);

    final hasUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    final hasFile = imageFile != null;

    // Define o provider de imagem baseado na disponibilidade
    ImageProvider? imageProvider;
    if (hasFile) {
      imageProvider = FileImage(imageFile!);
    } else if (hasUrl) {
      imageProvider = NetworkImage(avatarUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: imageProvider,
        child: (imageProvider == null)
            ? (_initials == '-'
                  ? Icon(
                      Icons.person,
                      size: fontSize ?? (radius * 1.2),
                      color: txtColor,
                    )
                  : Text(
                      _initials,
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            fontSize ??
                            (radius * 0.8), // Escala fonte baseada no raio
                      ),
                    ))
            : null,
      ),
    );
  }
}
