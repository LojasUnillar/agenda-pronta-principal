import 'package:connectivity_plus/connectivity_plus.dart';

/// Serviço responsável pelo monitoramento de conectividade de rede.
///
/// Utiliza o pacote [connectivity_plus] para verificar o status da conexão
/// (Wi-Fi, Dados Móveis, Ethernet, etc).
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica se o dispositivo possui conexão ativa com a internet.
  ///
  /// Retorna `true` se houver conexão (Wi-Fi, Mobile, Ethernet, VPN, etc).
  /// Retorna `false` caso o dispositivo esteja desconectado ([ConnectivityResult.none]).
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // Suporta a API v6.0.0+ que retorna List<ConnectivityResult>
    return !result.contains(ConnectivityResult.none);
  }
}
