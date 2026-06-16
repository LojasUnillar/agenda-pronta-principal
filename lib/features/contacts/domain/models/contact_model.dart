/// Implementação concreta de [ContactEntity] com suporte a serialização.
///
/// Responsável pela conversão de dados entre a aplicação (Dart) e
/// o banco de dados Supabase (JSON).
class ContactModel {
  final String id;
  final String name;
  final String? socialName;
  String status;
  final DateTime? lastUpdate;
  final String? imageUrl;
  final String? email;
  final String? cnpj;
  final String type; // Fornecedor, Distribuidora, etc.
  final List<String> brandIds;
  final List<String> productIds;
  final int usageCount; // Para ordenação por frequência
  final bool isFavorite;
  final String? about;

  // Campos de Cadastro
  final List<String> departments; // IDs dos departamentos
  final String? representative; // Nome
  final List<String> representativeIds;
  final String? turnoverCode; // codigo_erp
  final String? minDeliveryTime; // tempo_entrega (15 dias, etc)
  final String? billingTime; // tempo_faturamento
  final int? tenureValue; // tempo_casa_valor
  final String? tenureUnit; // tempo_casa_unidade
  final bool hasAssistance; // tem_assistencia
  final List<String> assistancePhones; // num_assistencia
  final List<String> devolucaoPhones; // num_devolucao
  final List<String> financeiroPhones; // num_financeiro
  final List<String> outroPhones; // num_outro
  String? outroLabel; // outro_label
  final bool hasInvoice; // tem_nota / emite_nota_fiscal
  final String? mainSite; // site_principal / site
  final bool hasBoletoSite; // tem_boleto / tem_site_boletos
  final String? boletoSiteLink; // site_boleto
  final String? regionOfActivity; // reg_atuacao
  final String? birthday; // data_aniversario
  final String? personality; // personalidade
  final bool? isMarried; // casado
  final String? spouseName; // nome_conjugue
  final bool? hasChildren; // tem_filhos
  final String? childrenNames; // nome_filhos
  final String? marketTime; // tempo_mercado
  final String? address; // endereco
  String? deactivationReason; // motivo_inativacao

  ContactModel({
    required this.id,
    required this.name,
    this.socialName,
    required this.status,
    this.lastUpdate,
    this.imageUrl,
    this.email,
    this.cnpj,
    required this.type,
    this.brandIds = const [],
    this.productIds = const [],
    this.usageCount = 0,
    this.isFavorite = false,
    this.about,
    this.departments = const [],
    this.representative,
    this.representativeIds = const [],
    this.turnoverCode,
    this.minDeliveryTime,
    this.billingTime,
    this.tenureValue,
    this.tenureUnit,
    this.hasAssistance = false,
    this.assistancePhones = const [],
    this.devolucaoPhones = const [],
    this.financeiroPhones = const [],
    this.outroPhones = const [],
    this.outroLabel,
    this.hasInvoice = false,
    this.mainSite,
    this.hasBoletoSite = false,
    this.boletoSiteLink,
    this.regionOfActivity,
    this.birthday,
    this.personality,
    this.isMarried,
    this.spouseName,
    this.hasChildren,
    this.childrenNames,
    this.marketTime,
    this.address,
    this.deactivationReason,
  });

