import 'package:flutter/services.dart';

/// Formatador de texto para campos de CNPJ.
///
/// Aplica dinamicamente a máscara `00.000.000/0000-00` enquanto o usuário digita.
/// Remove qualquer caractere não numérico antes de processar.
/// Limita a entrada a 18 caracteres (tamanho máximo de um CNPJ formatado).
class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Limita a 18 caracteres (com formatação)
    if (newValue.text.length > 18) {
      return oldValue;
    }

    // Remove caracteres não numéricos
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    // Aplica a máscara de CNPJ
    for (var i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) {
        newText += '.';
      } else if (i == 8) {
        newText += '/';
      } else if (i == 12) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Formatador de texto para campos de CPF.
///
/// Aplica dinamicamente a máscara `000.000.000-00` enquanto o usuário digita.
/// Limita a entrada a 14 caracteres (tamanho máximo de um CPF formatado).
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 14) return oldValue;

    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        newText += '.';
      } else if (i == 9) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Formatador de texto para campos de Telefone/Celular.
///
/// Suporta máscaras dinâmicas para:
/// - Fixo (8 dígitos): `(00) 0000-0000`
/// - Celular (9 dígitos): `(00) 00000-0000`
///
/// Ajusta a formatação automaticamente conforme o comprimento do número digitado.
/// Limita a entrada a 15 caracteres.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Limita a 15 caracteres (com formatação)
    if (newValue.text.length > 15) {
      return oldValue;
    }

    // Remove caracteres não numéricos
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    // Aplica a máscara de telefone
    for (var i = 0; i < text.length; i++) {
      if (i == 0) {
        newText += '(';
      } else if (i == 2) {
        newText += ') ';
      } else if (text.length == 11) {
        // Celular com 9 dígitos: (00) 00000-0000
        if (i == 7) {
          newText += '-';
        }
      } else {
        // Fixo com 8 dígitos: (00) 0000-0000
        if (i == 6) {
          newText += '-';
        }
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
