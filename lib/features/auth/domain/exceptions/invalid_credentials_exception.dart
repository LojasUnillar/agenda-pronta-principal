/// Exceção lançada quando as credenciais de autenticação são inválidas.
/// 
/// Usada durante o processo de login quando o usuário ou senha
/// não correspondem a um usuário válido no sistema.
class InvalidCredentialsException {
  /// Mensagem descritiva do erro
  final String message;

  /// Cria uma nova exceção de credenciais inválidas
  /// 
  /// [message] - Mensagem opcional (padrão: 'Usuário ou senha inválidos')
  InvalidCredentialsException([
    this.message = 'Usuário ou senha inválidos'
  ]);

  @override
  String toString() => message;
}

/// Exceção genérica de autenticação.
/// 
/// Usada para erros relacionados à autenticação que não se encaixam
/// em categorias específicas.
class AuthException implements Exception {
  /// Mensagem descritiva do erro
  final String message;

  /// Cria uma nova exceção de autenticação
  /// 
  /// [message] - Mensagem descritiva do erro
  AuthException(this.message);

  @override
  String toString() => message;
}
