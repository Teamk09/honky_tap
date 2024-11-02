// lib/widgets/typing_test_results.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../models/wpm_point.dart';
import 'stat_card.dart';

class TypingTestResults extends StatelessWidget {
  final List<WPMPoint> wpmPoints;
  final double secondsElapsed;
  final VoidCallback onRetry;
  final VoidCallback onNewTest;
  final LogicalKeyboardKey resetKey;

  const TypingTestResults({
    required this.wpmPoints,
    required this.secondsElapsed,
    required this.onRetry,
    required this.onNewTest,
    required this.resetKey,
    super.key,
  });

  double get averageWPM => wpmPoints.isEmpty
      ? 0
      : wpmPoints.map((p) => p.wpm).reduce((a, b) => a + b) / wpmPoints.length;

  double get peakWPM => wpmPoints.isEmpty
      ? 0
      : wpmPoints.map((p) => p.wpm).reduce((a, b) => a > b ? a : b);

  double get finalAccuracy => wpmPoints.isEmpty
      ? 0
      : wpmPoints.last.accuracy;

  double _calculateNetWPM() {
    if (wpmPoints.isEmpty) return 0;
    double rawWPM = wpmPoints.last.wpm;
    double accuracy = wpmPoints.last.accuracy / 100;
    return rawWPM * accuracy;
  }

  @override
  Widget build(BuildContext context) {
    double finalWPM = wpmPoints.isEmpty ? 0 : wpmPoints.last.wpm;
    double finalAccuracy = wpmPoints.isEmpty ? 0 : wpmPoints.last.accuracy;
    double netWPM = _calculateNetWPM();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == resetKey) {
          onRetry();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Raw WPM: ${finalWPM.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatCard(
                  label: 'Net WPM',
                  value: netWPM.toStringAsFixed(2),
                ),
                const SizedBox(width: 20),
                StatCard(
                  label: 'Accuracy',
                  value: '${finalAccuracy.toStringAsFixed(2)}%',
                ),
                const SizedBox(width: 20),
                StatCard(
                  label: 'Time',
                  value: '${secondsElapsed.toStringAsFixed(2)} seconds',
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: secondsElapsed.toDouble(),
                    minY: 0,
                    maxY: max(peakWPM, 100),
                    lineBarsData: [
                      LineChartBarData(
                        spots: wpmPoints
                            .map((point) => FlSpot(
                                point.milliseconds.toDouble(),
                                point.wpm))
                            .toList(),
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: wpmPoints
                            .map((point) => FlSpot(
                                point.milliseconds.toDouble(),
                                point.accuracy))
                            .toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: onNewTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('New Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}