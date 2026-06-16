import 'package:flutter/material.dart';
import 'package:agenda/features/contacts/domain/models/contact_model.dart';
import 'package:agenda/core/widgets/app_button.dart';
import 'package:agenda/core/di/service_locator.dart';
import 'package:agenda/features/contacts/domain/repositories/i_supplier_repository.dart';
import 'package:agenda/app/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agenda/features/contacts/presentation/viewmodel/contact_registration_viewmodel.dart';
import 'package:agenda/features/contacts/presentation/pages/registration/basic_info_page.dart';
import 'package:agenda/core/utils/app_formatters.dart';
import 'package:agenda/core/constants/app_permissions.dart';
import 'package:agenda/features/home/presentation/viewmodel/home_viewmodel.dart';
import 'package:agenda/features/contacts/domain/models/evaluation_model.dart';
import 'package:agenda/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:agenda/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:agenda/features/favorites/presentation/viewmodel/favorites_viewmodel.dart';

/// Tela de detalhamento de um fornecedor.
///
/// Exibe informações completas do fornecedor, incluindo:
/// - Dados cadastrais e status
/// - Informações de desempenho (Giro, Entrega, etc)
/// - Contatos relacionados (Assistência, Financeiro)
/// - Avaliações e anotações
class SupplierDetailsPage extends StatefulWidget {
  /// O modelo do contato/fornecedor a ser exibido.
  final ContactModel contact;

  /// Construtor da tela.
  const SupplierDetailsPage({super.key, required this.contact});

  @override
  State<SupplierDetailsPage> createState() => _SupplierDetailsPageState();
}

class _SupplierDetailsPageState extends State<SupplierDetailsPage> {
  String? _representativeName;
  ContactModel? _representativeContact;
  bool _isLoadingRepresentative = false;

  bool _isLoadingEvaluations = false;
  List<EvaluationModel> _evaluations = [];
  double _averageRating = 0.0;

  // Estado do favorito para este perfil
  bool _isFavorited = false;

  /// Retorna "Perfil do Fornecedor", "Perfil da Transportadora", etc.
  String get _pageTitle {
    final type = widget.contact.type;
    // Tipos femininos: Transportadora, Distribuidora, Representante (a)
    final isFeminine = type.toLowerCase().endsWith('a') ||
        type.toLowerCase() == 'representante';
    final article = isFeminine ? 'da' : 'do';
    return 'Perfil $article $type';
  }

  @override
  void initState() {
    super.initState();
    _loadRepresentativeName();
    _loadEvaluations();
    _initFavoriteState();
  }

  Future<void> _initFavoriteState() async {
    final vm = getIt<FavoritesViewModel>();
    // Usa o cache local (já populado) para resposta instantânea
    setState(() {
      _isFavorited = vm.isFavorited(widget.contact.id);
    });
  }

