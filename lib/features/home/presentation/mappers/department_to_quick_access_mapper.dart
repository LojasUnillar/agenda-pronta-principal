import '../models/quick_access_item.dart';
import '../../../departments/domain/models/department_model.dart';

/// Mapper de extensão para converter DepartmentModel em QuickAccessItem.
///
/// Facilita a conversão de modelos de domínio (DepartmentModel)
/// em modelos de apresentação (QuickAccessItem) para a UI.
extension DepartmentToQuickAccessMapper on DepartmentModel {
  /// Converte um DepartmentModel em QuickAccessItem.
  ///
  /// Mantém o ID, usa o código para resolução de ícone e
  /// o nome como label de exibição.
  /// Nomes longos são abreviados para melhor visualização no grid.
  QuickAccessItem toQuickAccessItem() {
    return QuickAccessItem(id: id, code: code, label: _abbreviate(name));
  }

  /// Mapa de abreviações para nomes longos de departamentos.
  static const _abbreviations = <String, String>{'Eletrodomésticos': 'Eletro'};

  String _abbreviate(String name) {
    return _abbreviations[name] ?? name;
  }
}
