import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe responsável por carregar e gerenciar variáveis de ambiente.
/// 
/// Utiliza o pacote flutter_dotenv para carregar configurações
/// de arquivos .env, permitindo diferentes configurações para
/// desenvolvimento e produção.
/// 
/// Também realiza ajustes automáticos para emulador Android.
class Env {
  /// Indica se está em modo de produção
  /// Altere para `true` para usar .env.prod
  static const bool isProduction = false;

  /// Carrega as variáveis de ambiente do arquivo apropriado.
  /// 
  /// Seleciona automaticamente entre .env.dev e .env.prod
  /// baseado na flag [isProduction].
  /// 
  /// Lança uma exceção se o arquivo não for encontrado.
  static Future<void> load() async {
    final String fileName = isProduction ? '.env.prod' : '.env.dev';

    try {
      await dotenv.load(fileName: 'assets/env/$fileName');
    } catch (e) {
      throw Exception(
        'Arquivo de ambiente $fileName não encontrado em assets/env/',
      );
    }
  }

  /// URL do Supabase.
  /// 
  /// Ajusta automaticamente o host para 10.0.2.2 quando
  /// detecta que está rodando no emulador Android.
  /// 
  /// Lança exceção se a variável não estiver definida.
  static String get supabaseUrl {
    var value = dotenv.env['SUPABASE_URL'];
    if (value == null || value.isEmpty) {
      throw Exception('SUPABASE_URL não definida');
    }

    // Ajuste automático para Emulador Android
    if (Platform.isAndroid &&
        (value.contains('127.0.0.1') || value.contains('localhost'))) {
      value = value
          .replaceFirst('127.0.0.1', '10.0.2.2')
          .replaceFirst('localhost', '10.0.2.2');
    }

    return value;
  }

  /// Chave anônima do Supabase.
  /// 
  /// Lança exceção se a variável não estiver definida.
  static String get supabaseKey {
    final value = dotenv.env['SUPABASE_KEY'];
    if (value == null || value.isEmpty) {
      throw Exception('SUPABASE_KEY não definida');
    }
    return value;
  }
}
