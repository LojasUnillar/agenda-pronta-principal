import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../departments/domain/repositories/i_department_repository.dart';
import '../../../notifications/domain/repositories/i_notification_repository.dart';
import '../mappers/department_to_quick_access_mapper.dart';
import '../models/quick_access_item.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// ViewModel da tela principal.
///
/// Responsabilidades:
/// - Gerenciar o estado global da Home (índice da navegação, avatar, usuário).
/// - Ouvir notificações em tempo real via [INotificationRepository].
/// - Carregar itens de acesso rápido (departamentos ativos) via [IDepartmentRepository].
/// - Gerenciar cache e atualização de imagem de avatar.
/// - Sincronizar token FCM para push notifications.
class HomeViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final INotificationRepository _notificationRepository;
  final IDepartmentRepository _departmentRepository;
  final PushNotificationService _pushNotificationService;
  final ConnectivityService _connectivityService;

  HomeViewModel(
    this._authRepository,
    this._notificationRepository,
    this._departmentRepository,
    this._pushNotificationService,
    this._connectivityService,
  );

  // ================== NAVEGAÇÃO ==================
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  // ================== USUÁRIO ==================

  int _userVersion = DateTime.now().millisecondsSinceEpoch;

  UserModel? get user => _authRepository.currentUser;

  String get userInitials {
    final name = user?.name ?? "";
    if (name.isEmpty) return "-";

    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  String? get userAvatarUrl {
    final url = user?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    return url.contains('?') ? "$url&v=$_userVersion" : "$url?v=$_userVersion";
  }

  File? _tempAvatarFile;
  bool _isPrecachingAvatar = false;

  File? get tempAvatarFile => _tempAvatarFile;

  void setTempAvatar(File file) {
    _tempAvatarFile = file;
    notifyListeners();
  }

  void clearTempAvatar() {
    _tempAvatarFile = null;
    notifyListeners();
  }

  Future<void> finalizeTempAvatar(BuildContext context) async {
    if (_tempAvatarFile == null) return;
    final url = userAvatarUrl;
    if (url == null || url.isEmpty) {
      clearTempAvatar();
      return;
    }

    if (_isPrecachingAvatar) return;
    _isPrecachingAvatar = true;

    try {
      await precacheImage(NetworkImage(url), context);
    } catch (_) {
      _isPrecachingAvatar = false;
      return;
    }

    _isPrecachingAvatar = false;
    clearTempAvatar();
  }

  Future<void> reloadUser() async {
    if (!await _connectivityService.isConnected) return;

    await _authRepository.refreshCurrentUser();
    _userVersion = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  // ================== NOTIFICAÇÕES ==================
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  String get notificationText =>
      _notificationCount > 10 ? "10+" : _notificationCount.toString();

  StreamSubscription? _notificationsSubscription;

  void startNotificationsListener() async {
    final userId = user?.id;
    if (userId == null) {
      // Tenta novamente em breve caso o usuário ainda não tenha sido carregado
      Future.delayed(const Duration(seconds: 1), startNotificationsListener);
      return;
    }

    if (!await _connectivityService.isConnected) return;

    // Atualiza token FCM
    _pushNotificationService.getToken().then((token) {
      if (token != null) {
        _authRepository.saveFcmToken(userId, token);
      }
    });

    // Reinicia subscription se necessário
    _notificationsSubscription?.cancel();

    _notificationsSubscription = _notificationRepository
        .getNotificationsStream(userId, user?.roles ?? [])
        .listen(
          (notifications) {
            _notificationCount = notifications.where((n) => !n.isRead).length;
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Erro ao ouvir notificações: $e");
          },
        );
  }

  void stopNotificationsListener() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  // ================== QUICK ACCESS ==================
  List<QuickAccessItem> _quickAccessItems = [];

  List<QuickAccessItem> get quickAccessItems => _quickAccessItems;

  bool _isLoadingDepartments = true;

  bool get isLoadingDepartments => _isLoadingDepartments;

  Future<void> loadQuickAccess() async {
    _isLoadingDepartments = true;
    notifyListeners();

    if (!await _connectivityService.isConnected) {
      _isLoadingDepartments = false;
      notifyListeners();
      return;
    }

    try {
      final departments = await _departmentRepository.getActiveDepartments();
      _quickAccessItems = departments
          .map((d) => d.toQuickAccessItem())
          .toList();
    } catch (e) {
      debugPrint("Erro ao carregar departamentos: $e");
    } finally {
      _isLoadingDepartments = false;
      notifyListeners();
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    stopNotificationsListener();
    // Apenas lógica. UI gerencia a navegação.
  }

  @override
  void dispose() {
    stopNotificationsListener();
    super.dispose();
  }
}
