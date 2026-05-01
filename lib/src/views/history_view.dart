import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:penyu_guard/src/res/custom_color.dart';
import 'package:penyu_guard/src/services/api_key.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse(ApiKey.weeklyUrl));
      if (response.statusCode == 200) {
        setState(() {
          historyData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat history: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.background,
      appBar: AppBar(
        backgroundColor: CustomColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: CustomColors.navy),
        title: const Text(
          'History Mingguan',
          style: TextStyle(color: CustomColors.navy, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: CustomColors.primary))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: CustomColors.danger)))
              : historyData.isEmpty
                  ? const Center(
                      child: Text('Belum ada data history',
                          style: TextStyle(color: CustomColors.grey)))
                  : _buildCharts(),
    );
  }

  Widget _buildCharts() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildChartCard(
            title: 'Grafik Turbidity (NTU)',
            color: CustomColors.primary,
            spots: historyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), (e.value['turbidity'] as num).toDouble());
            }).toList(),
            isPh: false,
          ),
          const SizedBox(height: 24),
          _buildChartCard(
            title: 'Grafik pH Level',
            color: CustomColors.warning,
            spots: historyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), (e.value['ph'] as num).toDouble());
            }).toList(),
            isPh: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Color color,
    required List<FlSpot> spots,
    required bool isPh,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CustomColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: CustomColors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < historyData.length) {
                          DateTime dt = DateTime.parse(historyData[index]['created_at']).toLocal();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(dt),
                              style: const TextStyle(color: CustomColors.grey, fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: (historyData.length / 5).ceilToDouble().clamp(1, 100),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(isPh ? 1 : 0),
                          style: const TextStyle(color: CustomColors.grey, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (historyData.length - 1).toDouble() > 0 ? (historyData.length - 1).toDouble() : 1,
                minY: isPh ? 0 : null,
                maxY: isPh ? 14 : null,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
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
