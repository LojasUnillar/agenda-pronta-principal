import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// Serviço responsável pela autenticação biométrica local (FaceID, TouchID).
///
/// Utiliza o pacote [local_auth] para verificar suporte e autenticar usuários.
class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  /// Verifica o suporte biométrico do dispositivo.
  ///
  /// Checa se o hardware possui capacidades biométricas ([isDeviceSupported])
  /// e se há biometrias cadastradas/configuradas para uso ([canCheckBiometrics]).
  ///
  /// Retorna `true` se ambas as condições forem atendidas.
  Future<bool> isDeviceSupported() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (e) {
      debugPrint("Erro ao checar suporte biométrico: $e");
      return false;
    }
  }

  /// Realiza a autenticação biométrica do usuário.
  ///
  /// Verifica se o dispositivo suporta biometria e solicita a autenticação
  /// (Impressão digital ou Face ID).
  ///
  /// Retorna `true` se a autenticação for bem-sucedida, `false` caso contrário
  /// ou se houver erro/cancelamento.
  Future<bool> authenticate() async {
    try {
      if (!await isDeviceSupported()) return false;
      await auth.stopAuthentication();

      return await auth.authenticate(
        localizedReason: 'Autentique-se para acessar a agenda',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Acesso Biométrico',
            cancelButton: 'Cancelar',
            biometricHint: 'Toque no sensor',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Ajustes',
            goToSettingsDescription: 'Por favor configure sua biometria.',
            lockOut: 'Muitas tentativas. Bloqueado temporariamente.',
          ),
        ],
      );
    } on PlatformException catch (e) {
      debugPrint("Erro na autenticação: ${e.message}");
      return false;
    }
  }
}
