import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AnalysisCharts extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final String title;

  const AnalysisCharts({
    super.key,
    required this.chartData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppConstants.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Graphique en barres pour les essences
        if (chartData['essenceChart'] != null &&
            (chartData['essenceChart'] as List).isNotEmpty)
          _buildEssenceBarChart(),

        const SizedBox(height: 24),

        // Graphique en secteurs pour les zones
        if (chartData['zoneChart'] != null &&
            (chartData['zoneChart'] as List).isNotEmpty)
          _buildZonePieChart(),

        const SizedBox(height: 24),

        // Graphique linéaire pour l'évolution temporelle
        if (chartData['timelineChart'] != null &&
            (chartData['timelineChart'] as List).isNotEmpty)
          _buildTimelineChart(),
      ],
    );
  }

  Widget _buildEssenceBarChart() {
    final essenceData = chartData['essenceChart'] as List;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par essence',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    essenceData
                        .map((e) => e['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = essenceData[group.x];
                      return BarTooltipItem(
                        '${data['name']}\n${data['count']} arbres\nDiamètre moyen: ${(data['avgDiameter'] as double).toStringAsFixed(1)} cm',
                        GoogleFonts.poppins(
                          color: AppConstants.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() < essenceData.length) {
                          final name =
                              essenceData[value.toInt()]['name'] as String;
                          return Text(
                            name.length > 8
                                ? '${name.substring(0, 8)}...'
                                : name,
                            style: GoogleFonts.poppins(
                              color: AppConstants.textGrey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            color: AppConstants.textGrey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    essenceData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (data['count'] as int).toDouble(),
                            color: AppConstants.primaryGreen,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonePieChart() {
    final zoneData = chartData['zoneChart'] as List;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par zone',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections:
                          zoneData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            final total = zoneData.fold<int>(
                              0,
                              (sum, item) => sum + (item['count'] as int),
                            );
                            final percentage = (data['count'] as int) / total;

                            final colors = [
                              AppConstants.primaryGreen,
                              Colors.blue,
                              Colors.orange,
                              Colors.purple,
                              Colors.red,
                              Colors.teal,
                            ];

                            return PieChartSectionData(
                              color: colors[index % colors.length],
                              value: (data['count'] as int).toDouble(),
                              title:
                                  '${(percentage * 100).toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: GoogleFonts.poppins(
                                color: AppConstants.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        zoneData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final colors = [
                            AppConstants.primaryGreen,
                            Colors.blue,
                            Colors.orange,
                            Colors.purple,
                            Colors.red,
                            Colors.teal,
                          ];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['name'] as String,
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.white,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart() {
    final timelineData = chartData['timelineChart'] as List;

    // Trier les données par date
    timelineData.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution temporelle (30 derniers jours)',
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppConstants.darkGrey, strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: AppConstants.darkGrey, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() < timelineData.length) {
                          final date =
                              timelineData[value.toInt()]['date'] as String;
                          final parts = date.split('-');
                          if (parts.length >= 3) {
                            return Text(
                              '${parts[2]}/${parts[1]}',
                              style: GoogleFonts.poppins(
                                color: AppConstants.textGrey,
                                fontSize: 10,
                              ),
                            );
                          }
                        }
                        return const Text('');
                      },
                      interval: (timelineData.length / 5).ceil().toDouble(),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            color: AppConstants.textGrey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppConstants.darkGrey),
                ),
                minX: 0,
                maxX: (timelineData.length - 1).toDouble(),
                minY: 0,
                maxY:
                    timelineData
                        .map((d) => d['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        timelineData.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            (entry.value['count'] as int).toDouble(),
                          );
                        }).toList(),
                    isCurved: true,
                    color: AppConstants.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppConstants.primaryGreen,
                          strokeWidth: 2,
                          strokeColor: AppConstants.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisSummaryCards extends StatelessWidget {
  final Map<String, dynamic> summary;

  const AnalysisSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total',
            '${summary['totalRecords'] ?? 0}',
            CupertinoIcons.cube_box,
            AppConstants.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Essences',
            '${summary['uniqueEssences'] ?? 0}',
            CupertinoIcons.tree,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Zones',
            '${summary['uniqueZones'] ?? 0}',
            CupertinoIcons.location,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Alertes',
            '${summary['totalAlerts'] ?? 0}',
            CupertinoIcons.exclamationmark_triangle,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppConstants.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppConstants.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
