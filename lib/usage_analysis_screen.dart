import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';  //  Removed
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsageData {
  final DateTime time;
  final double value;
  final String type; // e.g., "electricity", "water"

  UsageData({required this.time, required this.value, required this.type});
}

class UsageAnalysisScreen extends StatefulWidget {
  const UsageAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<UsageAnalysisScreen> createState() => _UsageAnalysisScreenState();
}

class _UsageAnalysisScreenState extends State<UsageAnalysisScreen> {
  String _selectedTimePeriod = "Daily";
  String _selectedUsageType = "Electricity";
  List<UsageData> _usageData = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });
    try {
      _usageData = await _fetchUsageData(_selectedUsageType, _selectedTimePeriod);
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _errorMessage = "Failed to load usage data. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<UsageData>> _fetchUsageData(String usageType, String timePeriod) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("usage_data") // Replace "usage_data" with your collection name
          .where("type", isEqualTo: usageType)
          .orderBy("timestamp")
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data["timestamp"] as String); // Adjust if timestamp is stored differently
        final value = data["value"] as double;        // Adjust if value field is named differently
        return UsageData(time: DateTime.parse(timestamp), value: value, type: usageType);
      }).toList();
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Return an empty list on error
    }
  }

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

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    } else if (_usageData.isEmpty) {
      return const Center(child: Text("No usage data available."));
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 16.0),
            _buildDropdowns(context),
            const SizedBox(height: 16.0),
            // _buildChart(context),  //  Removed
            const SizedBox(height: 16.0),
            _buildRecommendations(context),
          ],
        ),
      );
    }
  }

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

  Widget _buildDropdowns(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _selectedUsageType,
          items: ["Electricity", "Water"].map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedUsageType = newValue;
                _loadData();
              });
            }
          },
        ),
        DropdownButton<String>(
          value: _selectedTimePeriod,
          items: ["Daily", "Weekly", "Monthly"].map((period) {
            return DropdownMenuItem<String>(
              value: period,
              child: Text(period),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimePeriod = newValue;
                _loadData();
              });
            }
          },
        ),
      ],
    );
  }

  // Widget _buildChart(BuildContext context) {
  //   //  Temporarily removed chart code
  //   return const SizedBox(
  //     height: 200,
  //     child: Center(
  //       child: Text("Chart functionality temporarily disabled"),
  //     ),
  //   );
  // }

  Widget _buildRecommendations(BuildContext context) {
    // Placeholder for AI recommendations
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
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