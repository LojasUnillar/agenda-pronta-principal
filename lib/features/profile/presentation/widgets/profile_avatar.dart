import 'dart:io';
import 'package:flutter/material.dart';
import 'user_avatar.dart';

/// Widget que exibe o avatar do usuário com opção de edição (câmera).
/// Usa UserAvatar internamente para garantir consistência visual.
class ProfileAvatar extends StatelessWidget {
  final double radius;
  final File? selectedImage;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;
  final VoidCallback? onPickImage;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.selectedImage,
    this.avatarUrl,
    this.initials,
    this.onTap,
    this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4), // Borda branca/cinza externa
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: UserAvatar(
              radius: radius,
              name:
                  initials ??
                  "", // Passa as iniciais (como se fosse o "name" tratado) se não tiver nome completo na VM
              // Hack: UserAvatar calcula iniciais de "name". Se passarmos as iniciais direto em "name", funciona igual.
              // Melhor seria refatorar UserAvatar para aceitar initials opcional, mas isso serve.
              avatarUrl: avatarUrl,
              imageFile: selectedImage,
              backgroundColor: colors.primaryContainer,
              textColor: colors.onPrimaryContainer,
              fontSize: radius * 0.9, // Ajuste fino para parecer com o antigo
            ),
          ),

          // Botão de Câmera
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: onPickImage,
              child: Icon(Icons.camera_alt, color: colors.primary, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
