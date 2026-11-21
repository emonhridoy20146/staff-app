import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A one-page PDF of a receipt (FR-M-055): the receipt card exactly as the
/// customer saw it, drawn as an image on an 80 mm wide page (thermal-printer
/// size), height to fit. The card is an image so Bangla text keeps its shape.
Future<Uint8List> receiptPdfBytes({required Uint8List png, required int widthPx, required int heightPx, required String receiptNo}) async {
  const pageWidth = 80 * PdfPageFormat.mm;
  const margin = 4 * PdfPageFormat.mm;
  final imageWidth = pageWidth - 2 * margin;
  final imageHeight = imageWidth * heightPx / widthPx;
  final doc = pw.Document(title: receiptNo, author: 'Howlader Electronics');
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat(pageWidth, imageHeight + 2 * margin, marginAll: margin),
    build: (_) => pw.Image(pw.MemoryImage(png), width: imageWidth, height: imageHeight),
  ));
  return doc.save();
}
