/// Enum para filtrar usuários por status.
/// 
/// Utilizado na tela de busca de usuários para filtrar
/// entre usuários ativos, inativos ou ambos.
enum UserStatusFilter { 
  /// Todos os usuários (ativos e inativos)
  all, 
  
  /// Apenas usuários ativos
  active, 
  
  /// Apenas usuários inativos
  inactive 
}

/// Extensão com helpers para UserStatusFilter.
/// 
/// Fornece labels amigáveis e valores para parâmetros de API.
extension UserStatusFilterX on UserStatusFilter {
  /// Label amigável para exibição na UI.
  String get label {
    switch (this) {
      case UserStatusFilter.active:
        return 'Ativo';
      case UserStatusFilter.inactive:
        return 'Inativo';
      case UserStatusFilter.all:
        return 'Todos';
    }
  }

  /// Valor booleano para filtro de API.
  /// 
  /// Retorna `true` para ativos, `false` para inativos,
  /// ou `null` para todos (sem filtro).
  bool? get isActiveParam {
    switch (this) {
      case UserStatusFilter.active:
        return true;
      case UserStatusFilter.inactive:
        return false;
      case UserStatusFilter.all:
        return null;
    }
  }
}
