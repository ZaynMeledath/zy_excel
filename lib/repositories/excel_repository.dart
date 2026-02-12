import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelRepository {
  Future<Excel> loadExcelFile() async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (pickedFile == null) throw Exception('No file selected');

      final file = File(pickedFile.files.first.path!);
      final byteCode = await file.readAsBytes();

      final excel = Excel.decodeBytes(byteCode);
      return excel;
    } catch (_) {
      rethrow;
    }
  }
}
