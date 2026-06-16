import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agenda/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/i_notification_repository.dart';

/// Implementação do repositório de Notificações usando Supabase com RLS.
/// RLS no banco filtra automaticamente por user_id OU por cargo do usuário.
class NotificationRepositorySupabase implements INotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepositorySupabase({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  StreamController<List<NotificationModel>>? _controller;
  String? _currentUserId;
  RealtimeChannel? _channelNotifications;
  RealtimeChannel? _channelReads;
  Timer? _debounce;

  /// IDs de notificações que o usuário deletou localmente.
  /// Mesmo que o DB delete falhe (RLS), esses IDs ficam filtrados na sessão.
  final Set<String> _deletedIds = {};

  @override
  Stream<List<NotificationModel>> getNotificationsStream(
    String userId,
    List<String>
    userRoles, // Mantido para compatibilidade, mas não usado no filtro
  ) {
    if (_controller != null &&
        _currentUserId == userId &&
        !_controller!.isClosed) {
      _fetchAndEmit();
      return _controller!.stream;
    }

    _closeController();

    _currentUserId = userId;

    _controller = StreamController<List<NotificationModel>>.broadcast(
      onListen: () {
        _fetchAndEmit();
      },
    );

    _setupRealtime(userId);

    return _controller!.stream;
  }

  void _closeController() {
    _debounce?.cancel();
    _channelNotifications?.unsubscribe();
    _channelReads?.unsubscribe();
    _controller?.close();
    _controller = null;
  }

  Future<void> _setupRealtime(String userId) async {
    // Escuta novas notificações
    _channelNotifications = _supabase.channel('public:tb_notificacao:global');
    _channelNotifications!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tb_notificacao',
          callback: (payload) => _debouncedFetch(),
        )
        .subscribe();

    // Escuta atualizações de leitura
    _channelReads = _supabase.channel('public:tb_notificacoes_leituras:global');
    _channelReads!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tb_notificacoes_leituras',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_usuario',
            value: userId,
          ),
          callback: (payload) => _debouncedFetch(),
        )
        .subscribe();
  }

  void _debouncedFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _fetchAndEmit);
  }

  Future<void> _fetchAndEmit() async {
    if (_controller == null || _controller!.isClosed) return;
    if (_currentUserId == null) return;

    try {
      // Filtra explicitamente por user_id do usuário logado
      // Cada notificação gerada tem um user_id específico
      final data = await _supabase
          .from('tb_notificacao')
          .select('*, tb_notificacoes_leituras!left(id, id_usuario)')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      final List items = data as List;

      final models = items
          .map<NotificationModel>((json) {
            // Verifica se O USUARIO ATUAL já leu esta notificação
            final readingsData = json['tb_notificacoes_leituras'];
            bool isRead = false;

            if (readingsData is List) {
              isRead = readingsData.any(
                (r) =>
                    r is Map && r['id_usuario']?.toString() == _currentUserId,
              );
            } else if (readingsData is Map) {
              isRead = readingsData['id_usuario']?.toString() == _currentUserId;
            }

            return NotificationModel.fromMap(json, isRead: isRead);
          })
          // Filtra IDs que o usuário já excluiu localmente nessa sessão
          .where((n) => !_deletedIds.contains(n.id))
          .toList();

      if (!_controller!.isClosed) {
        _controller!.add(models);
      }
    } catch (e) {
      debugPrint('Erro ao buscar notificações: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _supabase.from('tb_notificacoes_leituras').upsert({
        'id_notificacao': notificationId,
        'id_usuario': userId,
        'is_read': true,
        'lida_em': DateTime.now().toIso8601String(),
      }, onConflict: 'id_notificacao,id_usuario');
      await _fetchAndEmit();
    } catch (e) {
      debugPrint('Erro ao marcar notificação: $e');
      throw ServerException(message: 'Erro ao marcar notificação como lida.');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      // Filtra apenas as notificações do usuário atual
      final data = await _supabase
          .from('tb_notificacao')
          .select('id, tb_notificacoes_leituras!left(id, id_usuario)')
          .eq('user_id', userId);

      final List items = data as List;
      final unreadIds = items
          .where((json) {
            final readingsData = json['tb_notificacoes_leituras'];
            if (readingsData is List) {
              // Não lida se não existe entrada para este usuário
              return !readingsData.any(
                (r) => r is Map && r['id_usuario']?.toString() == userId,
              );
            } else if (readingsData is Map) {
              return readingsData['id_usuario']?.toString() != userId;
            }
            return true; // null = não lido
          })
          .map((json) => json['id'] as String)
          .toList();

      if (unreadIds.isEmpty) return;

      final records = unreadIds
          .map(
            (id) => {
              'id_notificacao': id,
              'id_usuario': userId,
              'is_read': true,
              'lida_em': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      await _supabase
          .from('tb_notificacoes_leituras')
          .upsert(records, onConflict: 'id_notificacao,id_usuario');
      await _fetchAndEmit();
    } catch (e) {
      debugPrint('Erro ao marcar todas: $e');
      throw ServerException(message: 'Erro ao marcar todas como lidas.');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    // Marca como deletado localmente ANTES de tentar o banco
    _deletedIds.add(notificationId);
    try {
      // 1. Remove as leituras associadas (FK constraint exige deletar antes)
      await _supabase
          .from('tb_notificacoes_leituras')
          .delete()
          .eq('id_notificacao', notificationId);

      // 2. Agora remove a notificação
      await _supabase.from('tb_notificacao').delete().eq('id', notificationId);

      // Sucesso: remove do set pois a linha foi apagada do banco
      _deletedIds.remove(notificationId);

      // 3. Força o stream a emitir dados limpos imediatamente
      await _fetchAndEmit();
    } catch (e) {
      debugPrint('Erro ao deletar notificação no banco: $e');
      // Mantém em _deletedIds para continuar filtrado no stream
      // Força re-emit filtrando pelo _deletedIds
      await _fetchAndEmit();
    }
  }

  @override
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await _supabase.from('tb_notificacao').insert({
        'user_id': userId,
        'titulo': title,
        'mensagem': body,
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação para $userId: $e');
      // Silencia o erro para não quebrar o fluxo principal de cadastro/edição
    }
  }
}
