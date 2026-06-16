import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/profile/presentation/pages/search_profile_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';
import '../../../../features/favorites/presentation/pages/favorites_page.dart';
import '../../../../features/favorites/presentation/viewmodel/favorites_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/home_header.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/quick_access_section.dart';

/// Tela inicial do aplicativo.
/// Exibe um dashboard com informações do usuário, contador de notificações e menu de acesso rápido.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// RouteObserver global para detectar quando a HomePage volta ao foco
final homeRouteObserver = RouteObserver<ModalRoute<void>>();

class _HomePageState extends State<HomePage> with RouteAware {
  final HomeViewModel viewModel = getIt<HomeViewModel>();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      homeRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Chamado quando uma rota empilhada acima é removida (pop) e voltamos para Home
  @override
  void didPopNext() {
    viewModel.reloadUser();
  }

  @override
  void initState() {
    super.initState();
    viewModel.startNotificationsListener();
    if (!_loaded) {
      viewModel.loadQuickAccess();
      // Popula o cache de favoritos para que a estrela nos perfis funcione imediatamente
      getIt<FavoritesViewModel>().initCache();
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: colors.surface,
            body: _buildBody(vm),
            bottomNavigationBar: _buildBottomNav(vm),
          );
        },
      ),
    );
  }

  Widget _buildBody(HomeViewModel vm) {
    switch (vm.currentIndex) {
      case 0:
        return _buildHome(vm);
      case 1:
        return const FavoritesPage();
      case 2:
        return const SearchProfilePage();
      case 3:
        return const SettingsPage();
      default:
        return _buildHome(vm);
    }
  }

  // ================== TELA HOME ==================
  Widget _buildHome(HomeViewModel vm) {
    final colors = Theme.of(context).colorScheme;
    const double headerHeight = 90;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          // --- Camada 1: Seção de Acesso Rápido ---
          QuickAccessSection(vm: vm, topPadding: headerHeight),

          // --- Camada 2: Header (Avatar e Saudação) ---
          HomeHeader(vm: vm, height: headerHeight),
        ],
      ),
    );
  }

  // ================== BARRA DE NAVEGAÇÃO ==================
  Widget _buildBottomNav(HomeViewModel vm) {
    return HomeBottomNav(vm: vm);
  }
}
