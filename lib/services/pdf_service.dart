import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static final PdfColor _brandGreen = PdfColor(45 / 255, 223 / 255, 22 / 255);
  static final PdfColor _brandTint12 = PdfColor(235 / 255, 252 / 255, 232 / 255); // approx green @12%
  static final PdfColor _brandTint10 = PdfColor(238 / 255, 253 / 255, 236 / 255); // approx green @10%
  static final PdfColor _textMuted = PdfColors.grey700;

  static Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/logo/box_black.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            k,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(v, style: pw.TextStyle(color: _textMuted)),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> buildChantierReport({
    required String chantier,
    required DateTime date,
    required String essence,
    required int bloc,
    required int ufe,
    required int acc,
    required List<String> materiels,
    required List<Map<String, dynamic>> consommations,
    String? observations,
  }) async {
    final doc = pw.Document();
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final logo = await _loadLogo();

    final header = pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null) pw.Image(logo, width: 36, height: 36),
              if (logo != null) pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Forest',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _brandGreen,
                    ),
                  ),
                  pw.Text(
                    'BoisTech',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Rapport de Chantier',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                df.format(date),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    pw.Widget sectionTitle(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        );

    pw.Widget card(pw.Widget child) => pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 1),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: child,
        );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        header: (_) => header,
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 1),
            ),
          ),
          child: pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}  •  © BoisTech',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ),
        build: (context) => [
          // Résumé chantier
          sectionTitle('Résumé du Chantier'),
          card(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _kv('Chantier', chantier),
                _kv('Essence', essence),
                _kv('Bloc', '$bloc'),
                _kv('UFE', '$ufe'),
                _kv('ACC', '$acc'),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Matériels nécessaires
          sectionTitle('Matériels nécessaires'),
          if (materiels.isEmpty)
            pw.Text(
              'Aucun matériel déclaré',
              style: const pw.TextStyle(color: PdfColors.grey700),
            )
          else
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in materiels)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor(245 / 255, 245 / 255, 245 / 255),
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
                    ),
                    child: pw.Text(
                      m,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          pw.SizedBox(height: 14),

          // Consommations
          sectionTitle('Matériels utilisés / Consommations'),
          if (consommations.isEmpty)
            pw.Text(
              'Aucune consommation renseignée',
              style: const pw.TextStyle(color: PdfColors.grey700),
            )
          else
            pw.TableHelper.fromTextArray(
              headerDecoration: pw.BoxDecoration(
                color: _brandTint12,
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(4),
                ),
              ),
              headerStyle: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Matériel', 'Quantité', 'Unité'],
              data: consommations
                  .map(
                    (e) => [
                      e['name'] ?? '-',
                      '${e['qty'] ?? '-'}',
                      e['unit'] ?? '-',
                    ],
                  )
                  .toList(),
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                verticalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                top: pw.BorderSide(color: PdfColors.grey400, width: 1),
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                left: pw.BorderSide.none,
                right: pw.BorderSide.none,
              ),
              rowDecoration: pw.BoxDecoration(
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(2),
                ),
              ),
            ),

          if (observations != null && observations.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            sectionTitle('Observations'),
            card(
              pw.Text(
                observations,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          ],

          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _brandTint10,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Icon(
                  pw.IconData(0xe537),
                  color: _brandGreen,
                ), // info icon
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    'Généré par BoisTech • Forest',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
