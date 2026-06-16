import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/app_formatters.dart';
import '../../../../../core/utils/app_validators.dart';
import '../../viewmodel/contact_registration_viewmodel.dart';
import 'additional_info_page.dart';

/// Página de informações básicas do cadastro de contato.
///
/// Primeira etapa do fluxo de cadastro, coleta dados essenciais:
/// - Nome/Razão social
/// - CNPJ/CPF com validação
/// - Departamentos (seleção múltipla)
/// - Marcas e Produtos
/// - Vínculos (representantes ou empresas)
///
/// Valida os dados e navega para [AdditionalInfoPage]
class BasicInfoPage extends StatelessWidget {
  /// Cria uma nova instância da página de informações básicas
  const BasicInfoPage({super.key});

  /// Constrói a interface da página
  ///
  /// Renderiza formulário com campos essenciais e botão para navegar
  /// para a próxima etapa do cadastro.
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
          viewModel.isEditing
              ? "Editar ${viewModel.registrationType}"
              : "Cadastro de ${viewModel.registrationType}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
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
                color: colors.surfaceContainer,
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
                child: Form(
                  key: viewModel.basicInfoFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (viewModel.isLoadingDependencies)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: LinearProgressIndicator(),
                        ),
                      if (viewModel.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20),
                                onPressed: viewModel.loadDependencies,
                              ),
                            ],
                          ),
                        ),

                      // Cabeçalho de Seção
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          "Informações Básicas",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      // Nome
                      TextFormField(
                        controller: viewModel.nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nome é obrigatório.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: viewModel.registrationType.contains(
                            'Representante',
                          )
                              ? "Nome do Representante"
                              : "Nome Fantasia",
                          hintText: "Digite o nome...",
                          prefixIcon: Icon(
                            viewModel.registrationType.contains('Representante')
                                ? Icons.person_outline
                                : Icons.business_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: viewModel.socialNameController,
                        decoration: InputDecoration(
                          labelText: viewModel.registrationType.contains(
                            'Representante',
                          )
                              ? "Apelido"
                              : "Razão Social",
                          hintText: viewModel.registrationType.contains(
                            'Representante',
                          )
                              ? "Digite o apelido"
                              : "Digite a razão social",
                          prefixIcon: Icon(
                            viewModel.registrationType.contains('Representante')
                                ? Icons.badge_outlined
                                : Icons.domain_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CNPJ
                      // CNPJ / CPF
                      TextFormField(
                        controller: viewModel.cnpjController,
                        onChanged: viewModel.onCnpjChanged,
                        validator: (value) {
                          final isRepresentative = viewModel.registrationType
                              .contains('Representante');

                          if (isRepresentative &&
                              (value == null || value.isEmpty)) {
                            return null;
                          }

                          if (!isRepresentative &&
                              (value == null || value.isEmpty)) {
                            return 'CNPJ é obrigatório.';
                          }

                          if (value != null && value.isNotEmpty) {
                            final cleanValue = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (cleanValue.length == 11) {
                              if (!AppValidators.isValidCPF(value)) {
                                return 'CPF inválido.';
                              }
                            } else if (cleanValue.length == 14) {
                              if (!AppValidators.isValidCNPJ(value)) {
                                return 'CNPJ inválido.';
                              }
                            } else {
                              return 'Documento inválido (11 ou 14 dígitos).';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: viewModel.registrationType.contains(
                            'Representante',
                          )
                              ? "CPF (Opcional)"
                              : "CNPJ",
                          hintText: viewModel.registrationType.contains(
                            'Representante',
                          )
                              ? "000.000.000-00"
                              : "00.000.000/0000-00",
                          errorText: viewModel.cnpjError,
                          prefixIcon: const Icon(Icons.assignment_ind_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          viewModel.registrationType.contains('Representante')
                              ? CpfInputFormatter()
                              : CnpjInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: viewModel.addressController,
                        decoration: InputDecoration(
                          labelText: "Endereço Completo",
                          hintText: "Rua, Número, Bairro, Cidade - UF",
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      MenuAnchor(
                        builder: (context, controller, child) {
                          final selectedNames = viewModel.departments
                              .where(
                                (d) => viewModel.selectedDepartmentIds.contains(
                                  d.id,
                                ),
                              )
                              .map((d) => d.name.toUpperCase())
                              .join(', ');

                          return TextFormField(
                            readOnly: true,
                            onTap: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                            decoration: InputDecoration(
                              labelText: "Departamentos",
                              hintText: "Selecione os departamentos",
                              prefixIcon: Icon(Icons.category_outlined),
                              suffixIcon: Icon(
                                controller.isOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (viewModel.selectedDepartmentIds.isEmpty) {
                                return 'Selecione pelo menos um departamento.';
                              }
                              return null;
                            },
                            controller: TextEditingController(
                              text: selectedNames,
                            ),
                          );
                        },
                        menuChildren: viewModel.departments.map((dep) {
                          final isSelected =
                              viewModel.selectedDepartmentIds.contains(dep.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(dep.name.toUpperCase()),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (_) =>
                                viewModel.toggleDepartment(dep.id),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      MenuAnchor(
                        builder: (context, controller, child) {
                          final isRepresentative = viewModel.registrationType
                              .contains('Representante');
                          final availableItems = isRepresentative
                              ? viewModel.suppliersAndDistributors
                              : viewModel.representatives;
                          final label = isRepresentative
                              ? "Empresas Representadas"
                              : "Representantes";
                          final hint = isRepresentative
                              ? "Selecione as empresas"
                              : "Selecione os representantes";
                          final icon = isRepresentative
                              ? Icons.business_outlined
                              : Icons.person_outline;

                          final selectedNames = availableItems
                              .where(
                                (item) => viewModel.selectedRepresentativeIds
                                    .contains(item.id),
                              )
                              .map((item) => item.name)
                              .join(', ');

                          return TextFormField(
                            readOnly: true,
                            onTap: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                            decoration: InputDecoration(
                              labelText: label,
                              hintText: hint,
                              prefixIcon: Icon(icon),
                              suffixIcon: Icon(
                                controller.isOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            controller: TextEditingController(
                              text: selectedNames,
                            ),
                          );
                        },
                        menuChildren: (viewModel.registrationType.contains(
                          'Representante',
                        )
                                ? viewModel.suppliersAndDistributors
                                : viewModel.representatives)
                            .map((item) {
                          final isSelected = viewModel.selectedRepresentativeIds
                              .contains(item.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(item.name),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (_) =>
                                viewModel.toggleRepresentative(item.id),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Marcas
                      MenuAnchor(
                        builder: (context, controller, child) {
                          final selectedNames = viewModel.availableBrands
                              .where(
                                (b) =>
                                    viewModel.selectedBrandIds.contains(b.id),
                              )
                              .map((b) => b.name)
                              .join(', ');

                          return TextFormField(
                            readOnly: true,
                            onTap: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                            decoration: InputDecoration(
                              labelText: "Marcas",
                              hintText: "Selecione as marcas",
                              prefixIcon: const Icon(
                                Icons.branding_watermark_outlined,
                              ),
                              suffixIcon: Icon(
                                controller.isOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            controller: TextEditingController(
                              text: selectedNames,
                            ),
                          );
                        },
                        menuChildren: viewModel.availableBrands.map((brand) {
                          final isSelected =
                              viewModel.selectedBrandIds.contains(brand.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(brand.name),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (_) => viewModel.toggleBrand(brand.id),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Produtos
                      MenuAnchor(
                        builder: (context, controller, child) {
                          final selectedNames = viewModel.availableProducts
                              .where(
                                (p) =>
                                    viewModel.selectedProductIds.contains(p.id),
                              )
                              .map((p) => p.name)
                              .join(', ');

                          return TextFormField(
                            readOnly: true,
                            onTap: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                            decoration: InputDecoration(
                              labelText: "Produtos",
                              hintText: "Selecione os produtos",
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              suffixIcon: Icon(
                                controller.isOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            controller: TextEditingController(
                              text: selectedNames,
                            ),
                          );
                        },
                        menuChildren: viewModel.availableProducts.map((
                          product,
                        ) {
                          final isSelected =
                              viewModel.selectedProductIds.contains(product.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(product.name),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (_) =>
                                viewModel.toggleProduct(product.id),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // Botão Próximo
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            viewModel.submitBasicInfo(context);
                            if (viewModel.currentStep == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                    value: viewModel,
                                    child: AdditionalInfoPage(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: viewModel.isLoading
                              ? CircularProgressIndicator(
                                  color: colors.onPrimary,
                                )
                              : Text(
                                  viewModel.registrationType
                                          .toLowerCase()
                                          .contains('fornecedor')
                                      ? "Concluir"
                                      : "Próximo",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