  Future<void> _loadEvaluations() async {
    setState(() => _isLoadingEvaluations = true);
    try {
      final repo = getIt<ISupplierRepository>();
      final evals = await repo.getContactEvaluations(widget.contact.id);

      double total = 0;
      int count = 0;
      for (var e in evals) {
        if (e.rating != null) {
          total += e.rating!;
          count++;
        }
      }

      if (mounted) {
        setState(() {
          _evaluations = evals;
          _averageRating = count > 0 ? total / count : 0.0;
          _isLoadingEvaluations = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEvaluations = false);
    }
  }

  Future<void> _loadRepresentativeName() async {
    if (widget.contact.representativeIds.isNotEmpty) {
      setState(() {
        _isLoadingRepresentative = true;
      });

      try {
        final repo = getIt<ISupplierRepository>();
        final contactId = widget.contact.representativeIds.first;
        final representative = await repo.getContactById(contactId);

        if (mounted) {
          setState(() {
            _representativeName = representative?.name;
            _representativeContact = representative;
            _isLoadingRepresentative = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingRepresentative = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: false,
        titleSpacing:
            0, // Remove o espaçamento extra para ficar bem ao lado da seta
        title: Text(
          _pageTitle,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Contato',
            onPressed: () {
              final viewModel = ContactRegistrationViewModel(
                registrationType: widget.contact.type,
                departmentRepository: getIt(),
                supplierRepository: getIt(),
                brandRepository: getIt(),
                productRepository: getIt(),
                contactToEdit: widget.contact,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: const BasicInfoPage(),
                  ),
                ),
              ).then((_) {
                // Optional: Refresh data when returning from edit screen
              });
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Espaço para o fundo azul
          Container(height: 200, color: colors.primary),

          // Card Branco Principal
          Container(
            margin: const EdgeInsets.only(top: 80),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(context),
                  const SizedBox(height: 24),
                  // Seções dinâmicas por tipo de contato
                  if (widget.contact.type.toLowerCase().startsWith(
                        'representante',
                      )) ...[
                    _buildRepresentativeSummarySection(context),
                    const SizedBox(height: 24),
                    _buildRepresentativeAdditionalInfoSection(context),
                    const SizedBox(height: 24),
                    _buildRelatedNumbersSection(context),
                  ] else ...[
                    _buildSummarySection(context),
                    const SizedBox(height: 24),
                    _buildAdditionalInfoSection(context),
                    const SizedBox(height: 24),
                    _buildRelatedNumbersSection(context),
                  ],
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Divider(thickness: 1, color: colors.outlineVariant),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildRatingsSection(context),
                  const SizedBox(height: 24),
                  _buildReviewsList(context),
                  const SizedBox(height: 40), // Espaço extra no fim
                ],
              ),
            ),
          ),

          // Avatar (Sobreposto)
          Positioned(top: 20, child: _buildAvatar()),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: colors.primary,
        backgroundImage: widget.contact.imageUrl != null
            ? NetworkImage(widget.contact.imageUrl!)
            : null,
        child: widget.contact.imageUrl == null
            ? Text(
                widget.contact.name.isNotEmpty
                    ? widget.contact.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimary,
                ),
              )
            : null,
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    bool isCurrentlyActive = widget.contact.status == 'Ativo';
    bool selectedIsActive = isCurrentlyActive;
    final reasonController = TextEditingController(
      text: widget.contact.deactivationReason ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: bottomInset + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status de ${widget.contact.type}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Ativo'),
                        value: true,
                        groupValue: selectedIsActive,
                        onChanged: (value) {
                          if (value != null) {
                            setStateModal(() => selectedIsActive = value);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Inativo'),
                        value: false,
                        groupValue: selectedIsActive,
                        onChanged: (value) {
                          if (value != null) {
                            setStateModal(() => selectedIsActive = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (!selectedIsActive) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Motivo da inativação',
                      hintText:
                          'Explique por que este fornecedor está sendo inativado...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!selectedIsActive &&
                        reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, infome o motivo da inativação.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    widget.contact.status =
                        selectedIsActive ? 'Ativo' : 'Inativo';
                    widget.contact.deactivationReason =
                        selectedIsActive ? null : reasonController.text.trim();

                    Navigator.pop(context);
                    setState(() {});

                    try {
                      final repository = getIt<ISupplierRepository>();
                      await repository.updateContact(widget.contact);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status atualizado!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Erro ao atualizar status: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao salvar status.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment
              .center, // Centraliza verticalmente o texto e a estrela
          children: [
            // Status
            GestureDetector(
              onTap: () => _showStatusDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.contact.status == 'Ativo'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.contact.status == 'Ativo'
                        ? AppColors.success.withValues(alpha: 0.5)
                        : colors.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.contact.status,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.contact.status == 'Ativo'
                            ? AppColors.success
                            : colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: widget.contact.status == 'Ativo'
                          ? AppColors.success
                          : colors.error,
                    ),
                  ],
                ),
              ),
            ),

            // Favorito
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                _isFavorited ? Icons.star : Icons.star_border,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              tooltip: _isFavorited
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () async {
                final vm = getIt<FavoritesViewModel>();
                final nowFav = await vm.toggleFavorite(
                  widget.contact.id,
                  widget.contact,
                );
                if (mounted) setState(() => _isFavorited = nowFav);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            widget.contact.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Razão Social:',
                widget.contact.socialName?.isNotEmpty == true
                    ? widget.contact.socialName!
                    : '-',
              ),
              _buildDetailRow(
                'Código giro:',
                widget.contact.turnoverCode ?? '-',
              ),
              _buildDetailRow(
                'Sobre:',
                widget.contact.about ?? 'Sem descrição.',
                isMultiLine: true,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Tempo de entrega:',
                widget.contact.minDeliveryTime ?? '-',
              ),
              _buildDetailRow(
                'Tempo de faturamento:',
                widget.contact.billingTime ?? '-',
              ),
              _buildDetailRow(
                'Tempo de casa:',
                (widget.contact.tenureValue != null &&
                        widget.contact.tenureUnit != null)
                    ? '${widget.contact.tenureValue} ${widget.contact.tenureUnit}'
                    : '-',
              ),
              _buildBooleanRow('Assistência:', widget.contact.hasAssistance),
              _buildBooleanRow('Tem nota:', widget.contact.hasInvoice),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    // Texto do representante
    String representativeText = 'Nenhum';
    if (_isLoadingRepresentative) {
      representativeText = 'Carregando...';
    } else if (_representativeName != null) {
      representativeText = _representativeName!;
    } else if (widget.contact.representativeIds.isNotEmpty) {
      // Fallback para o ID se falhar
      representativeText = widget.contact.representativeIds.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Adicionais:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Site:', widget.contact.mainSite ?? '-'),
              _buildDetailRow(
                'Site/boletos:',
                widget.contact.boletoSiteLink ?? '-',
              ),
              _buildDetailRow(
                'Endereço:',
                widget.contact.address?.isNotEmpty == true
                    ? widget.contact.address!
                    : '-',
              ),
              _buildDetailRow('Email:', widget.contact.email ?? '-'),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Representante:',
                representativeText,
                isLink: true,
                onTap: _representativeContact != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplierDetailsPage(
                              contact: _representativeContact!,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink
                      ? Colors.lightBlue
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isLink ? FontWeight.bold : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                maxLines: isMultiLine ? 5 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value ? 'Sim' : 'Não',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: value
                    ? AppColors.success
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    try {
      // Remove caracteres não numéricos
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // Validação básica
      if (cleanPhone.length < 10) return;

      // Adiciona código do país se não tiver (assumindo BR +55 se não começar com ele)
      // Logica simples: se tem 10 ou 11 digitos, é BR sem DDI.
      final fullPhone = cleanPhone.length <= 11 ? '55$cleanPhone' : cleanPhone;

      final url = Uri.parse("https://wa.me/$fullPhone");

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Não foi possível abrir o WhatsApp para $fullPhone');
      }
    } catch (e) {
      debugPrint('Erro ao abrir WhatsApp: $e');
    }
  }

  void _showPhonesDialog(
    BuildContext context,
    String title,
    List<String> phones,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Selecione uma opção para entrar em contato',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // List
            ...phones.map((phone) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      _launchWhatsApp(phone);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Phone Icon Helper
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.phone_in_talk_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Phone Number
                          Expanded(
                            child: Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // WhatsApp
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _launchWhatsApp(phone);
                                },
                                icon: const Icon(Icons.chat),
                                color: const Color(
                                  0xFF25D366,
                                ), // WhatsApp Green
                                tooltip: 'WhatsApp',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Copy
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: phone));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copiado!'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                tooltip: 'Copiar',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddNumberDialog(BuildContext context) {
    String selectedType = 'Assistência';
    final phoneController = TextEditingController();
    final outroLabelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: bottomInset + 24, // Para evitar o teclado
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Novo Número',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de contato',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Assistência', 'Financeiro', 'Devolução', 'Outro']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateModal(() => selectedType = value);
                    }
                  },
                ),
                if (selectedType == 'Outro') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: outroLabelController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do tipo (ex: Compras)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Número do Telefone',
                    hintText: '(00) 00000-0000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (phoneController.text.trim().isEmpty) return;

                    final phone = phoneController.text.trim();
                    // Fechar o modal
                    Navigator.pop(context);

                    // Adicionar dependendo do tipo selecionado
                    if (selectedType == 'Assistência') {
                      widget.contact.assistancePhones.add(phone);
                    } else if (selectedType == 'Financeiro') {
                      widget.contact.financeiroPhones.add(phone);
                    } else if (selectedType == 'Devolução') {
                      widget.contact.devolucaoPhones.add(phone);
                    } else if (selectedType == 'Outro') {
                      widget.contact.outroPhones.add(phone);
                      // Atualiza o label somente se informado
                      final label = outroLabelController.text.trim();
                      if (label.isNotEmpty) {
                        widget.contact.outroLabel = label;
                      }
                    }

                    // Atualizar UI
                    setState(() {});

                    // Salvar no Banco
                    try {
                      final repository = getIt<ISupplierRepository>();
                      await repository.updateContact(widget.contact);

                      // Notificação: novo número adicionado
                      final homeVm = getIt<HomeViewModel>();
                      final userName = homeVm.user?.name ?? 'Um usuário';
                      final contactName = widget.contact.name;
                      Future(() async {
                        try {
                          final profileRepo = getIt<IProfileRepository>();
                          final notifRepo = getIt<INotificationRepository>();
                          final userIds =
                              await profileRepo.getUserIdsByPermission(
                            AppPermissions.receiveContactUpdateNotif,
                          );
                          for (final userId in userIds) {
                            await notifRepo.createNotification(
                              userId: userId,
                              title: 'Novo número adicionado',
                              body:
                                  '$userName adicionou um novo número ($selectedType) no perfil de $contactName.',
                            );
                          }
                        } catch (e) {
                          debugPrint(
                            'Erro ao enviar notificação de número: $e',
                          );
                        }
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$selectedType atualizado(a)!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Erro ao atualizar telefone: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao salvar número.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRelatedNumbersSection(BuildContext context) {
    // Filtra itens vazios
    final validAssistancePhones = widget.contact.assistancePhones
        .where((phone) => phone.trim().isNotEmpty)
        .toList();
    final validFinanceiroPhones = widget.contact.financeiroPhones
        .where((phone) => phone.trim().isNotEmpty)
        .toList();
    final validDevolucaoPhones = widget.contact.devolucaoPhones
        .where((phone) => phone.trim().isNotEmpty)
        .toList();
    final validOutroPhones = widget.contact.outroPhones
        .where((phone) => phone.trim().isNotEmpty)
        .toList();

    // Verifica se existem telefones
    final hasAssistancePhones = validAssistancePhones.isNotEmpty;
    final hasFinanceiroPhones = validFinanceiroPhones.isNotEmpty;
    final hasDevolucaoPhones = validDevolucaoPhones.isNotEmpty;
    final hasOutroPhones = validOutroPhones.isNotEmpty;
    final outroCardLabel = (widget.contact.outroLabel?.isNotEmpty == true)
        ? widget.contact.outroLabel!
        : 'Outro';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Números Relacionados',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildNumberCard(
                context,
                icon: Icons.add,
                label: 'Novo',
                isAction: true,
                onTap: () => _showAddNumberDialog(context),
              ),
              if (hasAssistancePhones) ...[
                const SizedBox(width: 12),
                _buildNumberCard(
                  context,
                  icon: Icons.phone_in_talk,
                  label: 'Assistência',
                  color: AppColors.success,
                  phones: validAssistancePhones,
                  onTap: () {
                    if (validAssistancePhones.length > 1) {
                      _showPhonesDialog(
                        context,
                        'Assistência',
                        validAssistancePhones,
                      );
                    } else if (validAssistancePhones.isNotEmpty) {
                      // Se só tem 1, mostra ele também no dialog para copiar
                      _showPhonesDialog(
                        context,
                        'Assistência',
                        validAssistancePhones,
                      );
                    }
                  },
                ),
              ],
              if (hasFinanceiroPhones) ...[
                const SizedBox(width: 12),
                _buildNumberCard(
                  context,
                  icon: Icons.attach_money,
                  label: 'Financeiro',
                  color: AppColors.success,
                  phones: validFinanceiroPhones,
                  onTap: () {
                    if (validFinanceiroPhones.length > 1) {
                      _showPhonesDialog(
                        context,
                        'Financeiro',
                        validFinanceiroPhones,
                      );
                    } else if (validFinanceiroPhones.isNotEmpty) {
                      _showPhonesDialog(
                        context,
                        'Financeiro',
                        validFinanceiroPhones,
                      );
                    }
                  },
                ),
              ],
              if (hasDevolucaoPhones) ...[
                const SizedBox(width: 12),
                _buildNumberCard(
                  context,
                  icon: Icons.assignment_return,
                  label: 'Devolução',
                  color: AppColors.success,
                  phones: validDevolucaoPhones,
                  onTap: () {
                    if (validDevolucaoPhones.length > 1) {
                      _showPhonesDialog(
                        context,
                        'Devolução',
                        validDevolucaoPhones,
                      );
                    } else if (validDevolucaoPhones.isNotEmpty) {
                      _showPhonesDialog(
                        context,
                        'Devolução',
                        validDevolucaoPhones,
                      );
                    }
                  },
                ),
              ],
              if (hasOutroPhones) ...[
                const SizedBox(width: 12),
                _buildNumberCard(
                  context,
                  icon: Icons.phone_forwarded_rounded,
                  label: outroCardLabel,
                  color: AppColors.success,
                  phones: validOutroPhones,
                  onTap: () {
                    _showPhonesDialog(
                      context,
                      outroCardLabel,
                      validOutroPhones,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    bool isAction = false,
    List<String> phones = const [],
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = color ?? colors.onSurfaceVariant;

    // Se for action, usa um estilo diferente
    // Se não, verifica se tem telefones
    final count = phones.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Levemente maior para acomodar melhor
        height: 110,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isAction ? colors.surfaceContainerHighest : colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isAction ? colors.onSurfaceVariant : iconColor,
                size: 28,
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (count > 0) ...[
              const SizedBox(height: 4),
              Text(
                count > 1 ? '$count números' : '$count número',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
              // Indicador visual de "mais" se tiver > 1?
              // O texto "$count números" já indica bem.
            ],
          ],
        ),
      ),
    );
  }

  void _showEvaluationModal(BuildContext context) {
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Toque para classificar:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 48,
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setStateModal(() => selectedRating = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _saveEvaluation(rating: selectedRating);
                        },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCommentModal(BuildContext context) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: bottomInset + 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Faça uma observação:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Digite aqui a observação...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    await _saveEvaluation(
                      comment: commentController.text.trim(),
                    );
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveEvaluation({int? rating, String? comment}) async {
    final homeVm = getIt<HomeViewModel>();
    final user = homeVm.user;
    if (user == null) return;

    try {
      final repo = getIt<ISupplierRepository>();
      final eval = EvaluationModel(
        id: '', // Supabase gera UUID
        contactId: widget.contact.id,
        userId: user.id,
        userName: user.name,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await repo.addEvaluation(eval);

      // Notificação: nova anotação adicionada (apenas para comentários, não avaliações de estrela)
      if (comment != null && comment.isNotEmpty) {
        final contactName = widget.contact.name;
        Future(() async {
          try {
            final profileRepo = getIt<IProfileRepository>();
            final notifRepo = getIt<INotificationRepository>();
            final userIds = await profileRepo.getUserIdsByPermission(
              AppPermissions.receiveContactAnnotationNotif,
            );
            for (final userId in userIds) {
              await notifRepo.createNotification(
                userId: userId,
                title: 'Nova anotação adicionada',
                body:
                    '${user.name} adicionou uma nova anotação no perfil de $contactName.',
              );
            }
          } catch (e) {
            debugPrint('Erro ao enviar notificação de anotação: $e');
          }
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadEvaluations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRatingsSection(BuildContext context) {
    if (_isLoadingEvaluations) {
      return const Center(child: CircularProgressIndicator());
    }

    final rating = _averageRating;
    final count = _evaluations.where((e) => e.rating != null).length;

    final homeVm = getIt<HomeViewModel>();
    final canEvaluate =
        homeVm.user?.hasPermission(AppPermissions.evaluateSupplier) ?? false;
    final canComment =
        homeVm.user?.hasPermission(AppPermissions.commentSupplier) ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classificações e Avaliações',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    if (index < rating.floor()) {
                      return const Icon(
                        Icons.star,
                        color: Colors.blue,
                        size: 20,
                      );
                    } else if (index < rating && index + 0.5 <= rating) {
                      return const Icon(
                        Icons.star_half,
                        color: Colors.blue,
                        size: 20,
                      );
                    } else {
                      return const Icon(
                        Icons.star_border,
                        color: Colors.blue,
                        size: 20,
                      );
                    }
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count classificações',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (canEvaluate || canComment)
          Row(
            children: [
              if (canEvaluate)
                Expanded(
                  child: AppButton(
                    label: 'Avalie',
                    onPressed: () => _showEvaluationModal(context),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              if (canEvaluate && canComment) const SizedBox(width: 16),
              if (canComment)
                Expanded(
                  child: AppButton(
                    label: 'Anotação',
                    onPressed: () => _showCommentModal(context),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    if (_isLoadingEvaluations) {
      return const SizedBox.shrink(); // Loader já está sendo mostrado
    }

    final reviews = _evaluations
        .where((e) => e.comment != null && e.comment!.trim().isNotEmpty)
        .toList();

    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: reviews.map((review) {
        // Formatar data simpificada
        final now = DateTime.now();
        final diff = now.difference(review.createdAt);
        String timeAgo = '';
        if (diff.inDays > 365) {
          timeAgo = 'Há ${diff.inDays ~/ 365} ano(s)';
        } else if (diff.inDays > 30) {
          timeAgo = 'Há ${diff.inDays ~/ 30} mês(es)';
        } else if (diff.inDays > 0) {
          timeAgo = 'Há ${diff.inDays} dia(s)';
        } else if (diff.inHours > 0) {
          timeAgo = 'Há ${diff.inHours} hora(s)';
        } else {
          timeAgo = 'Agora mesmo';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Seções exclusivas do perfil de Representante
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildRepresentativeSummarySection(BuildContext context) {
    final contact = widget.contact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Pessoais:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Código giro:', contact.turnoverCode ?? '-'),
              _buildDetailRow('Email:', contact.email ?? '-'),
              _buildDetailRow(
                'Região de atuação:',
                contact.regionOfActivity ?? '-',
              ),
              _buildDetailRow(
                'Tempo de casa:',
                contact.tenureValue != null
                    ? '${contact.tenureValue}${contact.tenureUnit != null ? ' ${contact.tenureUnit}' : ''}'
                    : '-',
              ),
              _buildDetailRow(
                'Sobre:',
                contact.about ?? 'Sem descrição.',
                isMultiLine: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepresentativeAdditionalInfoSection(BuildContext context) {
    final contact = widget.contact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Adicionais:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Aniversário:', contact.birthday ?? '-'),
              _buildDetailRow(
                'Personalidade:',
                contact.personality ?? '-',
                isMultiLine: true,
              ),
              _buildBooleanRow('Casado(a):', contact.isMarried ?? false),
              if (contact.isMarried == true)
                _buildDetailRow('Cônjuge:', contact.spouseName ?? '-'),
              _buildBooleanRow('Tem filhos:', contact.hasChildren ?? false),
              if (contact.hasChildren == true)
                _buildDetailRow(
                  'Filho(s):',
                  contact.childrenNames ?? '-',
                  isMultiLine: true,
                ),
              _buildBooleanRow('Emite nota fiscal:', contact.hasInvoice),
              _buildDetailRow('Site:', contact.mainSite ?? '-'),
              _buildDetailRow('Site/boletos:', contact.boletoSiteLink ?? '-'),
            ],
          ),
        ),
      ],
    );
  }
}
