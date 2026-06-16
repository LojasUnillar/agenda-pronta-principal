import 'package:agenda/app/app_routes.dart';
import 'package:agenda/core/constants/app_permissions.dart';
import 'package:agenda/core/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';

import '../viewmodel/search_profile_viewmodel.dart';
import '../../../../core/widgets/jump_to_letter_dialog.dart';
import '../widgets/profile_filter_bar.dart';
import '../widgets/user_profile_list_tile.dart';

/// Tela de listagem de usuários com busca e filtros.
class SearchProfilePage extends StatefulWidget {
  const SearchProfilePage({super.key});

  @override
  State<SearchProfilePage> createState() => _SearchProfilePageState();
}

class _SearchProfilePageState extends State<SearchProfilePage> {
  final SearchProfileViewModel viewModel = getIt<SearchProfileViewModel>();

  bool _loaded = false;
  bool _isSearching = false;

  final Map<String, GlobalKey> _sectionKeys = {};

  void _scrollToSection(String letter) {
    final key = _sectionKeys[letter];
    if (key != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void _showJumpToLetterDialog(List<String> availableLetters) {
    showDialog(
      context: context,
      builder: (context) {
        return JumpToLetterDialog(
          availableLetters: availableLetters,
          onLetterSelected: _scrollToSection,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (!_loaded) {
      viewModel.load();
      _loaded = true;
    }
    viewModel.init();
  }

  @override
  void dispose() {
    viewModel.searchController.dispose();
    super.dispose();
  }

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        viewModel.searchController.clear();
      }
      if (viewModel.searchController.text.isEmpty) {
        viewModel.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<SearchProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: colors.surface,
              title: _isSearching
                  ? AppSearchField(
                      controller: viewModel.searchController,
                      hint: 'Buscar usuário...',
                      onChanged: (value) {
                        if (value.isEmpty) {
                          vm.load();
                        }
                      },
                      onClear: () => vm.load(),
                    )
                  : const Text(
                      'Usuários',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: toggleSearch,
                ),
              ],
            ),
            floatingActionButton:
                vm.user!.hasPermission(AppPermissions.accessCadUser)
                ? FloatingActionButton(
                    backgroundColor: colors.onSurface,
                    onPressed: () async {
                      final changed = await Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.userForm);

                      if (changed == true) {
                        await viewModel.load(
                          query: viewModel.searchController.text,
                        );
                      }
                    },
                    child: Icon(Icons.add, color: colors.surface),
                  )
                : null,
            body: _buildBody(vm),
          );
        },
      ),
    );
  }

  Widget _buildBody(SearchProfileViewModel vm) {
    return Column(
      children: [
        ProfileFilterBar(viewModel: vm),
        Expanded(
          child: Builder(
            builder: (context) {
              if (vm.isLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: 8,
                  itemBuilder: (context, index) => const SkeletonListTile(),
                );
              }

              if (vm.error != null) {
                return AppErrorState(
                  message: vm.error!,
                  onRetry: () =>
                      vm.load(query: viewModel.searchController.text),
                );
              }

              final grouped = vm.groupedUsers;

              for (var letter in grouped.keys) {
                if (!_sectionKeys.containsKey(letter)) {
                  _sectionKeys[letter] = GlobalKey();
                }
              }

              return grouped.isEmpty
                  ? const AppEmptyState(
                      message: 'Nenhum usuário encontrado.',
                      icon: Icons.person_off_outlined,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: grouped.entries.map((entry) {
                          final letter = entry.key;
                          final list = entry.value;

                          return Column(
                            key: _sectionKeys[letter],
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header da Letra com Click
                              InkWell(
                                onTap: () => _showJumpToLetterDialog(
                                  grouped.keys.toList(),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        letter,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: List.generate(list.length, (i) {
                                    final u = list[i];
                                    final isLast = i == list.length - 1;
                                    final colors = Theme.of(
                                      context,
                                    ).colorScheme;

                                    return Column(
                                      children: [
                                        UserProfileListTile(
                                          user: u,
                                          initials: vm.initialsFromName(u.name),
                                          onTap: () async {
                                            final changed =
                                                await Navigator.of(
                                                  context,
                                                ).pushNamed(
                                                  AppRoutes.userForm,
                                                  arguments: u,
                                                );
                                            if (changed == true) {
                                              await vm.load(
                                                query: vm.searchController.text,
                                              );
                                            }
                                          },
                                        ),
                                        if (!isLast)
                                          Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16,
                                            color: colors.outlineVariant
                                                .withValues(alpha: 0.5),
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
