import 'dart:io';
import 'package:agenda/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';

import 'app/app.dart';
import 'core/config/env.dart';

/// Ponto de entrada da aplicação.
///
/// Inicializa todos os serviços necessários antes de executar o app:
/// 1. Widgets Flutter
/// 2. Injeção de dependência (GetIt)
/// 3. Variáveis de ambiente (.env)
/// 4. Supabase (banco de dados)
/// 5. Firebase e Push Notifications (apenas Android/iOS)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a injeção de dependência
  setupServiceLocator();

  try {
    // Carrega variáveis de ambiente
    await Env.load();

    // Inicializa o Supabase
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);

    // Inicializa Firebase/Push (Apenas Android/iOS)
    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await getIt<PushNotificationService>().initialize();
    } else {
      debugPrint("Push Notifications desativados: ${Platform.operatingSystem}");
    }
  } catch (e, stackTrace) {
    debugPrint("ERRO FATAL NA INICIALIZAÇÃO: $e");
    debugPrint(stackTrace.toString());
  }

  // Inicia a aplicação
  runApp(const App());
}
