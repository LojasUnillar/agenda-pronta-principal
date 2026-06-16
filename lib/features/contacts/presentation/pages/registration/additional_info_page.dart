import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/app_formatters.dart';
import '../../viewmodel/contact_registration_viewmodel.dart';

/// Página de informações adicionais do cadastro de contato.
///
/// Exibe campos específicos baseados no tipo de contato:
/// - Representantes: informações pessoais, família, aniversário
/// - Fornecedores: tempo de entrega, faturamento, assistência técnica
///
/// Funcionalidades:
/// - Formulário dinâmico por tipo de contato
/// - Seleção de chips para tempo de entrega/faturamento
/// - Gerenciamento de múltiplos telefones
/// - Validação e submissão final do cadastro
class AdditionalInfoPage extends StatefulWidget {
  /// Cria uma nova instância da página de informações adicionais
  const AdditionalInfoPage({super.key});

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

/// Estado interno da página de informações adicionais
///
/// Gerencia a renderização do formulário dinâmico baseado no tipo de contato
/// selecionado no ViewModel.
class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ContactRegistrationViewModel>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          viewModel.registrationType.contains('Representante')
              ? "Cadastro de Representante"
              : "Cadastro de Fornecedor",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: colors.primary,
        forceMaterialTransparency: true,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (viewModel.registrationType.contains('Representante'))
                      ..._buildRepresentativeFields(context, viewModel, colors)
                    else
                      ..._buildSupplierFields(context, viewModel, colors),
                    const SizedBox(height: 40),

