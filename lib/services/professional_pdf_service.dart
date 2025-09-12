import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/analysis_report_model.dart';

class ProfessionalPdfService {
  static Future<void> exportAnalysisReport({
    required AnalysisReportModel report,
    required Map<String, dynamic> analysisData,
    required Map<String, dynamic> chartData,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Charger des polices similaires à Poppins (sans-serif moderne)
    final font = await _loadPoppinsFont();
    final fontBold = await _loadPoppinsBoldFont();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // En-tête
            _buildHeader(font, fontBold, report),
            pw.SizedBox(height: 30),

            // Résumé exécutif
            _buildExecutiveSummary(font, fontBold, analysisData),
            pw.SizedBox(height: 20),

            // Statistiques générales
            _buildGeneralStats(font, fontBold, analysisData),
            pw.SizedBox(height: 20),

            // Analyse par essence
            _buildEssenceAnalysis(font, fontBold, analysisData),
            pw.SizedBox(height: 20),

            // Analyse par zone
            _buildZoneAnalysis(font, fontBold, analysisData),
            pw.SizedBox(height: 20),

            // Alertes et recommandations
            _buildAlertsAndRecommendations(font, fontBold, analysisData),
            pw.SizedBox(height: 20),

            // Métadonnées du rapport
            _buildReportMetadata(font, fontBold, report),
          ];
        },
      ),
    );

    // Sauvegarder le PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  static pw.Widget _buildHeader(
    pw.Font font,
    pw.Font fontBold,
    AnalysisReportModel report,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green800,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RAPPORT D\'ANALYSE FORESTIÈRE',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            report.title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 18,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Type: ${report.reportTypeDisplayName}',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            'Statut: ${report.statusDisplayName}',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(
    pw.Font font,
    pw.Font fontBold,
    Map<String, dynamic> analysisData,
  ) {
    final summary = analysisData['summary'] as Map<String, dynamic>? ?? {};

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RÉSUMÉ EXÉCUTIF',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Ce rapport présente une analyse complète des données forestières collectées. '
            'Au total, ${summary['totalRecords'] ?? 0} enregistrements ont été analysés, '
            'couvrant ${summary['uniqueEssences'] ?? 0} essences différentes réparties sur '
            '${summary['uniqueZones'] ?? 0} zones distinctes. Le taux d\'alertes s\'élève à '
            '${summary['alertPercentage'] ?? '0.0'}% du total des observations.',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGeneralStats(
    pw.Font font,
    pw.Font fontBold,
    Map<String, dynamic> analysisData,
  ) {
    final summary = analysisData['summary'] as Map<String, dynamic>? ?? {};

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'STATISTIQUES GÉNÉRALES',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            _buildTableRow(
              font,
              fontBold,
              'Total des enregistrements',
              '${summary['totalRecords'] ?? 0}',
            ),
            _buildTableRow(
              font,
              fontBold,
              'Nombre d\'essences',
              '${summary['uniqueEssences'] ?? 0}',
            ),
            _buildTableRow(
              font,
              fontBold,
              'Nombre de zones',
              '${summary['uniqueZones'] ?? 0}',
            ),
            _buildTableRow(
              font,
              fontBold,
              'Total des alertes',
              '${summary['totalAlerts'] ?? 0}',
            ),
            _buildTableRow(
              font,
              fontBold,
              'Taux d\'alertes',
              '${summary['alertPercentage'] ?? '0.0'}%',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildEssenceAnalysis(
    pw.Font font,
    pw.Font fontBold,
    Map<String, dynamic> analysisData,
  ) {
    final essenceAnalysis =
        analysisData['essenceAnalysis'] as Map<String, dynamic>? ?? {};

    if (essenceAnalysis.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ANALYSE PAR ESSENCE',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            // En-tête
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell(fontBold, 'Essence', PdfColors.black),
                _buildTableCell(fontBold, 'Nombre', PdfColors.black),
                _buildTableCell(fontBold, 'Diam. Moy.', PdfColors.black),
                _buildTableCell(fontBold, 'Diam. Min.', PdfColors.black),
                _buildTableCell(fontBold, 'Diam. Max.', PdfColors.black),
              ],
            ),
            // Données
            ...essenceAnalysis.entries.map((entry) {
              final data = entry.value as Map<String, dynamic>;
              return pw.TableRow(
                children: [
                  _buildTableCell(font, entry.key, PdfColors.black),
                  _buildTableCell(font, '${data['count']}', PdfColors.black),
                  _buildTableCell(
                    font,
                    '${(data['avgDiameter'] as double).toStringAsFixed(1)} cm',
                    PdfColors.black,
                  ),
                  _buildTableCell(
                    font,
                    '${(data['minDiameter'] as double).toStringAsFixed(1)} cm',
                    PdfColors.black,
                  ),
                  _buildTableCell(
                    font,
                    '${(data['maxDiameter'] as double).toStringAsFixed(1)} cm',
                    PdfColors.black,
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildZoneAnalysis(
    pw.Font font,
    pw.Font fontBold,
    Map<String, dynamic> analysisData,
  ) {
    final zoneAnalysis =
        analysisData['zoneAnalysis'] as Map<String, dynamic>? ?? {};

    if (zoneAnalysis.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ANALYSE PAR ZONE',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            // En-tête
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell(fontBold, 'Zone', PdfColors.black),
                _buildTableCell(fontBold, 'Nombre', PdfColors.black),
                _buildTableCell(fontBold, 'Essences', PdfColors.black),
                _buildTableCell(fontBold, 'Alertes', PdfColors.black),
              ],
            ),
            // Données
            ...zoneAnalysis.entries.map((entry) {
              final data = entry.value as Map<String, dynamic>;
              return pw.TableRow(
                children: [
                  _buildTableCell(font, entry.key, PdfColors.black),
                  _buildTableCell(font, '${data['count']}', PdfColors.black),
                  _buildTableCell(
                    font,
                    '${(data['essences'] as Set<String>).length}',
                    PdfColors.black,
                  ),
                  _buildTableCell(font, '${data['alerts']}', PdfColors.black),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAlertsAndRecommendations(
    pw.Font font,
    pw.Font fontBold,
    Map<String, dynamic> analysisData,
  ) {
    final alerts = analysisData['alerts'] as Map<String, dynamic>? ?? {};
    final alertLevels = alerts['levels'] as Map<String, int>? ?? {};

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ALERTES ET RECOMMANDATIONS',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.red200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Résumé des alertes:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Total des alertes: ${alerts['total'] ?? 0}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
              if (alertLevels.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  'Répartition par niveau:',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.red800,
                  ),
                ),
                ...alertLevels.entries.map((entry) {
                  return pw.Text(
                    '• ${entry.key}: ${entry.value} alertes',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 11,
                      color: PdfColors.black,
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Recommandations:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '• Effectuer une inspection approfondie des zones avec un taux d\'alertes élevé',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                '• Surveiller les essences présentant des diamètres anormaux',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                '• Planifier des interventions ciblées selon les niveaux d\'alerte',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildReportMetadata(
    pw.Font font,
    pw.Font fontBold,
    AnalysisReportModel report,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MÉTADONNÉES DU RAPPORT',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Créé par: ${report.createdByUserName}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    'Date de création: ${_formatDate(report.createdAt)}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'ID du rapport: ${report.id}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    'Généré le: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildTableRow(
    pw.Font font,
    pw.Font fontBold,
    String label,
    String value,
  ) {
    return pw.TableRow(
      children: [
        _buildTableCell(font, label, PdfColors.black),
        _buildTableCell(fontBold, value, PdfColors.green800),
      ],
    );
  }

  static pw.Widget _buildTableCell(pw.Font font, String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, color: color),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Charger une police similaire à Poppins
  /// Poppins est une police sans-serif moderne, nous utilisons Helvetica comme alternative
  /// Helvetica est une police sans-serif moderne et professionnelle similaire à Poppins
  static Future<pw.Font> _loadPoppinsFont() async {
    return pw.Font.helvetica();
  }

  /// Charger une police bold similaire à Poppins Bold
  /// Helvetica Bold offre un style similaire à Poppins Bold
  static Future<pw.Font> _loadPoppinsBoldFont() async {
    return pw.Font.helveticaBold();
  }
}
