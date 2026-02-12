import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:zy_excel/repositories/excel_repository.dart';

class ExcelController extends GetxController {
  final Rxn<Excel> excelObs = Rxn<Excel>();
  final RxMap<String, bool> searchColsMapObs = <String, bool>{}.obs;
  final RxMap<String, bool> modifyColsMapObs = <String, bool>{}.obs;
  final RxString selectedSearchColObs = ''.obs;
  final RxString selectedModifyColObs = ''.obs;

  final excelRepo = ExcelRepository();

  //==================== Load Excel ====================//
  Future<void> loadExcel() async {
    try {
      final excel = await excelRepo.loadExcelFile();
      excelObs.value = excel;

      final table = excel.tables.values.first;
      final cols = table.rows.first;

      searchColsMapObs.value = {
        for (var col in cols) getExcelColumnName(col?.columnIndex ?? 0): false,
      };

      modifyColsMapObs.value = Map.from(searchColsMapObs);
    } catch (_) {}
  }

  void selectOrUnselectSearchCol({
    required String colKey,
    required bool isSelected,
  }) {
    try {
      if (isSelected && searchColsMapObs[selectedSearchColObs.value] != null) {
        searchColsMapObs[selectedSearchColObs.value] = false;
      }
      searchColsMapObs[colKey] = isSelected;
      selectedSearchColObs.value = isSelected ? colKey : '';
    } catch (_) {}
  }

  void selectOrUnselectModifyCol({
    required String colKey,
    required bool isSelected,
  }) {
    try {
      if (isSelected && modifyColsMapObs[selectedModifyColObs.value] != null) {
        modifyColsMapObs[selectedModifyColObs.value] = false;
      }
      modifyColsMapObs[colKey] = isSelected;
      selectedModifyColObs.value = isSelected ? colKey : '';
    } catch (_) {}
  }

  String getExcelColumnName(int index) {
    String columnName = '';
    while (index >= 0) {
      int remainder = index % 26;
      columnName = String.fromCharCode(65 + remainder) + columnName;
      index = (index ~/ 26) - 1;
    }
    return columnName;
  }
}
