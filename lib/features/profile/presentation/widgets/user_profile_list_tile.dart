import 'package:flutter/material.dart';
import '../../../auth/domain/models/user_model.dart';

/// Tile de lista para exibição de usuários na tela de busca.
/// 
/// Exibe informações resumidas do usuário incluindo:
/// - Avatar (imagem ou iniciais)
/// - Nome (com destaque para usuários inativos)
/// - Cargo(s) do usuário
class UserProfileListTile extends StatelessWidget {
  /// Modelo do usuário a ser exibido
  final UserModel user;
  
  /// Iniciais do nome do usuário
  final String initials;
  
  /// Callback ao tocar no tile
  final VoidCallback onTap;

  /// Cria um tile de usuário
  /// 
  /// [user] - Dados do usuário
  /// [initials] - Iniciais do nome
  /// [onTap] - Ação ao tocar
  const UserProfileListTile({
    super.key,
    required this.user,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    // Formata os cargos para exibição
    final String roleText = user.roles.isNotEmpty
        ? user.roles.join(', ')
        : 'Sem perfil';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: user.isActive
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        backgroundImage: (user.avatarUrl?.isNotEmpty == true)
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: (user.avatarUrl == null)
            ? Text(
                initials,
                style: TextStyle(
                  color: user.isActive
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: user.isActive ? null : colors.error,
                decoration: user.isActive ? null : TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!user.isActive)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '(Inativo)',
                style: TextStyle(
                  color: colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        roleText,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
      onTap: onTap,
    );
  }
}
