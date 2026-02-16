import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelRepository {
  Future<Excel> loadExcelFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (pickedFile == null) throw Exception('No file selected');

    final bytes = pickedFile.files.first.bytes;
    if (bytes != null) {
      return Excel.decodeBytes(bytes);
    }

    final path = pickedFile.files.first.path;
    if (path == null) throw Exception('Cannot read file');

    final file = File(path);
    final byteCode = await file.readAsBytes();
    return Excel.decodeBytes(byteCode);
  }

  Future<String?> saveExcelFile(Excel excel) async {
    final encodedBytes = excel.encode();
    if (encodedBytes == null) throw Exception('Failed to encode Excel file');

    String? outputPath;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Modified Excel File',
        fileName: 'modified_excel.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
    } else {
      final dir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose save location',
      );
      if (dir != null) {
        outputPath = '$dir/modified_excel.xlsx';
      }
    }

    if (outputPath == null) return null;

    if (!outputPath.endsWith('.xlsx')) {
      outputPath = '$outputPath.xlsx';
    }

    final file = File(outputPath);
    await file.writeAsBytes(encodedBytes);
    return outputPath;
  }
}
