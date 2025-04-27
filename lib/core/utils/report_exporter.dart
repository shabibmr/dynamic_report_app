import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report_config.dart';
import '../services/loader_service.dart';
import 'date_formatter.dart';
import 'number_formatter.dart';

enum ExportFormat { csv, excel }

class ReportExporter {
  static Future<void> exportAndShare({
    required String reportName,
    required List<String> headers,
    required List<List<dynamic>> rows,
    required ExportFormat format,
    ReportConfig? reportConfig,
  }) async {
    return LoaderService.instance.during(() async {
      final fileName = _sanitizeFileName(
        '${reportName}_${DateFormatter.formatDate(DateTime.now())}',
      );
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/$fileName.${format == ExportFormat.csv ? 'csv' : 'xlsx'}';

      final file = File(filePath);

      switch (format) {
        case ExportFormat.csv:
          await _exportToCsv(file, headers, rows);
          break;
        case ExportFormat.excel:
          await _exportToExcel(file, headers, rows, reportConfig);
          break;
      }

      await Share.shareXFiles([XFile(filePath)], subject: reportName);
    }, 'Preparing ${format == ExportFormat.csv ? 'CSV' : 'Excel'} export...');
  }

  static Future<void> _exportToCsv(
    File file,
    List<String> headers,
    List<List<dynamic>> rows,
  ) async {
    final buffer = StringBuffer();

    // Write headers
    buffer.writeln(headers.map((h) => '"$h"').join(','));

    // Write data rows
    for (final row in rows) {
      buffer.writeln(
        row
            .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
            .join(','),
      );
    }

    await file.writeAsString(buffer.toString());
  }

  static Future<void> _exportToExcel(
    File file,
    List<String> headers,
    List<List<dynamic>> rows,
    ReportConfig? reportConfig,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    // Write headers with styling
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = headers[i];
      cell.cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString('#E0E0E0'),
      );
    }

    // Write data rows
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      for (var colIndex = 0; colIndex < row.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: colIndex,
            rowIndex: rowIndex + 1,
          ),
        );
        cell.value = row[colIndex];

        // Apply number formatting for numeric columns if specified in report config
        if (reportConfig?.displayOptions != null) {
          final alignList =
              reportConfig!.displayOptions!['align-list'] as List?;
          if (alignList != null && colIndex < alignList.length) {
            cell.cellStyle = CellStyle(
              horizontalAlign: alignList[colIndex] == 0
                  ? HorizontalAlign.Left
                  : HorizontalAlign.Right,
            );
          }
        }
      }
    }

    // Auto-size columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColWidth(i, 15.0);
    }

    final excelBytes = excel.encode();
    if (excelBytes != null) {
      await file.writeAsBytes(excelBytes);
    }
  }

  static String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
