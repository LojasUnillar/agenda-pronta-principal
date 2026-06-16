import 'package:flutter/material.dart';
import 'package:agenda/core/constants/app_permissions.dart';
import '../../../../app/app_routes.dart';
import '../../../profile/presentation/widgets/user_avatar.dart';
import '../viewmodel/home_viewmodel.dart';

/// Header da tela Home com saudação e ações do usuário.
/// 
/// Exibe:
/// - Avatar do usuário (com navegação para edição de perfil)
/// - Saudação personalizada com o nome do usuário
/// - Botão de notificações (com badge de contagem)
/// - Botão de logout
class HomeHeader extends StatelessWidget {
  /// ViewModel da tela Home
  final HomeViewModel vm;
  
  /// Altura do header
  final double height;

  /// Cria o header da Home
  /// 
  /// [vm] - ViewModel para acesso aos dados
  /// [height] - Altura do header em pixels
  const HomeHeader({super.key, required this.vm, required this.height});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FOTO DE PERFIL
            GestureDetector(
              onTap: () async {
                // Navega para edição de perfil se tiver permissão
                if (vm.user != null &&
                    vm.user!.hasPermission(AppPermissions.alterCadUser)) {
                  await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.editUser, arguments: vm.user);
                  vm.reloadUser();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: UserAvatar(
                  radius: 26,
                  name: vm.user?.name ?? "Usuário",
                  avatarUrl: vm.userAvatarUrl,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // TEXTOS DE BOAS-VINDAS
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Seja bem vindo(a),",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    vm.user?.name ?? "Usuário",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // BOTÕES DE AÇÃO
            if (vm.user != null &&
                vm.user!.hasPermission(AppPermissions.accessNotifi))
              IconButton(
                icon: Badge(
                  isLabelVisible: vm.notificationCount > 0,
                  label: Text(vm.notificationText),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notification),
              ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await vm.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
