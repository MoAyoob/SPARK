import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Standard import for fl_chart
import 'package:fl_chart/fl_chart.dart';

// Data model for usage records
class UsageData {
  final DateTime time;
  final double value;
  final String type; // 'electricity' or 'water' (lowercase)
  final String unit; // e.g., 'kWh', 'm³'

  UsageData({
    required this.time,
    required this.value,
    required this.type,
    required this.unit,
  });
}

// StatefulWidget for the Usage Analysis Screen
class UsageAnalysisScreen extends StatefulWidget {
  const UsageAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<UsageAnalysisScreen> createState() => _UsageAnalysisScreenState();
}

// State class for UsageAnalysisScreen
class _UsageAnalysisScreenState extends State<UsageAnalysisScreen> {
  // *** Use lowercase for consistency with Firestore data ***
  String _selectedTimePeriod = "Daily";
  String _selectedUsageType = "electricity"; // Default to lowercase
  List<UsageData> _usageData = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Loads usage data from Firestore
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _usageData.clear();
    });
    try {
      print("Querying for type: $_selectedUsageType"); // Debug print
      final snapshot = await FirebaseFirestore.instance
          .collection("usage_data")
      // Query uses the current _selectedUsageType (which should be lowercase now)
          .where("type", isEqualTo: _selectedUsageType)
          .orderBy("time")
          .get();

      print("Documents found: ${snapshot.docs.length}"); // Debug print

      final List<UsageData> fetchedData = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null) {
          print("Warning: Firestore document data is null for doc ID: ${doc.id}");
          return null; // Skip this document
        }

        final timestampData = data["time"];
        final DateTime timestamp = (timestampData is Timestamp)
            ? timestampData.toDate()
            : DateTime.now(); // Default time

        final valueData = data["value"];
        final double doubleValue = (valueData != null && valueData is num)
            ? valueData.toDouble()
            : 0.0; // Default value

        final unitData = data["unit"];
        final unit = (unitData is String) ? unitData : ''; // Default unit

        // Get the type from the document, ensure it's lowercase for consistency
        final typeData = data["type"];
        final typeString = (typeData is String) ? typeData.toLowerCase() : '';


        return UsageData(
          time: timestamp,
          value: doubleValue,
          type: typeString, // Use lowercase type from document
          unit: unit,
        );
      }).whereType<UsageData>().toList(); // Filter out nulls

      setState(() {
        _usageData = fetchedData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _errorMessage = "Failed to load usage data: $e";
        _isLoading = false;
      });
    }
  }

  // Calculates total usage
  double _calculateTotalUsage() {
    if (_usageData.isEmpty) return 0.0;
    return _usageData.map((data) => data.value).reduce((a, b) => a + b);
  }

  // Gets the unit (assumes consistency)
  String _getUnit() {
    return _usageData.isNotEmpty ? _usageData.first.unit : '';
  }

  // Builds the main widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: _buildContent(context),
      ),
    );
  }

  // Builds content based on state
  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Error: $_errorMessage", textAlign: TextAlign.center),
      ));
    }
    // Check if data is empty *after* loading and no error
    if (_usageData.isEmpty && !_isLoading) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the type being checked
            Text("No usage data available for '$_selectedUsageType'."),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ));
    }

    // Main content display (only if data is loaded and not empty)
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 16.0),
            _buildDropdowns(context),
            const SizedBox(height: 16.0),
            _buildUsageSummary(context),
            const SizedBox(height: 16.0),
            _buildChart(context),
            const SizedBox(height: 16.0),
            _buildRecommendations(context),
          ],
        ),
      ),
    );
  }

  // Builds title
  Widget _buildTitle(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      child: const Text("Usage Analysis"),
    );
  }

  // Builds dropdowns
  Widget _buildDropdowns(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _selectedUsageType,
          // *** Use lowercase values in the dropdown items ***
          items: ["electricity", "water"].map((type) =>
              DropdownMenuItem<String>(value: type, child: Text(type[0].toUpperCase() + type.substring(1))), // Capitalize for display
          ).toList(),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedUsageType) {
              setState(() => _selectedUsageType = newValue);
              _loadData();
            }
          },
        ),
        DropdownButton<String>(
          value: _selectedTimePeriod,
          items: ["Daily", "Weekly", "Monthly"].map((period) =>
              DropdownMenuItem<String>(value: period, child: Text(period)),
          ).toList(),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedTimePeriod) {
              setState(() => _selectedTimePeriod = newValue);
              // Note: Currently only changes chart labels, not data query range
            }
          },
        ),
      ],
    );
  }

  // Builds usage summary
  Widget _buildUsageSummary(BuildContext context) {
    final totalUsage = _calculateTotalUsage();
    final unit = _getUnit();
    // Capitalize type for display purposes
    final displayType = _selectedUsageType.isNotEmpty
        ? _selectedUsageType[0].toUpperCase() + _selectedUsageType.substring(1)
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(26), // ~10% opacity
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total $displayType Usage:", style: TextStyle( // Use capitalized display type
              fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
          Text("${totalUsage.toStringAsFixed(2)} $unit", style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColorDark)),
        ],
      ),
    );
  }

  // Builds the chart
  Widget _buildChart(BuildContext context) {
    List<FlSpot> chartData = _usageData.map((data) =>
        FlSpot(data.time.millisecondsSinceEpoch.toDouble(), data.value)).toList();
    final unit = _getUnit();

    Duration interval;
    String dateFormatString;
    switch (_selectedTimePeriod) {
      case 'Daily': interval = const Duration(hours: 6); dateFormatString = 'HH:mm'; break;
      case 'Weekly': interval = const Duration(days: 1); dateFormatString = 'E dd'; break;
      case 'Monthly': interval = const Duration(days: 7); dateFormatString = 'MMM dd'; break;
      default: interval = const Duration(hours: 6); dateFormatString = 'HH:mm';
    }

    double minY = 0, maxY = 10; // Defaults
    if (chartData.isNotEmpty) {
      minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1;
      maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1;
      if (minY < 0 && chartData.every((e) => e.y >= 0)) minY = 0;
      if (maxY <= minY) maxY = minY + 10;
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, drawVerticalLine: true, drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.grey, strokeWidth: 0.5),
            getDrawingVerticalLine: (value) => const FlLine(color: Colors.grey, strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 30, interval: interval.inMilliseconds.toDouble(),
                getTitlesWidget: (value, meta) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final intervalMillis = interval.inMilliseconds.toDouble();
                  final tolerance = intervalMillis * 0.01;
                  if ((value % intervalMillis).abs() < tolerance || ((intervalMillis - (value % intervalMillis)).abs() < tolerance)) {
                    return Padding(padding: const EdgeInsets.only(top: 8.0),
                        child: Text(DateFormat(dateFormatString).format(dateTime), style: const TextStyle(fontSize: 10)));
                  }
                  return const SizedBox.shrink();
                })),
            leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
          minX: chartData.isNotEmpty ? chartData.first.x : 0,
          maxX: chartData.isNotEmpty ? chartData.last.x : 0,
          minY: minY, maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              // Use lowercase selected type for color logic
              color: _selectedUsageType == 'electricity' ? Colors.amber.shade700 : Colors.blue.shade700,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              // Removing belowBarData to ensure compilation
              // belowBarData: BelowBarData( ... )
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.shade800,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('MMM dd, HH:mm').format(dateTime);
                  return LineTooltipItem(
                    '$formattedDate\n${spot.y.toStringAsFixed(2)} $unit',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  // Builds recommendations section
  Widget _buildRecommendations(BuildContext context) {
    // Placeholder
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0, fontWeight: FontWeight.bold),
          child: const Text("AI Recommendations"),
        ),
        const SizedBox(height: 8),
        const Text("Based on your usage patterns, we recommend:"),
        const SizedBox(height: 8),
        const Text("- Reduce electricity consumption during peak hours (6 PM - 9 PM)."),
        const Text("- Consider using energy-efficient appliances."),
      ],
    );
  }
}