  /// Converte o modelo para um mapa (JSON para Supabase)
  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome_fantasia': name,
      'razao_social': socialName?.isNotEmpty == true ? socialName : null,
      'cnpj': cnpj?.isNotEmpty == true ? cnpj : null,
      'tipo_contato': type,
      'email': email?.isNotEmpty == true ? email : null,
      'departamentos': departments,
      'representantes': representativeIds,
      'marcas': brandIds,
      'produtos': productIds,
      'info_adicional': about,
      'is_actived': status == 'Ativo',
      'codigo_erp': turnoverCode?.isNotEmpty == true ? turnoverCode : null,
      'tempo_entrega': minDeliveryTime,
      'tempo_faturamento': billingTime,
      'tempo_casa': tenureValue != null
          ? '${tenureValue} ${tenureUnit?.isNotEmpty == true ? tenureUnit : ''}'
              .trim()
          : null,
      'tem_assistencia': hasAssistance,
      'num_assistencia': assistancePhones.join('; '),
      'num_devolucao': devolucaoPhones.join('; '),
      'num_financeiro': financeiroPhones.join('; '),
      'num_outro': outroPhones.join('; '),
      'outro_label': outroLabel,
      'tem_nota': hasInvoice,
      'emite_nota_fiscal': hasInvoice,
      'site': mainSite,
      'tem_boleto': hasBoletoSite,
      'site_boleto': boletoSiteLink,
      'reg_atuacao': regionOfActivity,
      'data_aniversario': birthday,
      'personalidade': personality,
      'casado': isMarried,
      'nome_conjugue': spouseName,
      'tem_filhos': hasChildren,
      'nome_filhos': childrenNames,
      'tempo_mercado': marketTime,
      'endereco': address,
      'motivo_inativacao': deactivationReason,
    };
  }

  /// Cria uma instância a partir de um mapa (JSON do Supabase)
  factory ContactModel.fromMap(Map<String, dynamic> map) {
    int? tValue;
    String? tUnit;
    if (map['tempo_casa'] != null) {
      final raw = map['tempo_casa'].toString().trim();
      if (raw.isNotEmpty) {
        final parts = raw.split(' ');
        tValue = int.tryParse(parts[0]);
        // Aceita qualquer unidade que não seja lixo (ex: "$tenureUnit" ou "null")
        if (parts.length > 1 &&
            parts[1].isNotEmpty &&
            parts[1] != 'null' &&
            !parts[1].startsWith(r'$')) {
          tUnit = parts[1];
        }
      }
    }

    return ContactModel(
      id: map['id'] ?? '',
      name: map['nome_fantasia'] ?? 'Sem Nome',
      socialName: map['razao_social'],
      status: (map['is_actived'] ?? true) ? 'Ativo' : 'Inativo',
      lastUpdate: map['update_at'] != null
          ? DateTime.tryParse(map['update_at'].toString())
          : null,
      imageUrl: map['logo_url'],
      email: map['email'],
      cnpj: map['cnpj'],
      type: map['tipo_contato'],
      brandIds: map['marcas'] != null ? List<String>.from(map['marcas']) : [],
      productIds:
          map['produtos'] != null ? List<String>.from(map['produtos']) : [],
      usageCount: 0,
      isFavorite: false,
      about: map['info_adicional'],
      departments: map['departamentos'] != null
          ? List<String>.from(map['departamentos'])
          : [],
      representative: null,
      representativeIds: map['representantes'] != null
          ? List<String>.from(map['representantes'])
          : [],
      turnoverCode: map['codigo_erp'],
      minDeliveryTime: map['tempo_entrega'],
      billingTime: map['tempo_faturamento'],
      tenureValue: tValue,
      tenureUnit: tUnit,
      hasAssistance: map['tem_assistencia'] ?? false,
      assistancePhones: (map['num_assistencia'] as String?)?.split('; ') ?? [],
      devolucaoPhones: (map['num_devolucao'] as String?)?.split('; ') ?? [],
      financeiroPhones: (map['num_financeiro'] as String?)?.split('; ') ?? [],
      outroPhones: (map['num_outro'] as String?)?.split('; ') ?? [],
      outroLabel: map['outro_label'],
      hasInvoice: map['emite_nota_fiscal'] ?? map['tem_nota'] ?? false,
      mainSite: map['site'],
      hasBoletoSite: map['tem_boleto'] ?? false,
      boletoSiteLink: map['site_boleto'],
      regionOfActivity: map['reg_atuacao'],
      birthday: map['data_aniversario'],
      personality: map['personalidade'],
      isMarried: map['casado'],
      spouseName: map['nome_conjugue'],
      hasChildren: map['tem_filhos'],
      childrenNames: map['nome_filhos'],
      marketTime: map['tempo_mercado'],
      address: map['endereco'],
      deactivationReason: map['motivo_inativacao'],
    );
  }
}
