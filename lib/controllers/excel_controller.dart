import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:zy_excel/repositories/excel_repository.dart';

class ExcelController extends GetxController {
  final Rxn<Excel> excelObs = Rxn<Excel>();
  final RxString fileName = ''.obs;

  // Column maps: key = column letter, value = is selected
  final RxMap<String, bool> searchColsMapObs = <String, bool>{}.obs;
  final RxMap<String, bool> modifyColsMapObs = <String, bool>{}.obs;

  // Column headers: key = column letter, value = header name
  final RxMap<String, String> columnHeaders = <String, String>{}.obs;

  final RxString selectedSearchColObs = ''.obs;
  final RxString selectedModifyColObs = ''.obs;

  // Search & modification state
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> selectedItems =
      <Map<String, dynamic>>[].obs;
  final RxMap<int, String> newValues = <int, String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final excelRepo = ExcelRepository();

  //==================== Load Excel ====================//
  Future<void> loadExcel({String? pickedFileName}) async {
    try {
      isLoading.value = true;
      final excel = await excelRepo.loadExcelFile();
      excelObs.value = excel;
      fileName.value = pickedFileName ?? 'Excel File';

      final table = excel.tables.values.first;
      final headerRow = table.rows.first;

      final Map<String, bool> colMap = {};
      final Map<String, String> headers = {};

      for (var col in headerRow) {
        final colLetter = getExcelColumnName(col?.columnIndex ?? 0);
        colMap[colLetter] = false;
        headers[colLetter] = col?.value?.toString() ?? colLetter;
      }

      searchColsMapObs.value = colMap;
      modifyColsMapObs.value = Map.from(colMap);
      columnHeaders.value = headers;

      // Reset selections
      selectedSearchColObs.value = '';
      selectedModifyColObs.value = '';
      searchResults.clear();
      selectedItems.clear();
      newValues.clear();
      searchQuery.value = '';

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  //==================== Column Selection ====================//
  void selectOrUnselectSearchCol({
    required String colKey,
    required bool isSelected,
  }) {
    if (isSelected && searchColsMapObs[selectedSearchColObs.value] != null) {
      searchColsMapObs[selectedSearchColObs.value] = false;
    }
    searchColsMapObs[colKey] = isSelected;
    selectedSearchColObs.value = isSelected ? colKey : '';
  }

  void selectOrUnselectModifyCol({
    required String colKey,
    required bool isSelected,
  }) {
    if (isSelected && modifyColsMapObs[selectedModifyColObs.value] != null) {
      modifyColsMapObs[selectedModifyColObs.value] = false;
    }
    modifyColsMapObs[colKey] = isSelected;
    selectedModifyColObs.value = isSelected ? colKey : '';
  }

  bool get areBothColumnsSelected =>
      selectedSearchColObs.value.isNotEmpty &&
      selectedModifyColObs.value.isNotEmpty;

  //==================== Search ====================//
  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final excel = excelObs.value;
    if (excel == null) return;

    final table = excel.tables.values.first;
    final searchColIndex = getColumnIndex(selectedSearchColObs.value);
    final modifyColIndex = getColumnIndex(selectedModifyColObs.value);

    final List<Map<String, dynamic>> results = [];
    final lowerQuery = query.toLowerCase();

    // Skip header row (index 0)
    for (int i = 1; i < table.rows.length; i++) {
      final row = table.rows[i];
      if (searchColIndex >= row.length) continue;

      final cellValue = row[searchColIndex]?.value?.toString() ?? '';
      if (cellValue.toLowerCase().contains(lowerQuery)) {
        final modifyValue = modifyColIndex < row.length
            ? (row[modifyColIndex]?.value?.toString() ?? '')
            : '';
        results.add({
          'rowIndex': i,
          'searchValue': cellValue,
          'modifyValue': modifyValue,
          'isSelected': _isRowSelected(i),
        });
      }
    }

    searchResults.value = results;
  }

  bool _isRowSelected(int rowIndex) {
    return selectedItems.any((item) => item['rowIndex'] == rowIndex);
  }

  //==================== Selection ====================//
  void toggleSelectItem(Map<String, dynamic> item) {
    final rowIndex = item['rowIndex'] as int;
    final existingIndex = selectedItems.indexWhere(
      (el) => el['rowIndex'] == rowIndex,
    );

    if (existingIndex != -1) {
      selectedItems.removeAt(existingIndex);
      newValues.remove(rowIndex);
    } else {
      selectedItems.add({...item, 'isSelected': true});
      newValues[rowIndex] = item['modifyValue'] ?? '';
    }

    // Refresh search results to update selection state
    _refreshSearchResultSelections();
  }

  void _refreshSearchResultSelections() {
    final updated = searchResults.map((item) {
      return {...item, 'isSelected': _isRowSelected(item['rowIndex'] as int)};
    }).toList();
    searchResults.value = updated;
  }

  //==================== Edit Values ====================//
  void updateNewValue(int rowIndex, String value) {
    newValues[rowIndex] = value;
  }

  //==================== Save ====================//
  Future<String?> saveChanges() async {
    try {
      isSaving.value = true;
      final excel = excelObs.value;
      if (excel == null) throw Exception('No Excel file loaded');

      final sheetName = excel.tables.keys.first;
      final modifyColIndex = getColumnIndex(selectedModifyColObs.value);

      for (final item in selectedItems) {
        final rowIndex = item['rowIndex'] as int;
        final newVal = newValues[rowIndex] ?? '';

        final cellRef = CellIndex.indexByColumnRow(
          columnIndex: modifyColIndex,
          rowIndex: rowIndex,
        );

        excel.updateCell(sheetName, cellRef, TextCellValue(newVal));
      }

      final savedPath = await excelRepo.saveExcelFile(excel);
      isSaving.value = false;
      return savedPath;
    } catch (e) {
      isSaving.value = false;
      rethrow;
    }
  }

  //==================== Helpers ====================//
  String getExcelColumnName(int index) {
    String columnName = '';
    while (index >= 0) {
      int remainder = index % 26;
      columnName = String.fromCharCode(65 + remainder) + columnName;
      index = (index ~/ 26) - 1;
    }
    return columnName;
  }

  int getColumnIndex(String columnName) {
    int index = 0;
    for (int i = 0; i < columnName.length; i++) {
      index = index * 26 + (columnName.codeUnitAt(i) - 64);
    }
    return index - 1;
  }

  String getHeaderName(String colLetter) {
    return columnHeaders[colLetter] ?? colLetter;
  }

  void removeSelectedItem(int rowIndex) {
    selectedItems.removeWhere((item) => item['rowIndex'] == rowIndex);
    newValues.remove(rowIndex);
    _refreshSearchResultSelections();
  }
}
