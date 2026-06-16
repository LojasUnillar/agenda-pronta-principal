import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:agenda/core/errors/exceptions.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/role_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Repositório de Perfil usando Supabase e Edge Functions.
/// Implementação do repositório de perfis usando Supabase.
/// Realiza CRUD de usuários na tabela 'profiles' e gerencia vinculação de roles.
class ProfileRepositorySupabase implements IProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  ProfileRepositorySupabase();

  /// Busca usuários diretamente na tabela tb_usuario
  @override
  Future<List<UserModel>> searchUsers({
    String query = '',
    bool? isActive,
  }) async {
    try {
      var dbQuery = _supabase.from('tb_usuario').select('''
        *,
        roles:tb_cargo_usuario (
          cargo:tb_cargo ( name )
        )
      ''');

      if (query.isNotEmpty) {
        dbQuery = dbQuery.or('nome.ilike.%$query%,login.ilike.%$query%');
      }

      if (isActive != null) {
        dbQuery = dbQuery.eq('is_active', isActive);
      }

      final data = await dbQuery;
      final List items = data as List;

      return items.map((m) {
        // Mapear roles - pode vir como List ou Map dependendo da estrutura
        final rolesData = m['roles'];
        List<String> rolesList = [];

        if (rolesData is List) {
          rolesList = rolesData
              .map((r) {
                final cargo = r['cargo'];
                if (cargo is Map) {
                  return cargo['name']?.toString() ?? '';
                }
                return '';
              })
              .where((name) => name.isNotEmpty)
              .toList();
        } else if (rolesData is Map && rolesData['cargo'] != null) {
          final cargo = rolesData['cargo'];
          if (cargo is Map && cargo['name'] != null) {
            rolesList = [cargo['name'].toString()];
          }
        }

        return UserModel.fromMap(m, '', roles: rolesList);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar usuários: $e');
      throw ServerException(
        message: 'Erro ao buscar usuários.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    try {
      final data = await _supabase
          .from('tb_cargo')
          .select('''
        *,
        cargo_permissoes:tb_cargo_permissoes (
          permissao:tb_permissoes ( code )
        )
      ''')
          .order('name');

      final List items = data as List;
      return items.map((e) {
        final cargoPermissoes = e['cargo_permissoes'] as List? ?? [];
        final permissions = cargoPermissoes
            .map((cp) {
              final permissao = cp['permissao'];
              if (permissao is Map) return permissao['code']?.toString() ?? '';
              return '';
            })
            .where((code) => code.isNotEmpty)
            .toList();

        return RoleModel(
          id: e['id']?.toString() ?? '',
          name: e['name'] ?? '',
          description: e['description'],
          permissions: permissions,
        );
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar cargos: $e');
    }
  }

  @override
  Future<void> createRole(String name, String description) async {
    try {
      final newId = _generateUuid();
      debugPrint('createRole chamado: name=$name, id=$newId');
      final response = await _supabase.from('tb_cargo').insert({
        'id': newId,
        'name': name,
        'description': description,
      }).select();
      debugPrint('createRole resposta: $response');
    } catch (e) {
      debugPrint('createRole ERRO: $e');
      throw ServerException(message: 'Erro ao criar cargo: $e');
    }
  }

  /// Gera um UUID v4 em Dart puro (sem pacote externo)
  String _generateUuid() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // versão 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante RFC4122
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-'
        '${hex.sublist(4, 6).join()}-'
        '${hex.sublist(6, 8).join()}-'
        '${hex.sublist(8, 10).join()}-'
        '${hex.sublist(10, 16).join()}';
  }

  @override
  Future<void> updateRolePermissions(
    String roleId,
    List<String> permissions,
  ) async {
    try {
      if (permissions.isEmpty) {
        // Se nenhuma permissão selecionada, apenas limpa
        await _supabase
            .from('tb_cargo_permissoes')
            .delete()
            .eq('cargo_id', roleId);
        return;
      }

      // 1. Buscar IDs das permissões pelo código
      final permsData = await _supabase
          .from('tb_permissoes')
          .select('id, code')
          .inFilter('code', permissions);

      final permsList = permsData as List;
      final permIds = permsList.map((p) => p['id'] as String).toList();
      debugPrint(
        'updatePermissions: encontrou ${permIds.length} permissões de ${permissions.length} solicitadas',
      );

      // 2. Limpar permissões atuais do cargo
      await _supabase
          .from('tb_cargo_permissoes')
          .delete()
          .eq('cargo_id', roleId);

      // 3. Inserir novas
      if (permIds.isNotEmpty) {
        final rows = permIds
            .map((pId) => {'cargo_id': roleId, 'permissao_id': pId})
            .toList();
        await _supabase.from('tb_cargo_permissoes').insert(rows);
        debugPrint(
          'updatePermissions: ${rows.length} permissões inseridas com sucesso',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar permissões: $e');
    }
  }

  @override
  Future<void> updateUser(
    UserModel user, {
    String? password,
    required String roleId,
    required bool isActive,
  }) async {
    try {
      // 1. Atualizar dados do perfil (tb_usuario)
      await _supabase
          .from('tb_usuario')
          .update({
            'nome': user.name,
            'login': user.login,
            'avatar_url': user.avatarUrl,
            'is_active': isActive,
          })
          .eq('id', user.id);

      // 2. Atualizar Cargo (tb_cargo_usuario)
      // Remove atual e insere novo
      await _supabase.from('tb_cargo_usuario').delete().eq('user_id', user.id);
      await _supabase.from('tb_cargo_usuario').insert({
        'user_id': user.id,
        'cargo_id': roleId,
      });

      // 3. Senha
      if (password != null && password.isNotEmpty) {
        // TODO: Implementar atualização de senha via Admin API ou RPC segura.
        // O Client SDK não permite mudar senha de outro usuário.
        debugPrint(
          "AVISO: Atualização de senha de terceiros não suportada via Client SDK direto.",
        );
      }
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar usuário: $e');
    }
  }

  @override
  Future<String> createUserReturningId(
    UserModel user,
    String password, {
    required String roleId,
    required bool isActive,
  }) async {
    // TODO: Criação de usuário requer Admin API (para não deslogar o admin).
    // Mantendo chamada de função ou lançando erro temporário para refactor posterior.
    throw ServerException(
      message: 'Criação de usuário requer migração para RPC Admin.',
    );
  }

  @override
  Future<void> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      await _supabase
          .from('tb_usuario')
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar avatar: $e');
    }
  }

  RealtimeChannel? _usersChannel;
  StreamController<void>? _usersChangesController;

  Stream<void> watchUsersChanges() {
    _usersChangesController ??= StreamController<void>.broadcast();
    if (_usersChannel != null) return _usersChangesController!.stream;

    _usersChannel = _supabase.channel('users-changes');
    _usersChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tb_usuario',
          callback: (payload) {
            _usersChangesController?.add(null);
          },
        )
        .subscribe();

    return _usersChangesController!.stream;
  }

  Future<void> disposeUsersWatcher() async {
    await _usersChannel?.unsubscribe();
    _usersChannel = null;
    await _usersChangesController?.close();
    _usersChangesController = null;
  }

  @override
  Future<List<String>> getUserIdsByRole(String roleName) async {
    try {
      // Passo 1: buscar o ID do cargo pelo nome
      final cargoData = await _supabase
          .from('tb_cargo')
          .select('id')
          .eq('name', roleName)
          .maybeSingle();

      if (cargoData == null) {
        debugPrint('Cargo "$roleName" não encontrado.');
        return [];
      }

      final cargoId = cargoData['id'].toString();

      // Passo 2: buscar usuários ativos vinculados a esse cargo
      final usuariosData = await _supabase
          .from('tb_cargo_usuario')
          .select('user_id, usuario:tb_usuario!user_id(is_active)')
          .eq('cargo_id', cargoId);

      final List items = usuariosData as List;
      return items
          .where((row) {
            final usuario = row['usuario'];
            if (usuario is Map) {
              return usuario['is_active'] == true;
            }
            return false;
          })
          .map<String>((row) => row['user_id'].toString())
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar usuários por cargo "$roleName": $e');
      return [];
    }
  }

  @override
  Future<List<String>> getUserIdsByPermission(String permissionCode) async {
    try {
      // Passo 1: buscar o ID da permissão pelo código
      final permData = await _supabase
          .from('tb_permissoes')
          .select('id')
          .eq('code', permissionCode)
          .maybeSingle();

      if (permData == null) {
        debugPrint('Permissão "$permissionCode" não encontrada.');
        return [];
      }

      final permId = permData['id'].toString();

      // Passo 2: buscar os cargo_ids que têm essa permissão
      final cargoPermsData = await _supabase
          .from('tb_cargo_permissoes')
          .select('cargo_id')
          .eq('permissao_id', permId);

      final List cargoPerms = cargoPermsData as List;
      if (cargoPerms.isEmpty) return [];

      final cargoIds = cargoPerms.map((c) => c['cargo_id'].toString()).toList();

      // Passo 3: buscar usuários ativos vinculados a esses cargos
      final usuariosData = await _supabase
          .from('tb_cargo_usuario')
          .select('user_id, usuario:tb_usuario!user_id(is_active)')
          .inFilter('cargo_id', cargoIds);

      final List items = usuariosData as List;
      return items
          .where((row) {
            final usuario = row['usuario'];
            if (usuario is Map) {
              return usuario['is_active'] == true;
            }
            return false;
          })
          .map<String>((row) => row['user_id'].toString())
          .toSet() // Remove duplicados (usuário com múltiplos cargos)
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar usuários por permissão "$permissionCode": $e');
      return [];
    }
  }
}
