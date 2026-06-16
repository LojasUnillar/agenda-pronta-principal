import 'package:flutter/material.dart';
import 'app_text_field.dart';

/// Dialog de ação com campo de texto (ex: criar, editar).
///
/// Componente reutilizável para ações que requerem um único input de texto do usuário.
/// Utiliza [AppTextField] internamente.
class AppActionDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String fieldHint;
  final String actionLabel;
  final String cancelLabel;
  final String? initialValue;
  final bool autofocus;

  const AppActionDialog({
    super.key,
    required this.title,
    required this.fieldLabel,
    this.fieldHint = '',
    required this.actionLabel,
    this.cancelLabel = 'Cancelar',
    this.initialValue,
    this.autofocus = true,
  });

  /// Exibe o dialog e aguarda a entrada do usuário.
  ///
  /// Retorna a [String] digitada se confirmado, ou `null` se cancelado.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    String fieldHint = '',
    required String actionLabel,
    String cancelLabel = 'Cancelar',
    String? initialValue,
    bool autofocus = true,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => AppActionDialog(
        title: title,
        fieldLabel: fieldLabel,
        fieldHint: fieldHint,
        actionLabel: actionLabel,
        cancelLabel: cancelLabel,
        initialValue: initialValue,
        autofocus: autofocus,
      ),
    );
  }

  @override
  State<AppActionDialog> createState() => _AppActionDialogState();
}

class _AppActionDialogState extends State<AppActionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: AppTextField(
        controller: _controller,
        label: widget.fieldLabel,
        hint: widget.fieldHint,
        autofocus: widget.autofocus,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isNotEmpty) {
              Navigator.pop(context, value);
            }
          },
          child: Text(
            widget.actionLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
