import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler global para processamento de mensagens quando o app está em Background ou Terminado.
///
/// Deve ser uma função top-level e anotada com [@pragma('vm:entry-point')] para garantir
/// que a VM do Dart possa invocá-la mesmo com o app fechado.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // 👈 ADICIONE ISSO
  debugPrint("Mensagem em background: ${message.messageId}");
}

/// Canal de notificação principal do app (obrigatório para Android 8+).
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'agenda_high_importance_channel',
  'Notificações do Agenda',
  description: 'Notificações importantes do aplicativo Agenda.',
  importance: Importance.high,
);

/// Plugin de notificações locais (para exibir notificações em foreground).
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Serviço responsável pelo gerenciamento de Push Notifications via Firebase Cloud Messaging (FCM).
///
/// Gerencia o ciclo de vida das notificações:
/// - Solicitação de permissões ao usuário
/// - Obtenção e log do token FCM do dispositivo
/// - Exibição de notificações em primeiro plano (Foreground) via flutter_local_notifications
/// - Manipulação de mensagens em segundo plano (Background)
class PushNotificationService {
  FirebaseMessaging? _firebaseMessaging;

  /// Inicializa o serviço de notificações.
  ///
  /// Realiza as seguintes operações:
  /// 1. Verifica se a plataforma é suportada (Android/iOS).
  /// 2. Solicita permissões de notificação (som, alerta, badge).
  /// 3. Configura canal de notificação para Android.
  /// 4. Configura os listeners para mensagens (Background e Foreground).
  /// 5. Obtém o token inicial do dispositivo.
  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _firebaseMessaging = FirebaseMessaging.instance;

    // Solicita permissão para notificações
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('Permissão de notificação negada.');
    }

    // Inicializa flutter_local_notifications
    await _initLocalNotifications();

    // Handler de mensagens em background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler de mensagens em FOREGROUND — exibe notificação local visível
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensagem recebida em primeiro plano: ${message.data}');
      _showLocalNotification(message);
    });

    // Habilita exibição de notificações em foreground no iOS
    await _firebaseMessaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtém o token FCM
    await getToken();
  }

  /// Inicializa o plugin flutter_local_notifications e cria o canal Android.
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Cria o canal de notificação no Android 8+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  /// Exibe uma notificação local visível na barra de status.
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Obtém o token FCM atual do dispositivo.
  ///
  /// Este token é utilizado para enviar notificações direcionadas a este aparelho.
  /// Retorna `null` em caso de erro ou se a plataforma não for suportada.
  Future<String?> getToken() async {
    if ((!Platform.isAndroid && !Platform.isIOS) ||
        _firebaseMessaging == null) {
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          _firebaseMessaging = FirebaseMessaging.instance;
        } catch (e) {
          debugPrint("PushNotificationService: Firebase não inicializado. $e");
          return null;
        }
      } else {
        return null;
      }
    }

    try {
      String? token = await _firebaseMessaging!.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Erro ao pegar token FCM: $e");
      return null;
    }
  }
}
