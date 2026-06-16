/// Exceção base do aplicativo.
///
/// Todas as exceções customizadas devem estender esta classe
/// para permitir tratamento unificado de erros.
abstract class AppException implements Exception {
  /// Mensagem descritiva do erro
  final String message;

  /// Código HTTP de status (opcional)
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message';
}

/// Representa erros vindos da API ou Banco de Dados (ex: Supabase).
///
/// Usada quando há falha na comunicação com o backend,
/// como erros HTTP 500 ou problemas de conexão.
class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

/// Representa erros de regras de negócio de Autenticação.
///
/// Usada para erros como senha incorreta, usuário não encontrado,
/// token expirado, etc.
class AuthException extends AppException {
  AuthException(String message) : super(message: message);
}

/// Representa erros ao acessar cache local ou SecureStorage.
///
/// Usada quando há falha ao ler/escrever dados locais.
class CacheException extends AppException {
  CacheException(String message) : super(message: message);
}
