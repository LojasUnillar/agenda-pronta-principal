import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:agenda/core/errors/exceptions.dart';
import '../domain/models/user_model.dart';
import '../domain/repositories/i_auth_repository.dart';

/// Implementação do repositório de autenticação utilizando Supabase.
///
/// Responsável por toda a camada de segurança e gestão de sessão do usuário.
/// Integrações:
/// - **Supabase Auth**: Autenticação principal (E-mail/Senha).
/// - **Supabase Database**: Recuperação de perfil (`tb_usuario`), cargos e permissões.
/// - **FlutterSecureStorage**: Persistência segura de tokens e credenciais locais.
/// - **Supabase Storage**: Upload e recuperação de avatar.
class AuthRepositorySupabase implements IAuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
      sharedPreferencesName: 'AgendaSecretsApp',
      preferencesKeyPrefix: 'auth_',
    ),
  );

  static const _tokenKey = 'CUSTOM_JWT_TOKEN';
  static const _userKey = 'CURRENT_USER';
  static const _loginKey = 'LOGIN';
  static const _passwordKey = 'PASSWORD';

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  /// Realiza o login do usuário.
  ///
  /// Fluxo de autenticação:
  /// 1. Autenticação nativa no Supabase Auth.
  /// 2. Recuperação do perfil na tabela `tb_usuario`.
  /// 3. Carregamento de cargos e permissões associadas.
  /// 4. Criação do objeto [UserModel] completo.
  /// 5. Persistência segura da sessão e credenciais.
  ///
  /// Lança [AuthException] em caso de credenciais inválidas ou erro de autenticação.
  @override
  Future<UserModel> login(String login, String password) async {
    try {
      // 1. Login Nativo no Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: login.toLowerCase(),
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw AuthException('Falha na autenticação');
      }

      final sessionToken = response.session!.accessToken;

      // 2. Buscar Perfil (tb_usuario)
      final profileData = await _supabase
          .from('tb_usuario')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profileData == null) {
        // Fallback se o trigger falhar (não deveria, mas...)
        throw AuthException('Perfil de usuário não encontrado.');
      }

      // 3. Buscar Cargos e Permissões via Join
      // Como removemos a duplicidade no banco, podemos usar a relação direta.
      // tb_cargo_usuario -> tb_cargo -> tb_cargo_permissoes -> tb_permissoes
      final rolesData = await _supabase
          .from('tb_cargo_usuario')
          .select('''
            cargo:tb_cargo (
              name,
              cargo_permissoes:tb_cargo_permissoes (
                permissoes:tb_permissoes ( code )
              )
            )
          ''')
          .eq('user_id', response.user!.id);

      final List<String> roles = [];
      final Set<String> permissions = {};

      for (var item in rolesData) {
        final cargo = item['cargo'];
        if (cargo != null) {
          final roleName = cargo['name'] as String?;
          if (roleName != null) roles.add(roleName);

          final cpList = cargo['cargo_permissoes'] as List<dynamic>?;
          if (cpList != null) {
            for (var cp in cpList) {
              final perm = cp['permissoes'];
              if (perm != null && perm['code'] != null) {
                permissions.add(perm['code'] as String);
              }
            }
          }
        }
      }

      final user = UserModel.fromMap(
        profileData, // Usa dados de tb_usuario
        sessionToken,
        roles: roles,
        permissions: permissions.toList(),
      );

      // Persistência
      await _storage.write(key: _tokenKey, value: sessionToken);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: _loginKey, value: login);
      await _storage.write(key: _passwordKey, value: password);

      _currentUser = user;
      return user;
    } on AuthException catch (e) {
      // Erro específico do Supabase Auth
      if (e.message.contains('Invalid login credentials')) {
        throw AuthException('Usuário ou senha incorretos.');
      }
      rethrow;
    } on FunctionException catch (e) {
      final message = (e.details is Map && e.details['error'] != null)
          ? e.details['error']
          : 'Erro no servidor: ${e.reasonPhrase}';
      throw ServerException(message: message, statusCode: e.status);
    } catch (e, s) {
      debugPrint('$e\n$s');
      throw AuthException('Erro inesperado. Tente novamente.');
    }
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    try {
      // 1. Criar Auth User
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Metadata
      );

      if (authResponse.user == null) {
        throw AuthException('Falha ao criar usuário no Auth.');
      }

      final userId = authResponse.user!.id;

      // 2. Inserir em tb_usuario
      // Nota: RLS deve permitir que usuário autenticado insira seu próprio ID
      await _supabase.from('tb_usuario').insert({
        'id': userId,
        'nome': name,
        'login': email,
        'avatar_url': null,
        'is_active': true,
      });

      // 3. Vincular Cargo Padrão (Ex: 'Vendedor' ou 'Usuário')
      // Busca ID do cargo padrão
      final roleRes = await _supabase
          .from('tb_cargo')
          .select('id')
          .ilike('name', 'Vendedor') // Tenta achar Vendedor
          .maybeSingle();

      String? roleId = roleRes?['id'];

      // Fallback: Se não achar Vendedor, pega o primeiro que tiver
      if (roleId == null) {
        final anyRole = await _supabase
            .from('tb_cargo')
            .select('id')
            .limit(1)
            .maybeSingle();
        roleId = anyRole?['id'];
      }

      if (roleId != null) {
        await _supabase.from('tb_cargo_usuario').insert({
          'user_id': userId,
          'cargo_id': roleId,
        });
      }
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Erro ao realizar cadastro: $e');
    }
  }

  /// Recupera as credenciais de login armazenadas localmente.
  ///
  /// Utiliza armazenamento seguro ([FlutterSecureStorage]) para retornar
  /// a tupla `(login, senha)` se disponível.
  /// Retorna `null` se não houver credenciais salvas.
  @override
  Future<(String, String)?> getStoredCredentials() async {
    final login = await _storage.read(key: _loginKey);
    final password = await _storage.read(key: _passwordKey);

    if (login == null || password == null) return null;
    return (login, password);
  }

  /// Verifica se a sessão atual é válida.
  ///
  /// Tenta restaurar a sessão na seguinte ordem:
  /// 1. Validação do Token JWT armazenado.
  /// 2. Renovação automática (Auto-Login) usando credenciais salvas se o token expirou.
  ///
  /// Retorna `true` se a sessão for restaurada com sucesso.
  /// Retorna `false` e realiza logout se não for possível validar.
  @override
  Future<bool> isSessionValid() async {
    try {
      // Tenta restaurar sessão via Token
      final savedToken = await _storage.read(key: _tokenKey);
      final savedUserJson = await _storage.read(key: _userKey);

      if (savedToken != null && savedUserJson != null) {
        final isExpired = JwtDecoder.isExpired(savedToken);
        if (!isExpired) {
          try {
            // Restaura sessão no Supabase Client
            await _supabase.auth.setSession(savedToken);

            final userMap = jsonDecode(savedUserJson);
            // Reconstrói o usuário com o token salvo
            _currentUser = UserModel.fromJson(userMap);
            debugPrint('Sessão restaurada com sucesso via Token.');
            return true;
          } catch (e) {
            debugPrint(
              'Erro ao decodificar usuário local ou restaurar sessão: $e',
            );
          }
        } else {
          debugPrint('Token expirado. Tentando login automático...');
        }
      }

      // Fallback: Login com credenciais salvas (Se token expirou ou não existe)
      final savedLogin = await _storage.read(key: _loginKey);
      final savedPassword = await _storage.read(key: _passwordKey);

      if (savedLogin == null || savedPassword == null) {
        debugPrint('Credenciais não encontradas. Exigindo login manual.');
        await logout();
        return false;
      }

      debugPrint('Tentando renovar sessão para: $savedLogin');
      await login(savedLogin, savedPassword);

      debugPrint('Sessão renovada com sucesso (Token e Dados atualizados).');
      return true;
    } on AuthException catch (e) {
      debugPrint('Falha na renovação: ${e.message}');
      await logout();
      return false;
    } catch (e) {
      debugPrint('Erro genérico ao validar sessão: $e');
      await logout();
      return false;
    }
  }

  /// Realiza o upload da imagem de avatar do usuário.
  ///
  /// Envia o arquivo para o bucket `avatars` no Supabase Storage e
  /// retorna a URL pública do arquivo gerado.
  /// O nome do arquivo será baseado no ID do usuário.
  @override
  Future<String> uploadAvatarImage(File file, String userId) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId.$fileExt';

      await _supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final avatarUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
      return avatarUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Atualiza os dados do perfil do usuário.
  ///
  /// Sincroniza as alterações tanto no Supabase Auth (Email/Senha/Metadata)
  /// quanto na tabela de perfil `tb_usuario`.
  /// Após a atualização, recarrega os dados do usuário atual na memória.
  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String login,
    String? password,
    String? avatarUrl,
    required String token,
  }) async {
    try {
      // 1. Atualizar Auth (Senha/Email) se necessário
      final attributes = UserAttributes(
        email: login,
        password: password,
        data: {'name': name, 'avatar_url': avatarUrl},
      );

      if (password != null || login != _currentUser?.login) {
        await _supabase.auth.updateUser(attributes);
      }

      // 2. Atualizar Tabela de Perfil (tb_usuario)
      // O RLS já permite que o usuário edite seu próprio registro
      await _supabase
          .from('tb_usuario')
          .update({
            'nome': name,
            'login': login, // Mantendo sincronizado
            'avatar_url': avatarUrl,
          })
          .eq('id', userId);

      await refreshCurrentUser();
    } on AuthException catch (e) {
      throw Exception('Erro ao atualizar autenticação: ${e.message}');
    } catch (e) {
      throw Exception('Falha na atualização de perfil: $e');
    }
  }

  /// Recarrega os dados do usuário atual do banco de dados.
  ///
  /// Útil para atualizar permissões, cargos ou dados de perfil que possam
  /// ter sido alterados externamente ou após uma atualização de perfil.
  @override
  Future<void> refreshCurrentUser() async {
    final current = _currentUser;
    if (current == null) return;

    // 1. Buscar Perfil Atualizado
    final profileData = await _supabase
        .from('tb_usuario')
        .select()
        .eq('id', current.id)
        .maybeSingle();

    if (profileData == null) return;

    // 2. Buscar Cargos e Permissões (igual ao login)
    final rolesData = await _supabase
        .from('tb_cargo_usuario')
        .select('''
          cargo:tb_cargo (
            name,
            cargo_permissoes:tb_cargo_permissoes (
              permissoes:tb_permissoes ( code )
            )
          )
        ''')
        .eq('user_id', current.id);

    final List<String> roles = [];
    final Set<String> permissions = {};

    for (var item in rolesData) {
      final cargo = item['cargo'];
      if (cargo != null) {
        final roleName = cargo['name'] as String?;
        if (roleName != null) roles.add(roleName);

        final cpList = cargo['cargo_permissoes'] as List<dynamic>?;
        if (cpList != null) {
          for (var cp in cpList) {
            final perm = cp['permissoes'];
            if (perm != null && perm['code'] != null) {
              permissions.add(perm['code'] as String);
            }
          }
        }
      }
    }

    _currentUser = UserModel.fromMap(
      profileData,
      current.token,
      roles: roles,
      permissions: permissions.toList(),
    );

    await _storage.write(
      key: _userKey,
      value: jsonEncode(_currentUser!.toJson()),
    );
  }

  /// Encerra a sessão do usuário.
  ///
  /// 1. Remove dados locais seguros (Token, User, Credenciais).
  /// 2. Realiza logout na API do Supabase.
  /// 3. Limpa o usuário atual da memória.
  @override
  Future<void> logout() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _loginKey);
    await _storage.delete(key: _passwordKey);
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  /// Registra o token FCM (Firebase Cloud Messaging) para notificações push.
  ///
  /// Armazena o token na tabela `tb_fcm_tokens`, vinculando-o ao usuário
  /// e identificando a plataforma (Android/iOS/Web).
  /// Utiliza `upsert` para evitar duplicatas.
  @override
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      final deviceInfo = Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'web');

      await _supabase.from('tb_fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'device_info': deviceInfo,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token', // Unique constraint
      );
      debugPrint("FCM Token salvo com sucesso para o user $userId");
    } catch (e) {
      debugPrint("Erro ao salvar FCM Token: $e");
    }
  }
}
