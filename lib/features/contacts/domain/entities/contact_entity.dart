/// Entidade de domínio representando um contato (Fornecedor, Representante, etc).
///
/// Contém todos os dados de negócio de um contato, sem acoplamento com
/// infraestrutura ou serialização JSON.
class ContactEntity {
  final String id;
  final String name;
  final String? socialName;
  final String status;
  final DateTime? lastUpdate;
  final String? imageUrl;
  final String? email;
  final String? cnpj;
  final String? type;
  final List<String> brandIds;
  final List<String> productIds;
  final int usageCount;
  final bool isFavorite;
  final String? about;

  // Campos de Cadastro
  final List<String> departments;
  final String? representative;
  final List<String> representativeIds;
  final String? turnoverCode;
  final String? minDeliveryTime;
  final String? billingTime;
  final int? tenureValue;
  final String? tenureUnit;
  final bool hasAssistance;
  final List<String> assistancePhones;
  final List<String> devolucaoPhones;
  final List<String> financeiroPhones;
  final List<String> outroPhones;
  final String? outroLabel;
  final bool hasInvoice;
  final String? mainSite;
  final bool hasBoletoSite;
  final String? boletoSiteLink;
  final String? regionOfActivity;
  final String? birthday;
  final String? personality;
  final bool? isMarried;
  final String? spouseName;
  final bool? hasChildren;
  final String? childrenNames;
  final String? marketTime;
  final String? address;

  const ContactEntity({
    required this.id,
    required this.name,
    this.socialName,
    required this.status,
    this.lastUpdate,
    this.imageUrl,
    this.email,
    this.cnpj,
    this.type,
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
  });
}
