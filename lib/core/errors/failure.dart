/// Classe base para manipulação de falhas e erros no domínio.
/// 
/// Representa falhas de negócio que podem ser tratadas de forma
/// previsível pela aplicação, diferente de exceções técnicas.
abstract class Failure {
  /// Mensagem descritiva da falha
  final String message;
  
  const Failure(this.message);
}

/// Falha relacionada a erros no servidor ou API.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor. Tente novamente.']);
}

/// Falha relacionada a autenticação ou autorização.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Falha relacionada a conectividade de rede.
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Sem conexão com a internet.']);
}
