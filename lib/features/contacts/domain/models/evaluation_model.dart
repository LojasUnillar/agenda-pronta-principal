/// Modelo de domínio que representa uma avaliação ou comentário sobre um fornecedor.
///
/// Um registro pode representar:
/// - Uma **avaliação** (com [rating] preenchido e [comment] nulo)
/// - Uma **anotação/observação** (com [comment] preenchido e [rating] nulo)
/// - Ambos ao mesmo tempo
class EvaluationModel {
  /// ID único do registro (gerado pelo Supabase)
  final String id;

  /// ID do contato avaliado
  final String contactId;

  /// ID do usuário que fez a avaliação
  final String userId;

  /// Nome do usuário (resolvido via JOIN com tb_usuario)
  final String userName;

  /// Nota de 1 a 5 estrelas. Nulo se for apenas uma anotação.
  final int? rating;

  /// Texto da observação. Nulo se for apenas uma avaliação de estrelas.
  final String? comment;

  /// Data e hora de criação do registro
  final DateTime createdAt;

  EvaluationModel({
    required this.id,
    required this.contactId,
    required this.userId,
    required this.userName,
    this.rating,
    this.comment,
    required this.createdAt,
  });

  /// Converte o modelo para um mapa JSON (Supabase).
  /// Ignora nulls e os campos calculados como `userName`.
  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'contact_id': contactId,
      'user_id': userId,
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
      // created_at é geralmente gerado pelo banco
    };
  }

  /// Cria uma instância a partir de um mapa (JSON do Supabase).
  /// Espera que a query tenha trazido a tabela relacionada `tb_usuario`.
  factory EvaluationModel.fromMap(Map<String, dynamic> map) {
    String pUserName = 'Usuário Desconhecido';

    // Fazendo parse da join do Supabase "tb_usuario(nome/name)"
    if (map['tb_usuario'] != null && map['tb_usuario'] is Map) {
      final userMap = map['tb_usuario'] as Map;
      pUserName = userMap['nome'] ?? userMap['name'] ?? pUserName;
    }

    return EvaluationModel(
      id: map['id']?.toString() ?? '',
      contactId: map['contact_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      userName: pUserName,
      rating: map['rating'] != null
          ? int.tryParse(map['rating'].toString())
          : null,
      comment: map['comment'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
