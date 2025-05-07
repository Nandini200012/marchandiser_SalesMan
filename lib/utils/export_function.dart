import 'package:excel/excel.dart' show Excel, Sheet;
import 'package:marchandise/model/excel_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart'; // Import open_file package
import 'package:flutter/foundation.dart'; // Import for checking platform
import 'package:universal_html/html.dart' as html;

Future<String?> exportToExcel(ExportModel exportModel) async {
  final excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  // Append headers as simple strings (no need for  )
// Add headers
  sheet.appendRow([
    ('Product ID'),
    ('Product Name'),
    ('Quantity'),
    ('Expiry Date'),
    ('Note'),
    ('Reason'),
    ('Request Status'),
    ('UOM'),
    ('Cost'),
    ('Discount Mode'),
    ('Discount %'),
    ('Discount Amount'),
    ('Salesman Action DateTime'),
  ]);

  // Add data rows and print to debug
  for (var item in exportModel.data) {
    print(
        "Exporting: ${item.prdouctId}, ${item.prdouctName}, ${item.quantity}");
    sheet.appendRow([
      (item.prdouctId ?? 'N/A'),
      (item.prdouctName ?? 'N/A'),
      (item.quantity?.toString() ?? '0'),
      (item.expiryDate ?? 'Unknown'),
      (item.note ?? 'No Note'),
      (item.reason ?? 'No Reason'),
      (item.reqStatus ?? 'No Status'),
      (item.uom ?? 'Unit'),
      (item.cost?.toString() ?? '0.00'),
      (item.discMode ?? 'None'),
      (item.discPerc?.toString() ?? '0'),
      (item.discAmount?.toString() ?? '0.00'),
      (item.salesManActionDateTime ?? 'No Action Date'),
    ]);
  }

  // Handle permissions for mobile platforms
  if (!kIsWeb) {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Storage permission denied');
      return null;
    }
  }

  try {
    // Get the directory based on the platform
    Directory? dir;

    if (kIsWeb) {
      // Handle export for web using the html package
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'exported_data.xlsx'
          ..click();
        html.Url.revokeObjectUrl(url);
        print('Excel file downloaded');
        return null; // For web, return null since file is downloaded immediately
      } else {
        print('Failed to encode the Excel file');
        return null;
      }
    } else {
      // For mobile platforms (Android/iOS)
      dir = await getExternalStorageDirectory();
      if (dir == null) {
        print('Unable to access external storage directory');
        return null;
      }
      final outputPath = '${dir.path}/exported_data.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(outputPath);
        await file.writeAsBytes(fileBytes);
        print('Excel file saved at $outputPath');

        // Optionally open the file after saving (on mobile)
        await OpenFile.open(outputPath);
        return outputPath;
      } else {
        print('Failed to encode the Excel file');
        return null;
      }
    }
  } catch (e) {
    print('Error while saving the file: $e');
    return null;
  }
}
