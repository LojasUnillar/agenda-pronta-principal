import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../../domain/models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_detail_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Tela principal de listagem de Notificações.
/// Exibe as notificações em cartões, permitindo seleção múltipla e marcação de leitura.
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationViewModel viewModel = getIt<NotificationViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<NotificationViewModel>(
        builder: (context, vm, child) {
          final isSelectionMode = vm.isSelectionMode;

          return Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: colors.surface,
              title: Text(
                isSelectionMode
                    ? "${vm.selectedIds.length} selecionada(s)"
                    : "Notificações",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: vm.clearSelection,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
              actions: [
                if (isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.mark_chat_read_outlined),
                    tooltip: "Marcar como lidas",
                    onPressed: vm.markSelectedAsRead,
                  ),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    tooltip: "Selecionar todas",
                    onPressed: vm.selectAll,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Excluir selecionadas",
                    onPressed: vm.selectedIds.isEmpty
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir notificações'),
                                content: Text(
                                  'Excluir ${vm.selectedIds.length} notificação(ões) selecionada(s)?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Excluir',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              vm.deleteSelected();
                            }
                          },
                  ),
                ] else ...[
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'select') {
                        vm.toggleSelectionMode();
                      } else if (value == 'read_all') {
                        vm.markAllAsRead();
                      } else if (value == 'delete_all') {
                        showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir todas'),
                            content: const Text(
                              'Tem certeza que deseja excluir todas as notificações?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ).then((confirm) {
                          if (confirm == true) {
                            vm.selectAll();
                            vm.deleteSelected();
                          }
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'select',
                        child: Text("Selecionar"),
                      ),
                      const PopupMenuItem(
                        value: 'read_all',
                        child: Text("Marcar todas como lidas"),
                      ),
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Text(
                          "Excluir todas",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            body: Builder(
              builder: (context) {
                if (vm.isLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: 8,
                    itemBuilder: (context, index) => const SkeletonListTile(),
                  );
                }

                if (vm.errorMessage != null) {
                  return AppErrorState(
                    message: vm.errorMessage!,
                    onRetry: vm.init,
                  );
                }

                if (vm.notifications.isEmpty) {
                  return const AppEmptyState(
                    message: "Nenhuma notificação nova",
                    icon: Icons.notifications_none,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: vm.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = vm.notifications[index];
                    return NotificationCard(
                      notification: notification,
                      isSelected: vm.selectedIds.contains(notification.id),
                      isSelectionMode: vm.isSelectionMode,
                      onTap: () {
                        if (vm.isSelectionMode) {
                          vm.toggleSelection(notification.id);
                        } else {
                          _showDetails(notification);
                          if (!notification.isRead) {
                            vm.markAsRead(notification.id);
                          }
                        }
                      },
                      onLongPress: () => vm.toggleSelection(notification.id),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) =>
          NotificationDetailDialog(notification: notification),
    );
  }
}
