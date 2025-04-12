import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';
import 'package:fl_chart/fl_chart.dart';

// Filter Enum
enum FilterType { daily, weekly, monthly }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FilterType _selectedFilter = FilterType.daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(text: "Admin Dashboard", icon: IconAssets.dashboard),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _dashboardCard("Pharmacists", "pharmacists")),
                  Expanded(child: _dashboardCard("Medicines", "medicines")),
                  Expanded(child: _dashboardCard("Orders", "orders")),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Selling Medicines",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<FilterType>(
                  value: _selectedFilter,
                  items: FilterType.values.map((filter) {
                    return DropdownMenuItem<FilterType>(
                      value: filter,
                      child: Text(filter.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _topSellingMedicinesChart(),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(String title, String collection) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection(collection).get(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Card(
          color: AppTheme.lightBgColor,
          shadowColor: AppTheme.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: AppSizes.sp(10),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(count.toString(), style: TextStyle(fontSize: AppSizes.sp(16))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topSellingMedicinesChart() {
    DateTime now = DateTime.now();
    late DateTime start, end;

    switch (_selectedFilter) {
      case FilterType.daily:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        break;
      case FilterType.weekly:
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case FilterType.monthly:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        break;
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('bills')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, int> medicineSales = {};

        for (var doc in snapshot.data!.docs) {
          List<dynamic> medicines = doc['medicines'];
          for (var med in medicines) {
            String name = med['medicine'];
            int quantity = med['quantity'];
            medicineSales[name] = (medicineSales[name] ?? 0) + quantity;
          }
        }

        final sortedMedicines = medicineSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedMedicines.isEmpty) {
          return const Text("No sales data found for this period.");
        }

        final topMedicines = sortedMedicines.take(15).toList();
        final maxValue = topMedicines.first.value.toDouble();
        final titles = topMedicines.map((e) => e.key).toList();

        final barData = topMedicines.asMap().entries.map((entry) {
          final index = entry.key;
          final medicine = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: medicine.value.toDouble(),
                color: AppTheme.primaryColor,
                width: 18,
              )
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();

        final double chartWidth = barData.length * 60;

        return SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              // Scrollable Bar Chart
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: BarChart(
                      BarChartData(
                        maxY: maxValue + 5,
                        barGroups: barData,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: EdgeInsets.zero,
                            tooltipMargin: 0,
                            getTooltipColor: (group) => Colors.transparent, // Makes the tooltip background transparent
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.toInt().toString(),
                                const TextStyle(
                                  color: AppTheme.darkBgColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 3,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value % 3 == 0) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // ❌ Hides right side
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                return Text(
                                  '${index + 1}', // ✅ Index starting from 1
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= titles.length) return const SizedBox();

                                return SideTitleWidget(
                                  // axisSide: meta.axisSide,
                                  meta: meta,
                                  space: 4,
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      titles[index],
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
