import 'package:get_it/get_it.dart';
import 'package:agenda/core/services/biometric_service.dart';
import 'package:agenda/core/services/connectivity_service.dart';
import 'package:agenda/core/services/push_notification_service.dart';
import 'package:agenda/core/services/update_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agenda/features/auth/data/auth_repository_supabase.dart';
import 'package:agenda/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:agenda/features/auth/presentation/viewmodel/login_viewmodel.dart';
import 'package:agenda/features/auth/presentation/viewmodel/register_viewmodel.dart';
import 'package:agenda/features/auth/presentation/viewmodel/splash_viewmodel.dart';
import 'package:agenda/features/brands/data/repositories/supabase_brand_repository.dart';
import 'package:agenda/features/brands/domain/repositories/i_brand_repository.dart';
import 'package:agenda/features/brands/presentation/viewmodel/manage_brands_viewmodel.dart';
import 'package:agenda/features/contacts/data/supabase_contacts_repository.dart';
import 'package:agenda/features/contacts/domain/repositories/i_supplier_repository.dart';
import 'package:agenda/features/contacts/presentation/viewmodel/contacts_list_viewmodel.dart';
import 'package:agenda/features/departments/data/repositories/department_repository_supabase.dart';
import 'package:agenda/features/departments/domain/repositories/i_department_repository.dart';
import 'package:agenda/features/favorites/data/favorite_repository_supabase.dart';
import 'package:agenda/features/favorites/domain/repositories/i_favorite_repository.dart';
import 'package:agenda/features/favorites/presentation/viewmodel/favorites_viewmodel.dart';
import 'package:agenda/features/home/presentation/viewmodel/home_viewmodel.dart';
import 'package:agenda/features/notifications/data/notification_repository_supabase.dart';
import 'package:agenda/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:agenda/features/notifications/presentation/viewmodel/notification_viewmodel.dart';
import 'package:agenda/features/products/data/repositories/supabase_product_repository.dart';
import 'package:agenda/features/products/domain/repositories/i_product_repository.dart';
import 'package:agenda/features/products/presentation/viewmodel/manage_products_viewmodel.dart';
import 'package:agenda/features/profile/data/repositories/profile_repository_supabase.dart';
import 'package:agenda/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:agenda/features/profile/presentation/viewmodel/create_profile_viewmodel.dart';
import 'package:agenda/features/profile/presentation/viewmodel/edit_profile_viewmodel.dart';
import 'package:agenda/features/profile/presentation/viewmodel/search_profile_viewmodel.dart';
import 'package:agenda/features/settings/presentation/viewmodel/manage_roles_viewmodel.dart';

final getIt = GetIt.instance;

/// Configura a Injeção de Dependência (DI) do projeto usando GetIt.
///
/// Registra as dependências em três camadas principais:
/// 1. **Repositories**: Singletons (Lazy) que gerenciam dados (Supabase, API, Local).
/// 2. **Services**: Singletons para funcionalidades core (Biometria, Conectividade).
/// 3. **ViewModels**: Factories (Cria nova instância a cada chamada) para gerenciar estado das telas.
void setupServiceLocator() {
  // --- REPOSITORIES (Data Layer) ---
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositorySupabase());

  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositorySupabase(),
  );

  getIt.registerLazySingleton<IDepartmentRepository>(
    () => DepartmentRepositorySupabase(),
  );

  getIt.registerLazySingleton<ISupplierRepository>(
    () => SupabaseContactsRepository(),
  );

  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositorySupabase(),
  );

  getIt.registerLazySingleton<IBrandRepository>(
    () => SupabaseBrandRepository(),
  );

  getIt.registerLazySingleton<IProductRepository>(
    () => SupabaseProductRepository(),
  );

  // Favoritos
  getIt.registerLazySingleton<IFavoriteRepository>(
    () => FavoriteRepositorySupabase(),
  );

  // FavoritesViewModel como lazySingleton para manter cache entre telas
  getIt.registerLazySingleton<FavoritesViewModel>(
    () => FavoritesViewModel(getIt(), getIt()),
  );

  // --- SERVICES ---
  getIt.registerLazySingleton<UpdateService>(
      () => UpdateService(Supabase.instance.client));
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(),
  );

  // --- VIEWMODELS (Camada de Apresentação) ---

  // Core & Autenticação
  getIt.registerFactory(() => SplashViewModel(getIt(), getIt()));
  getIt.registerFactory(() => RegisterViewModel(getIt()));
  getIt.registerFactory(() => LoginViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(
    () => HomeViewModel(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  // Notificações
  getIt.registerFactory(() => NotificationViewModel(getIt(), getIt()));

  // Gestão de Contatos
  getIt.registerLazySingleton(
    () => ContactsListViewModel(getIt(), getIt(), getIt()),
  );

  // Gestão de Perfil (Profile)
  getIt.registerFactory(() => EditProfileViewModel(getIt()));
  getIt.registerFactory(() => SearchProfileViewModel(getIt(), getIt()));
  getIt.registerFactory(() => CreateProfileViewModel(getIt(), getIt()));

  // Configurações e Cadastros Auxiliares
  getIt.registerFactory(() => ManageRolesViewModel(getIt()));
  getIt.registerFactory(() => ManageBrandsViewModel(getIt()));
  getIt.registerFactory(() => ManageProductsViewModel(getIt()));
}
