/// Modelo de dados que representa uma Notificação do sistema.
/// 
/// Contém informações de título, mensagem, status de leitura
/// e metadados de criação.
class NotificationModel {
  /// ID único da notificação
  final String id;
  
  /// Título da notificação
  final String title;
  
  /// Corpo/mensagem da notificação
  final String body;
  
  /// Indica se já foi lida pelo usuário
  final bool isRead;
  
  /// ID do usuário destinatário
  final String userId;
  
  /// Data de criação
  final DateTime createdAt;

  /// Cria uma nova notificação
  /// 
  /// [id] - Identificador único
  /// [title] - Título
  /// [body] - Mensagem
  /// [isRead] - Status de leitura
  /// [userId] - ID do destinatário
  /// [createdAt] - Data de criação
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.userId,
    required this.createdAt,
  });

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  /// 
  /// [isRead] - Parâmetro separado pois vem de join com tabela de leituras
  factory NotificationModel.fromMap(
    Map<String, dynamic> map, {
    bool isRead = false,
  }) {
    return NotificationModel(
      id: map['id'].toString(),
      title: map['titulo'] ?? 'Sem Título',
      body: map['mensagem'] ?? '',
      isRead: isRead,
      userId: map['user_id'].toString(),
      createdAt:
          DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
    );
  }

  /// Cria uma cópia com valores alterados.
  /// 
  /// Útil para atualizações otimistas na UI.
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? userId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
