import 'package:agenda/core/errors/exceptions.dart';
import 'package:agenda/core/services/connectivity_service.dart';
import 'package:agenda/features/auth/domain/models/user_model.dart';
import 'package:agenda/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:agenda/features/auth/presentation/viewmodel/login_viewmodel.dart';
import 'package:agenda/core/services/biometric_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late LoginViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    mockConnectivityService = MockConnectivityService();

    // Default to online
    when(
      () => mockConnectivityService.isConnected,
    ).thenAnswer((_) async => true);

    viewModel = LoginViewModel(
      mockAuthRepository,
      mockBiometricService,
      mockConnectivityService,
    );
  });

  group('LoginViewModel', () {
    final tUser = UserModel(
      id: '123',
      name: 'Test User',
      login: 'testuser',
      token: 'token123',
      roles: ['admin'],
      permissions: [],
    );

    test('Initial state should be correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.obscurePassword, true);
    });

    group('login()', () {
      test('should fail if not connected to internet', () async {
        when(
          () => mockConnectivityService.isConnected,
        ).thenAnswer((_) async => false);

        final result = await viewModel.login(
          login: 'user',
          password: 'password',
        );

        expect(result, false);
        expect(viewModel.errorMessage, 'Sem conexão com a internet');
        verifyNever(() => mockAuthRepository.login(any(), any()));
      });

      test('should define errorMessage when login fields are empty', () async {
        viewModel.loginController.text = '';
        viewModel.passwordController.text = '';

        final result = await viewModel.login();

        expect(result, false);
        expect(viewModel.errorMessage, 'Informe o usuário e senha');
      });

      test('should call repository.login and return true on success', () async {
        viewModel.loginController.text = 'user';
        viewModel.passwordController.text = 'password';

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => tUser);

        final result = await viewModel.login();

        expect(result, true);
        expect(viewModel.errorMessage, null);
        verify(() => mockAuthRepository.login('user', 'password')).called(1);
      });

      test('should handle AuthException correctly', () async {
        viewModel.loginController.text = 'user';
        viewModel.passwordController.text = 'password';

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenThrow(AuthException('Credenciais inválidas'));

        final result = await viewModel.login();

        expect(result, false);
        expect(viewModel.errorMessage, 'Credenciais inválidas');
        expect(viewModel.isLoading, false);
      });

      test('should handle ServerException correctly', () async {
        viewModel.loginController.text = 'user';
        viewModel.passwordController.text = 'password';

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenThrow(ServerException(message: 'Erro interno'));

        final result = await viewModel.login();

        expect(result, false);
        expect(viewModel.errorMessage, 'Erro interno');
      });

      test('should handle generic Exception correctly', () async {
        viewModel.loginController.text = 'user';
        viewModel.passwordController.text = 'password';

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenThrow(Exception('Unknown error'));

        final result = await viewModel.login();

        expect(result, false);
        expect(
          viewModel.errorMessage,
          'Ocorreu um erro inesperado: Exception: Unknown error',
        );
      });
    });

    group('Biometrics', () {
      test('should fail if not connected to internet', () async {
        when(
          () => mockConnectivityService.isConnected,
        ).thenAnswer((_) async => false);

        final result = await viewModel.authenticateWithBiometrics();

        expect(result, false);
        expect(viewModel.errorMessage, 'Sem conexão com a internet');
        verifyNever(() => mockBiometricService.authenticate());
      });

      test(
        'should authenticate successfully with stored credentials',
        () async {
          // Arrange
          when(
            () => mockBiometricService.isDeviceSupported(),
          ).thenAnswer((_) async => true);
          when(
            () => mockBiometricService.authenticate(),
          ).thenAnswer((_) async => true);
          when(
            () => mockAuthRepository.getStoredCredentials(),
          ).thenAnswer((_) async => ('u', 'p'));
          when(
            () => mockAuthRepository.login(any(), any()),
          ).thenAnswer((_) async => tUser);

          // Act
          await viewModel.init(); // To load canUseBiometrics
          final result = await viewModel.authenticateWithBiometrics();

          // Assert
          expect(result, true);
          verify(() => mockAuthRepository.login('u', 'p')).called(1);
        },
      );

      test(
        'should fail if biometrics not supported or not configured',
        () async {
          when(
            () => mockBiometricService.isDeviceSupported(),
          ).thenAnswer((_) async => false);

          await viewModel.init();
          expect(viewModel.canUseBiometrics, false);
        },
      );
    });
  });
}
