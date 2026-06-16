/// Utilitário para validação de documentos fiscais brasileiros.
///
/// Implementa as regras oficiais da Receita Federal para validação de formato e dígitos verificadores.
class AppValidators {
  /// Valida a integridade de um CNPJ (Cadastro Nacional de Pessoa Jurídica).
  ///
  /// Verifica:
  /// - Tamanho (14 dígitos numéricos)
  /// - Dígitos repetidos (ex: 11.111.111/1111-11)
  /// - Algoritmo de Dígitos Verificadores (Módulo 11)
  ///
  /// [cnpj] String do documento, com ou sem formatação.
  /// Retorna `true` se válido.
  static bool isValidCNPJ(String cnpj) {
    // Obter somente os números do CNPJ
    var numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numbers.length != 14) return false;

    // Testar se todos os dígitos do CNPJ são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    // Calcular o primeiro dígito verificador
    List<int> digits = numbers
        .split('')
        .map((String d) => int.parse(d))
        .toList();
    var calcDv1 = 0;
    var j = 0;
    for (var i in [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) {
      calcDv1 += digits[j++] * i;
    }
    calcDv1 %= 11;
    var dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    // Testar o primeiro dígito verificador
    if (digits[12] != dv1) return false;

    // Calcular o segundo dígito verificador
    var calcDv2 = 0;
    j = 0;
    for (var i in [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) {
      calcDv2 += digits[j++] * i;
    }
    calcDv2 %= 11;
    var dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    // Testar o segundo dígito verificador
    if (digits[13] != dv2) return false;

    return true;
  }

  /// Valida a integridade de um CPF (Cadastro de Pessoas Físicas).
  ///
  /// Verifica:
  /// - Tamanho (11 dígitos numéricos)
  /// - Dígitos repetidos (ex: 111.111.111-11)
  /// - Algoritmo de Dígitos Verificadores (Módulo 11)
  ///
  /// [cpf] String do documento, com ou sem formatação.
  /// Retorna `true` se válido.
  static bool isValidCPF(String cpf) {
    // Obter somente os números do CPF
    var numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CPF possui 11 dígitos
    if (numbers.length != 11) return false;

    // Testar se todos os dígitos do CPF são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    // Calcular o primeiro dígito verificador
    List<int> digits = numbers
        .split('')
        .map((String d) => int.parse(d))
        .toList();
    var calcDv1 = 0;
    for (var i = 0; i < 9; i++) {
      calcDv1 += digits[i] * (10 - i);
    }
    calcDv1 %= 11;
    var dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    // Testar o primeiro dígito verificador
    if (digits[9] != dv1) return false;

    // Calcular o segundo dígito verificador
    var calcDv2 = 0;
    for (var i = 0; i < 10; i++) {
      calcDv2 += digits[i] * (11 - i);
    }
    calcDv2 %= 11;
    var dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    // Testar o segundo dígito verificador
    if (digits[10] != dv2) return false;

    return true;
  }
}
