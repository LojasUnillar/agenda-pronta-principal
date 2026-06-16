import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../../../../core/widgets/jump_to_letter_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../viewmodel/contacts_list_viewmodel.dart';
import '../widgets/contact_card.dart';
import '../widgets/contacts_filter_bar.dart';
import '../widgets/expandable_fab_menu.dart';
import '../viewmodel/contact_registration_viewmodel.dart';
import 'registration/basic_info_page.dart';
import 'supplier_details_page.dart';
import '../../../../core/constants/app_permissions.dart';
import '../../../home/presentation/viewmodel/home_viewmodel.dart';

/// Tela de listagem de contatos e fornecedores.
///
/// Exibe a lista de contatos agrupados alfabeticamente.
/// Possui:
/// - Appbar com busca expansível.
/// - FAB Menu expansível para criar novos contatos de diferentes tipos.
/// - Barra de filtros ([ContactsFilterBar]).
/// - Navegação lateral alfabética (Jump To Letter).
class ContactsListPage extends StatefulWidget {
  final String departmentId;
  final String departmentName;

  const ContactsListPage({
    Key? key,
    required this.departmentId,
    required this.departmentName,
  }) : super(key: key);

  @override
  State<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
  final Map<String, GlobalKey> _sectionKeys = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Chama init() aqui para evitar que o route builder seja re-executado
    // ao abrir/fechar o bottom sheet de filtros (ModalRoute.of re-subscribe bug)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ContactsListViewModel>(
        context,
        listen: false,
      );
      viewModel.init(widget.departmentId);
    });
  }

  void toggleSearch(ContactsListViewModel viewModel) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        viewModel.searchController.clear();
        viewModel.onSearchChanged('');
      }
    });
  }

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
      builder: (context) => JumpToLetterDialog(
        availableLetters: availableLetters,
        onLetterSelected: _scrollToSection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final viewModel = Provider.of<ContactsListViewModel>(context);
    final user = getIt<HomeViewModel>().user;

    // Prepara as chaves globais para indexação alfabética (Jump To)
    for (var letter in viewModel.groupedContacts.keys) {
      if (!_sectionKeys.containsKey(letter)) {
        _sectionKeys[letter] = GlobalKey();
      }
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: _isSearching
            ? AppSearchField(
                controller: viewModel.searchController,
                hint: 'Buscar fornecedor...',
                onChanged: viewModel.onSearchChanged,
                onClear: () => viewModel.onSearchChanged(''),
              )
            : Text(
                widget.departmentName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onSurface,
                ),
              ),
        centerTitle: false,
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: colors.onSurface,
            ),
            onPressed: () => toggleSearch(viewModel),
          ),
        ],
      ),
      floatingActionButton:
          (user?.hasPermission(AppPermissions.createContact) ?? false)
          ? ExpandableFabMenu(
              icon: Icon(Icons.add, color: colors.onTertiary),
              backgroundColor: colors.tertiary,
              foregroundColor: colors.onSecondary,
              items: [
                // Transportadoras
                ExpandableFabMenuItem(
                  label: 'Transportadoras',
                  icon: const Icon(Icons.local_shipping),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => ContactRegistrationViewModel(
                            registrationType: 'Transportadora',
                            departmentRepository: getIt(),
                            supplierRepository: getIt(),
                            brandRepository: getIt(),
                            productRepository: getIt(),
                          ),
                          child: const BasicInfoPage(),
                        ),
                      ),
                    );
                  },
                ),
                // Representantes
                ExpandableFabMenuItem(
                  label: 'Representantes',
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => ContactRegistrationViewModel(
                            registrationType: 'Representante',
                            departmentRepository: getIt(),
                            supplierRepository: getIt(),
                            brandRepository: getIt(),
                            productRepository: getIt(),
                          ),
                          child: const BasicInfoPage(),
                        ),
                      ),
                    );
                  },
                ),
                // Distribuidores
                ExpandableFabMenuItem(
                  label: 'Distribuidores',
                  icon: const Icon(Icons.emoji_transportation),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => ContactRegistrationViewModel(
                            registrationType: 'Distribuidora',
                            departmentRepository: getIt(),
                            supplierRepository: getIt(),
                            brandRepository: getIt(),
                            productRepository: getIt(),
                          ),
                          child: const BasicInfoPage(),
                        ),
                      ),
                    );
                  },
                ),
                // Fornecedores
                ExpandableFabMenuItem(
                  label: 'Fornecedores',
                  icon: const Icon(Icons.store),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => ContactRegistrationViewModel(
                            registrationType: 'Fornecedor',
                            departmentRepository: getIt(),
                            supplierRepository: getIt(),
                            brandRepository: getIt(),
                            productRepository: getIt(),
                          ),
                          child: const BasicInfoPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // --- FILTRO E CONTAGEM ---
          ContactsFilterBar(viewModel: viewModel),

          const SizedBox(height: 10),

          // --- LISTA (Skeleton ou Conteúdo) ---
          Expanded(
            child: viewModel.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: 8,
                    itemBuilder: (context, index) => const SkeletonListTile(),
                  )
                : viewModel.groupedContacts.isEmpty
                ? const AppEmptyState(
                    message: "Nenhum contato encontrado.",
                    icon: Icons.person_off_outlined,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      children: viewModel.groupedContacts.entries.map((entry) {
                        final letter = entry.key;
                        final contacts = entry.value;

                        return Column(
                          key: _sectionKeys[letter],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho da Letra (A, B, C...)
                            InkWell(
                              onTap: () => _showJumpToLetterDialog(
                                viewModel.groupedContacts.keys.toList(),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Cards dos fornecedores desta letra
                            ...contacts
                                .map(
                                  (contact) => InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SupplierDetailsPage(
                                                contact: contact,
                                              ),
                                        ),
                                      );
                                    },
                                    child: ContactCard(contact: contact),
                                  ),
                                )
                                .toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
