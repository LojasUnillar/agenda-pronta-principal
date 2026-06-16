import 'dart:io';

import 'package:agenda/features/auth/domain/models/user_model.dart';

/// Interface que define o contrato para operações de Autenticação.
///
/// Inclui login, gestão de sessão e atualização de perfil do usuário logado.
abstract class IAuthRepository {
  /// Realiza login com credenciais.
  ///
  /// [login] - Email/username do usuário
  /// [password] - Senha
  ///
  /// Retorna o [UserModel] em caso de sucesso.
  /// Lança exceção em caso de erro.
  Future<UserModel> login(String login, String password);

  /// Cria uma nova conta de usuário.
  ///
  /// [name] - Nome completo
  /// [email] - E-mail do usuário
  /// [password] - Senha de acesso
  Future<void> signUp(String name, String email, String password);

  /// Verifica se a sessão atual é válida (token não expirado).
  ///
  /// Tenta restaurar sessão de token salvo ou fazer login automático
  /// com credenciais armazenadas.
  Future<bool> isSessionValid();

  /// Remove a sessão local e limpa dados sensíveis.
  Future<void> logout();

  /// Atualiza os dados do perfil do usuário logado.
  ///
  /// [userId] - ID do usuário
  /// [name] - Novo nome
  /// [login] - Novo login/email
  /// [password] - Nova senha (opcional)
  /// [avatarUrl] - Nova URL do avatar
  /// [token] - Token de autenticação atual
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String login,
    String? password,
    String? avatarUrl,
    required String token,
  });

  /// Recarrega os dados do usuário atual do servidor.
  ///
  /// Útil após atualizações para garantir dados frescos.
  Future<void> refreshCurrentUser();

  /// Envia a imagem de avatar para o storage.
  ///
  /// [file] - Arquivo de imagem
  /// [userId] - ID do usuário
  ///
  /// Retorna a URL pública da imagem armazenada.
  Future<String> uploadAvatarImage(File file, String userId);

  /// Retorna as credenciais salvas localmente, se houver.
  ///
  /// Útil para re-login automático ou biometria.
  /// Retorna tupla (login, password) ou null.
  Future<(String, String)?> getStoredCredentials();

  /// Salva o token FCM para Push Notifications.
  ///
  /// [userId] - ID do usuário
  /// [token] - Token FCM do Firebase
  Future<void> saveFcmToken(String userId, String token);

  /// Retorna o usuário logado atualmente em memória.
  ///
  /// Retorna null se não houver usuário logado.
  UserModel? get currentUser;
}
