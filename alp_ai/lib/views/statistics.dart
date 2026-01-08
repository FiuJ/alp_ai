import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trash_record.dart';
import 'home.dart'; // Untuk akses AppTheme

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Box<TrashRecord> historyBox;
  int touchedIndex = -1; // Untuk animasi saat grafik disentuh

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<TrashRecord>('history');
  }

  // Helper: Menghitung jumlah sampah per kategori
  Map<String, int> _calculateData(Box<TrashRecord> box) {
    Map<String, int> data = {};
    for (var record in box.values) {
      data[record.category] = (data[record.category] ?? 0) + 1;
    }
    return data;
  }

  // Helper: Warna untuk setiap kategori (Bisa disesuaikan)
  Color _getColorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'PLASTIC': return Colors.blue;
      case 'GLASS': return Colors.teal;
      case 'PAPER': return Colors.orange;
      case 'METAL': return Colors.grey;
      case 'ORGANIC': return Colors.green;
      case 'TEXTILES': return Colors.purple;
      default: return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkGreen),
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box<TrashRecord> box, _) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }

          final data = _calculateData(box);
          final totalItems = box.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 1. Kartu Ringkasan Total
                _buildSummaryCard(totalItems),
                
                const SizedBox(height: 32),

                // 2. Judul Grafik
                const Text(
                  "Waste Composition",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. PIE CHART
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildChartSections(data),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Daftar Detail (Legend)
                ...data.entries.map((e) => _buildLegendItem(
                  e.key, 
                  e.value, 
                  totalItems, 
                  _getColorForCategory(e.key)
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  List<PieChartSectionData> _buildChartSections(Map<String, int> data) {
    final List<String> keys = data.keys.toList();
    
    return List.generate(keys.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final category = keys[i];
      final count = data[category]!;
      
      return PieChartSectionData(
        color: _getColorForCategory(category),
        value: count.toDouble(),
        title: '${count}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Scanned Items",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "$total Items",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, int total, Color color) {
    final percentage = (count / total * 100).toStringAsFixed(1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGreen,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            "$count ($percentage%)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Data Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start scanning to see your stats!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}