import 'package:flutter/material.dart';
import 'app_text_field.dart';

/// Configuração de campo para o dialog
class DialogFieldConfig {
  final String label;
  final String hint;
  final String? initialValue;
  final int? maxLines;

  const DialogFieldConfig({
    required this.label,
    this.hint = '',
    this.initialValue,
    this.maxLines = 1,
  });
}

/// Dialog que apresenta múltiplos campos de texto para preenchimento.
///
/// Gerencia os TextEditingControllers internamente (StatefulWidget),
/// garantindo que sejam criados em initState e descartados em dispose,
/// prevenindo o crash _dependents.isEmpty.
class AppMultiFieldDialog extends StatefulWidget {
  final String title;
  final List<DialogFieldConfig> fields;
  final String actionLabel;
  final String cancelLabel;

  const AppMultiFieldDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.actionLabel,
    this.cancelLabel = 'Cancelar',
  });

  /// Exibe o dialog e coleta os valores digitados pelo usuário.
  ///
  /// Retorna uma lista de [String] na ordem dos campos, ou `null` se cancelado.
  static Future<List<String>?> show({
    required BuildContext context,
    required String title,
    required List<DialogFieldConfig> fields,
    required String actionLabel,
    String cancelLabel = 'Cancelar',
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => AppMultiFieldDialog(
        title: title,
        fields: fields,
        actionLabel: actionLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  State<AppMultiFieldDialog> createState() => _AppMultiFieldDialogState();
}

class _AppMultiFieldDialogState extends State<AppMultiFieldDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((f) => TextEditingController(text: f.initialValue))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.fields.length - 1 ? 16 : 0,
            ),
            child: AppTextField(
              controller: _controllers[index],
              label: field.label,
              hint: field.hint,
              autofocus: index == 0,
              maxLines: field.maxLines,
            ),
          );
        }).toList(),
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
            final values = _controllers.map((c) => c.text.trim()).toList();
            // Exige apenas que o primeiro campo (Nome) esteja preenchido
            if (values.isNotEmpty && values[0].isNotEmpty) {
              Navigator.pop(context, values);
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