                    // Botão Confirmar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.submitFullRegistration(context),
                        child: viewModel.isLoading
                            ? CircularProgressIndicator(color: colors.onPrimary)
                            : const Text(
                                "Confirmar",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected
                ? Theme.of(context)
                      .colorScheme
                      .primary // Usar cor primária para seleção
                : Theme.of(context).colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSquareButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLabel(String text, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildRepresentativeFields(
    BuildContext context,
    ContactRegistrationViewModel viewModel,
    ColorScheme colors,
  ) {
    return [
      _buildSectionHeader("Informações Pessoais", colors),
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.turnoverCodeController,
        decoration: InputDecoration(
          labelText: "Código giro",
          prefixIcon: const Icon(Icons.pin_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 16),
      // Campo de Empresas Representadas
      MenuAnchor(
        builder: (context, controller, child) {
          final items = viewModel.suppliersAndDistributors;
          final hasItems = items.isNotEmpty;

          final selectedNames = items
              .where(
                (item) => viewModel.selectedRepresentativeIds.contains(item.id),
              )
              .map((item) => item.name)
              .join(', ');

          return TextFormField(
            readOnly: true,
            enabled: hasItems,
            onTap: () {
              if (hasItems) {
                controller.isOpen ? controller.close() : controller.open();
              }
            },
            decoration: InputDecoration(
              labelText: "Empresas Representadas",
              hintText: hasItems
                  ? "Selecione as empresas"
                  : "Nenhuma empresa disponível",
              prefixIcon: const Icon(Icons.business_outlined),
              suffixIcon: hasItems
                  ? Icon(
                      controller.isOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    )
                  : const Icon(Icons.block, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            controller: TextEditingController(text: selectedNames),
          );
        },
        menuChildren: viewModel.suppliersAndDistributors.map((item) {
          final isSelected = viewModel.selectedRepresentativeIds.contains(
            item.id,
          );
          return CheckboxListTile(
            value: isSelected,
            title: Text(item.name),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (_) => viewModel.toggleRepresentative(item.id),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.regionController,
        decoration: InputDecoration(
          labelText: "Região de atuação",
          prefixIcon: const Icon(Icons.map_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.emailController,
        decoration: InputDecoration(
          labelText: "Email oficial",
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader("Informações Adicionais", colors),
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.birthdayController,
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            viewModel.birthdayController.text =
                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          }
        },
        decoration: InputDecoration(
          labelText: "Data de aniversário",
          hintText: "DD/MM/AAAA",
          prefixIcon: const Icon(Icons.cake_outlined),
          suffixIcon: const Icon(Icons.calendar_month_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.personalityController,
        decoration: InputDecoration(
          labelText: "Personalidade",
          prefixIcon: const Icon(Icons.psychology_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 16),
      _buildLabel("Tempo de casa"),
      _buildTenureField(viewModel, colors),
      const SizedBox(height: 24),
      _buildSectionHeader("Família", colors),
      const SizedBox(height: 16),
      _buildLabel("Casado"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.isMarried,
            () => viewModel.toggleMarried(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.isMarried,
            () => viewModel.toggleMarried(false),
          ),
        ],
      ),
      if (viewModel.isMarried) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: viewModel.spouseNameController,
          decoration: InputDecoration(
            labelText: "Nome do(a) Cônjugue",
            prefixIcon: const Icon(Icons.favorite_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
      const SizedBox(height: 16),
      _buildLabel("Filhos"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasChildrenGroup,
            () => viewModel.toggleChildren(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasChildrenGroup,
            () => viewModel.toggleChildren(false),
          ),
        ],
      ),
      if (viewModel.hasChildrenGroup) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: viewModel.childrenNamesController,
          decoration: InputDecoration(
            labelText: "Nome do(s) filho(s)",
            prefixIcon: const Icon(Icons.child_care_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
      const SizedBox(height: 24),
      _buildSectionHeader("Financeiro e Site", colors),
      const SizedBox(height: 16),
      _buildLabel("Contatos Financeiros"),
      _buildPhoneList(
        phones: viewModel.financeiroPhones,
        onAdd: viewModel.addFinanceiroPhone,
        onRemove: viewModel.removeFinanceiroPhone,
        onChanged: viewModel.updateFinanceiroPhone,
      ),
      const SizedBox(height: 24),
      _buildLabel("Emite Nota Fiscal"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasInvoice,
            () => viewModel.toggleInvoice(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasInvoice,
            () => viewModel.toggleInvoice(false),
          ),
        ],
      ),
      const SizedBox(height: 24),
      TextFormField(
        controller: viewModel.mainSiteController,
        decoration: InputDecoration(
          labelText: "Site Principal",
          prefixIcon: const Icon(Icons.language_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 24),
      _buildLabel("Site de boletos"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasBoletoSite,
            () => viewModel.toggleBoletoSite(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasBoletoSite,
            () => viewModel.toggleBoletoSite(false),
          ),
        ],
      ),
      if (viewModel.hasBoletoSite) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: viewModel.boletoSiteController,
          decoration: InputDecoration(
            labelText: "Link do Site de Boletos",
            hintText: "https://...",
            prefixIcon: const Icon(Icons.link_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    ];
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTenureField(
    ContactRegistrationViewModel viewModel,
    ColorScheme colors,
  ) {
    final units = ['Anos', 'Meses', 'Dias'];
    final currentUnit = units.contains(viewModel.tenureUnitController.text)
        ? viewModel.tenureUnitController.text
        : 'Anos';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Campo numérico com botões +/-
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  final v =
                      int.tryParse(viewModel.tenureValueController.text) ?? 1;
                  if (v > 1) {
                    viewModel.tenureValueController.text = '${v - 1}';
                  }
                },
                icon: Icon(Icons.remove, color: colors.primary, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: viewModel.tenureValueController,
                builder: (context, value, _) {
                  return Text(
                    value.text.isEmpty ? '1' : value.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  final v =
                      int.tryParse(viewModel.tenureValueController.text) ?? 1;
                  viewModel.tenureValueController.text = '${v + 1}';
                },
                icon: Icon(Icons.add, color: colors.primary, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Dropdown Anos / Meses / Dias
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentUnit,
            icon: const Icon(Icons.keyboard_arrow_down),
            borderRadius: BorderRadius.circular(16),
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            items: units.map((unit) {
              final isSelected = unit == currentUnit;
              return DropdownMenuItem(
                value: unit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        )
                      : null,
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) viewModel.updateTenureUnit(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneList({
    required List<String> phones,
    required void Function(int, String) onChanged,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(phones.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('${phones.hashCode}_$index'),
                  initialValue: phones[index],
                  decoration: InputDecoration(
                    hintText: "(00) 00000-0000",
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  onChanged: (val) => onChanged(index, val),
                ),
              ),
              const SizedBox(width: 8),
              if (index == 0)
                _buildSquareButton(Icons.add, colors.secondary, onAdd)
              else
                _buildSquareButton(
                  Icons.remove,
                  colors.error,
                  () => onRemove(index),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildSupplierFields(
    BuildContext context,
    ContactRegistrationViewModel viewModel,
    ColorScheme colors,
  ) {
    return [
      TextFormField(
        controller: viewModel.turnoverCodeController,
        decoration: InputDecoration(
          labelText: "Código ERP",
          prefixIcon: const Icon(Icons.confirmation_number_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 24),
      _buildLabel("Tempo Mínimo de Entrega"),
      _ChipSelection(
        options: const ["15 dias", "30 dias", "60 dias", "90 dias"],
        controller: viewModel.minDeliveryTimeController,
        hasCustomOption: true,
      ),
      const SizedBox(height: 24),
      _buildLabel("Tempo de Faturamento"),
      _ChipSelection(
        options: const ["15 dias", "30 dias", "60 dias", "90 dias"],
        controller: viewModel.billingTimeController,
        hasCustomOption: true,
      ),
      const SizedBox(height: 24),
      _buildLabel("Tempo de Casa"),
      _buildTenureField(viewModel, colors),
      const SizedBox(height: 24),
      _buildLabel("Possui assistência técnica?"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasAssistance,
            () => viewModel.toggleAssistance(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasAssistance,
            () => viewModel.toggleAssistance(false),
          ),
        ],
      ),
      if (viewModel.hasAssistance) ...[
        const SizedBox(height: 16),
        _buildPhoneList(
          phones: viewModel.assistancePhones,
          onAdd: viewModel.addAssistancePhone,
          onRemove: viewModel.removeAssistancePhone,
          onChanged: viewModel.updateAssistancePhone,
        ),
      ],
      const SizedBox(height: 24),
      _buildLabel("Possui Devolução?"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasDevolucao,
            () => viewModel.toggleDevolucao(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasDevolucao,
            () => viewModel.toggleDevolucao(false),
          ),
        ],
      ),
      if (viewModel.hasDevolucao) ...[
        const SizedBox(height: 16),
        _buildPhoneList(
          phones: viewModel.devolucaoPhones,
          onAdd: viewModel.addDevolucaoPhone,
          onRemove: viewModel.removeDevolucaoPhone,
          onChanged: viewModel.updateDevolucaoPhone,
        ),
      ],
      const SizedBox(height: 24),
      _buildLabel("Financeiro"),
      _buildPhoneList(
        phones: viewModel.financeiroPhones,
        onAdd: viewModel.addFinanceiroPhone,
        onRemove: viewModel.removeFinanceiroPhone,
        onChanged: viewModel.updateFinanceiroPhone,
      ),
      const SizedBox(height: 24),
      _buildLabel("Emite Nota Fiscal?"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasInvoice,
            () => viewModel.toggleInvoice(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasInvoice,
            () => viewModel.toggleInvoice(false),
          ),
        ],
      ),
      const SizedBox(height: 24),
      TextFormField(
        controller: viewModel.mainSiteController,
        decoration: InputDecoration(
          labelText: "Site Principal",
          prefixIcon: const Icon(Icons.language_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 24),
      _buildLabel("Site de boletos"),
      Row(
        children: [
          _buildRadioOption(
            "Sim",
            viewModel.hasBoletoSite,
            () => viewModel.toggleBoletoSite(true),
          ),
          const SizedBox(width: 24),
          _buildRadioOption(
            "Não",
            !viewModel.hasBoletoSite,
            () => viewModel.toggleBoletoSite(false),
          ),
        ],
      ),
      if (viewModel.hasBoletoSite) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: viewModel.boletoSiteController,
          decoration: InputDecoration(
            labelText: "Link do Site de Boletos",
            hintText: "https://...",
            prefixIcon: const Icon(Icons.link_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
      const SizedBox(height: 16),
      TextFormField(
        controller: viewModel.emailController,
        decoration: InputDecoration(
          labelText: "Email",
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ];
  }
}

class _ChipSelection extends StatefulWidget {
  final List<String> options;
  final TextEditingController controller;
  final bool hasCustomOption;

  const _ChipSelection({
    required this.options,
    required this.controller,
    this.hasCustomOption = false,
  });

  @override
  State<_ChipSelection> createState() => _ChipSelectionState();
}

class _ChipSelectionState extends State<_ChipSelection> {
  // Lógica para mostrar entrada personalizada se 'Outro' for selecionado
  bool isCustom = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.options.map((option) {
                final isSelected = widget.controller.text == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        isCustom = false;
                        widget.controller.text = selected ? option : "";
                      });
                    },
                    selectedColor: colors.primary,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                  ),
                );
              }),
              if (widget.hasCustomOption)
                ChoiceChip(
                  label: const Text('+ Outro'),
                  selected: isCustom,
                  onSelected: (selected) {
                    setState(() {
                      isCustom = selected;
                      // Sempre limpa o controller ao entrar/sair do modo customizado
                      widget.controller.text = '';
                    });
                  },
                  selectedColor: colors.primary,
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isCustom ? Colors.white : Colors.black,
                    fontWeight: isCustom ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  showCheckmark: false,
                ),
            ],
          ),
        ),
        if (isCustom)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _CounterInput(controller: widget.controller),
          ),
      ],
    );
  }
}

class _CounterInput extends StatefulWidget {
  final TextEditingController controller;
  const _CounterInput({required this.controller});

  @override
  State<_CounterInput> createState() => _CounterInputState();
}

class _CounterInputState extends State<_CounterInput> {
  int _value = 1;

  void _increment() {
    setState(() {
      _value++;
      widget.controller.text = '$_value ${_value == 1 ? 'dia' : 'dias'}';
    });
  }

  void _decrement() {
    if (_value > 1) {
      setState(() {
        _value--;
        widget.controller.text = '$_value ${_value == 1 ? 'dia' : 'dias'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _decrement,
            icon: Icon(Icons.remove, color: colors.primary),
          ),
          Text(
            '$_value ${_value == 1 ? 'dia' : 'dias'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            onPressed: _increment,
            icon: Icon(Icons.add, color: colors.primary),
          ),
        ],
      ),
    );
  }
}
