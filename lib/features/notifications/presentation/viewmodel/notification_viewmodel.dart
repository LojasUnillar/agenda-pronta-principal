import 'dart:async';
import 'package:agenda/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/notification_model.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';

/// ViewModel responsável pelo gerenciamento de estado da Tela de Notificações.
/// Controla a lista de notificações, filtros, seleção múltipla e ações de leitura/exclusão.
class NotificationViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final INotificationRepository _notificationRepository;

  NotificationViewModel(this._authRepository, this._notificationRepository);

  StreamSubscription? _subscription;
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? get user => _authRepository.currentUser;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Inicializa a escuta da lista
  void init() {
    final userId = user?.id;
    if (userId == null) {
      _errorMessage = 'Usuário não identificado.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _notificationRepository
        .getNotificationsStream(userId, user?.roles ?? [])
        .listen(
          (data) {
            _notifications = data;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Erro notificações: $e");
            if (e is AppException) {
              _errorMessage = e.message;
            } else {
              _errorMessage = 'Erro ao carregar notificações.';
            }
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // ================== SELEÇÃO (CHECKBOX) ==================
  final Set<String> _selectedIds = {};
  bool _manualSelectionMode = false;

  Set<String> get selectedIds => _selectedIds;
  bool get isSelectionMode => _manualSelectionMode || _selectedIds.isNotEmpty;

  void toggleSelectionMode() {
    _manualSelectionMode = !_manualSelectionMode;
    if (!_manualSelectionMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
      _manualSelectionMode =
          true; // Garante que o modo fica ativo ao selecionar
    }
    notifyListeners();
  }

  void selectAll() {
    if (_selectedIds.length == _notifications.length) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_notifications.map((e) => e.id));
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _manualSelectionMode = false;
    notifyListeners();
  }

  // ================== AÇÕES ==================

  Future<void> markAsRead(String id) async {
    try {
      // Atualização otimista
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      final userId = user?.id;
      if (userId != null) {
        await _notificationRepository.markAsRead(id, userId);
      }
    } catch (e) {
      debugPrint('Erro ao marcar como lida: $e');
      // Em caso de erro real, poderíamos reverter, mas em notificação não é crítico.
    }
  }

  Future<void> markSelectedAsRead() async {
    // Atualização otimista
    for (final id in _selectedIds) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    }
    notifyListeners();

    // Envia para backend
    final userId = user?.id;
    if (userId != null) {
      for (final id in _selectedIds) {
        _notificationRepository.markAsRead(id, userId).ignore();
      }
    }
    clearSelection();
  }

  Future<void> markAllAsRead() async {
    final userId = user?.id;
    if (userId != null) {
      try {
        // Atualização otimista
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        notifyListeners();

        await _notificationRepository.markAllAsRead(userId);
        clearSelection();
      } catch (e) {
        debugPrint('Erro ao marcar todas como lidas: $e');
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationRepository.deleteNotification(id);
      _selectedIds.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao excluir: $e');
    }
  }

  Future<void> deleteSelected() async {
    final idsToDelete = List<String>.from(_selectedIds);

    // Remoção otimista — remove da lista local imediatamente
    _notifications.removeWhere((n) => idsToDelete.contains(n.id));
    clearSelection(); // notifyListeners() aqui

    // Aguarda todos os deletes no banco em paralelo
    await Future.wait(
      idsToDelete.map(
        (id) => _notificationRepository.deleteNotification(id).catchError((e) {
          debugPrint('Erro ao excluir $id: $e');
        }),
      ),
    );

    // Notifica após todos os deletes para garantir UI atualizada
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
