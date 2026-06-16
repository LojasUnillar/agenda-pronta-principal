import 'package:flutter/material.dart';
import '../../domain/models/user_status_filter.dart';
import '../viewmodel/search_profile_viewmodel.dart';

class UsersFilterBottomSheet extends StatefulWidget {
  final SearchProfileViewModel viewModel;

  const UsersFilterBottomSheet({super.key, required this.viewModel});

  @override
  State<UsersFilterBottomSheet> createState() => _UsersFilterBottomSheetState();
}

class _UsersFilterBottomSheetState extends State<UsersFilterBottomSheet> {
  late ProfileSortOption _tempSortOption;
  late UserStatusFilter _tempStatusFilter;
  String? _tempRoleId;

  @override
  void initState() {
    super.initState();
    _tempSortOption = widget.viewModel.sortOption;
    _tempStatusFilter = widget.viewModel.statusFilter;
    _tempStatusFilter = widget.viewModel.statusFilter;
    _tempRoleId = widget.viewModel.filterByRoleId;
  }

  void _applyFilters() {
    widget.viewModel.setSortOption(_tempSortOption);
    widget.viewModel.setStatusFilter(_tempStatusFilter);
    widget.viewModel.setStatusFilter(_tempStatusFilter);
    widget.viewModel.setAdvancedFilters(roleId: _tempRoleId);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _tempSortOption = ProfileSortOption.alphabetical;
      _tempStatusFilter = UserStatusFilter.active;
      _tempStatusFilter = UserStatusFilter.active;
      _tempRoleId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "Filtros de Usuários",
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

              // 1. Ordenação
              _buildSectionTitle("Ordenar por", colors),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSortChip(
                      "A-Z",
                      ProfileSortOption.alphabetical,
                      colors,
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip(
                      "Z-A",
                      ProfileSortOption.alphabeticalReverse,
                      colors,
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip("Novos", ProfileSortOption.recent, colors),
                    const SizedBox(width: 8),
                    _buildSortChip("Antigos", ProfileSortOption.oldest, colors),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Status
              _buildSectionTitle("Status", colors),
              Row(
                children: [
                  _buildStatusChip("Ativos", UserStatusFilter.active, colors),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    "Inativos",
                    UserStatusFilter.inactive,
                    colors,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip("Todos", UserStatusFilter.all, colors),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Função (Dropdown)
              _buildSectionTitle("Tipo de Usuário", colors),
              if (widget.viewModel.isLoadingRoles)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (widget.viewModel.roles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Nenhuma role encontrada."),
                )
              else
                DropdownButtonFormField<String>(
                  value: _tempRoleId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text("Selecione um tipo"),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Todos"),
                    ),
                    ...widget.viewModel.roles.map(
                      (r) => DropdownMenuItem<String>(
                        value: r.id,
                        child: Text(r.name),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _tempRoleId = val;
                    });
                  },
                ),

              const SizedBox(height: 30),

              // Botão Aplicar
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
      },
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
    ProfileSortOption value,
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
    UserStatusFilter value,
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
}
