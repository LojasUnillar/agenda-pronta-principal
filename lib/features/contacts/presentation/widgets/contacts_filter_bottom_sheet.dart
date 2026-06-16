import 'package:flutter/material.dart';
import '../viewmodel/contacts_list_viewmodel.dart';

/// BottomSheet modal para filtros avançados da lista de contatos.
///
/// Permite filtrar por:
/// - Ordenação (A-Z, Z-A, Recentes, Frequência)
/// - Status (Ativo/Inativo)
/// - Marca e Produto (Dropdowns dinâmicos)
/// - Tipo de Contato (Multi-select)
/// - Filtros booleanos (Email, CNPJ)
///
/// Os filtros são aplicados temporariamente no estado local e efetivados
/// apenas ao clicar em "Aplicar Filtros".
class ContactsFilterBottomSheet extends StatefulWidget {
  /// ViewModel da lista para ler opções e status atual
  final ContactsListViewModel viewModel;

  const ContactsFilterBottomSheet({super.key, required this.viewModel});

  @override
  State<ContactsFilterBottomSheet> createState() =>
      _ContactsFilterBottomSheetState();
}

class _ContactsFilterBottomSheetState extends State<ContactsFilterBottomSheet> {
  late ContactSortOption _tempSortOption;
  late ContactStatusFilter _tempStatusFilter;
  late bool _tempByEmail;
  late bool _tempByCnpj;
  late Set<String> _tempSelectedTypes;
  late String? _tempSelectedBrand;
  late String? _tempSelectedProduct;

  @override
  void initState() {
    super.initState();
    // Inicializa o estado local com os valores atuais do ViewModel
    _tempSortOption = widget.viewModel.sortOption;
    _tempStatusFilter = widget.viewModel.statusFilter;
    _tempByEmail = widget.viewModel.filterByEmail;
    _tempByCnpj = widget.viewModel.filterByCnpj;
    _tempSelectedTypes = widget.viewModel.selectedTypes.toSet();
    _tempSelectedBrand = widget.viewModel.selectedBrand;
    _tempSelectedProduct = widget.viewModel.selectedProduct;
  }

  /// Aplica os filtros selecionados no ViewModel e fecha o modal.
  void _applyFilters() {
    widget.viewModel.setSortOption(_tempSortOption);
    widget.viewModel.setStatusFilter(_tempStatusFilter);
    widget.viewModel.setAdvancedFilters(
      byEmail: _tempByEmail,
      byCnpj: _tempByCnpj,
    );
    widget.viewModel.setTypeFilters(_tempSelectedTypes);
    widget.viewModel.setBrandFilter(_tempSelectedBrand);
    widget.viewModel.setProductFilter(_tempSelectedProduct);
    Navigator.of(context).pop();
  }

  /// Limpa todos os filtros locais e efetiva a limpeza.
  void _clearFilters() {
    setState(() {
      _tempSortOption = ContactSortOption.alphabetical;
      _tempStatusFilter = ContactStatusFilter.all;
      _tempByEmail = false;
      _tempByCnpj = false;
      _tempSelectedTypes = {};
      _tempSelectedBrand = null;
      _tempSelectedProduct = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  "Filtros",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _clearFilters,
                  child: const Text("Limpar"),
                ),
              ),
            ],
          ),
          const Divider(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Ordenação
                  _buildSectionTitle("Ordenar por", colors),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip(
                        "A-Z",
                        ContactSortOption.alphabetical,
                        colors,
                      ),
                      _buildSortChip(
                        "Z-A",
                        ContactSortOption.alphabeticalReverse,
                        colors,
                      ),
                      _buildSortChip("Novos", ContactSortOption.recent, colors),
                      _buildSortChip(
                        "Antigos",
                        ContactSortOption.oldest,
                        colors,
                      ),
                      _buildSortChip(
                        "Mais frequente",
                        ContactSortOption.mostFrequent,
                        colors,
                      ),
                      _buildSortChip(
                        "Menos frequente",
                        ContactSortOption.leastFrequent,
                        colors,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. Status
                  _buildSectionTitle("Status", colors),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip(
                        "Ativos",
                        ContactStatusFilter.active,
                        colors,
                      ),
                      _buildStatusChip(
                        "Inativos",
                        ContactStatusFilter.inactive,
                        colors,
                      ),
                      _buildStatusChip(
                        "Todos",
                        ContactStatusFilter.all,
                        colors,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2.1 Marca e Produto (Dropdowns restaurados)
                  _buildSectionTitle("Marca e Produto", colors),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Marca",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _tempSelectedBrand,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas as Marcas'),
                            ),
                            ...widget.viewModel.brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand.id,
                                child: Text(brand.name),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _tempSelectedBrand = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Produto",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _tempSelectedProduct,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todos os Produtos'),
                            ),
                            ...widget.viewModel.products.map((prod) {
                              return DropdownMenuItem(
                                value: prod.id,
                                child: Text(prod.name),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _tempSelectedProduct = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2.2 Tipo de Contato
                  _buildSectionTitle("Tipo de Contato", colors),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip("Fornecedor"),
                      _buildTypeChip("Distribuidora"),
                      _buildTypeChip("Transportadora"),
                      _buildTypeChip("Representante"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. Detalhes (Checkbox)
                  _buildSectionTitle("Exibir Apenas", colors),
                  SwitchListTile(
                    title: Text(
                      "Com E-mail cadastrado",
                      style: TextStyle(color: colors.onSurface),
                    ),
                    value: _tempByEmail,
                    onChanged: (val) => setState(() => _tempByEmail = val),
                    activeColor: colors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text(
                      "Com CNPJ cadastrado",
                      style: TextStyle(color: colors.onSurface),
                    ),
                    value: _tempByCnpj,
                    onChanged: (val) => setState(() => _tempByCnpj = val),
                    activeColor: colors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Botão Aplicar (Fixo no fundo)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text(
                "Aplicar Filtros",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSortChip(
    String label,
    ContactSortOption value,
    ColorScheme colors,
  ) {
    final isSelected = _tempSortOption == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tempSortOption = value;
        });
      },
      showCheckmark: false,
      selectedColor: colors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: const StadiumBorder(),
      side: isSelected ? BorderSide(color: colors.primary) : null,
    );
  }

  Widget _buildStatusChip(
    String label,
    ContactStatusFilter value,
    ColorScheme colors,
  ) {
    final isSelected = _tempStatusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tempStatusFilter = value;
        });
      },
      showCheckmark: false,
      selectedColor: colors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: const StadiumBorder(),
      side: isSelected ? BorderSide(color: colors.primary) : null,
    );
  }

  Widget _buildTypeChip(String type) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _tempSelectedTypes.contains(type);
    return FilterChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isSelected) {
            _tempSelectedTypes.remove(type);
          } else {
            _tempSelectedTypes.add(type);
          }
        });
      },
      showCheckmark: false,
      selectedColor: colors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: const StadiumBorder(),
      side: isSelected ? BorderSide(color: colors.primary) : null,
    );
  }
}
