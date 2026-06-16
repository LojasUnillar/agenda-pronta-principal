import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/domain/models/user_model.dart';
import '../features/profile/presentation/pages/create_profile_page.dart';
import '../features/profile/presentation/pages/edit_user_profile_page.dart';
import '../features/settings/presentation/pages/manage_roles_page.dart';
import '../features/brands/presentation/pages/manage_brands_page.dart';
import '../features/products/presentation/pages/manage_products_page.dart';
import '../features/profile/presentation/pages/search_profile_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/contacts/domain/models/department_args.dart';
import '../features/contacts/presentation/pages/contacts_list_page.dart';
import '../features/contacts/presentation/viewmodel/contacts_list_viewmodel.dart';
import '../core/di/service_locator.dart';

/// Define as rotas nomeadas e o mapa de rotas da aplicação.
/// Centraliza a navegação e a injeção de dependências por rota.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth';
  static const String register = '/register';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String searchContacts = '/search-contacts';

  static const String userForm = '/user-form';
  static const String editUser = '/edit-user';
  static const String manageRoles = '/manage-roles';
  static const String manageBrands = '/manage-brands';
  static const String manageProducts = '/manage-products';
  static const String searchProfile = '/search-profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
    notification: (context) => const NotificationPage(),

    searchContacts: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as DepartmentArgs;
      final viewModel = getIt<ContactsListViewModel>();

      return ChangeNotifierProvider.value(
        value: viewModel,
        child: ContactsListPage(
          departmentId: args.id,
          departmentName: args.name,
        ),
      );
    },

    // Edição de Perfil Próprio
    editUser: (context) {
      final user = ModalRoute.of(context)!.settings.arguments as UserModel;
      return EditUserProfilePage(user: user);
    },

    // FORMULÁRIO DE USUÁRIO (CRIAÇÃO/EDIÇÃO)
    userForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final userToEdit = (args is UserModel) ? args : null;

      return CreateProfilePage(user: userToEdit);
    },

    searchProfile: (context) => const SearchProfilePage(),
    manageRoles: (context) => const ManageRolesPage(),
    manageBrands: (context) => const ManageBrandsPage(),
    manageProducts: (context) => const ManageProductsPage(),
  };
}
