import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../drawer_screen.dart';
import 'dashboard_controller.dart';
import 'package:flutter_template/ui/drawer/dashboard/upcoming_bookings_screen.dart';
import 'package:flutter_template/network/model/dashboard_model.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final DashboardController controller = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: CustomAppBar(
          title: "Dashboard",
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'date') {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    // Handle single date selection
                    final range = DateTimeRange(
                      start: picked,
                      end: picked,
                    );
                    controller.setDateRange(range);
                  }
                } else if (value == 'range') {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDateRange: controller.selectedDateRange.value,
                  );
                  if (picked != null) {
                    controller.setDateRange(picked);
                  }
                } else if (value == 'branch') {
                  _showBranchSelectionDialog(context);
                } else if (value == 'clear') {
                  controller.selectedBranch.value = null;
                  controller.selectedDateRange.value = null;
                  controller.CalllApis();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'date',
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Filter by Date'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'range',
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Filter by Date Range'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'branch',
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Select Branch'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear_all,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Clear All Filters'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: DrawerScreen(),
      body: RefreshIndicator(
        color: primaryColor,
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 10,
                children: [
                  // _buildBranchDropdown(),
                  // _buildDateRangePicker(context),
                  // _buildFilterStatus(),
                  Obx(() => performce_widget(controller)),
                  Obx(() => lineChart(controller)),
                  Obx(() => upcomming_booking(controller)),
                  Obx(() => combinedChart(controller)),
                  Obx(() => total_revenue(controller)),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
        onRefresh: () async {
          controller.selectedBranch.value = null;
          controller.selectedDateRange.value = null;
          controller.CalllApis();
        },
      ),
    );
  }

  Widget performce_widget(DashboardController controller) {
    final dashboard = controller.dashboardData.value;
    // Use root-level fields from the API response
    final List<Map<String, dynamic>> items = [
      {'label': 'Appointments', 'value': dashboard.appointmentCount ?? 0},
      {
        'label': 'Total Commission',
        'value': dashboard.totalCommission?.toStringAsFixed(2) ?? 0
      },
      {'label': 'New Customers', 'value': dashboard.customerCount ?? 0},
      {
        'label': 'Orders',
        'value': dashboard.orderCount?.toStringAsFixed(2) ?? 0
      },
      {
        'label': 'Products',
        'value': dashboard.productSales?.toStringAsFixed(2) ?? 0
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
            text: 'Performance',
            textStyle:
                CustomTextStyles.textFontSemiBold(size: 15.sp, color: black)),
        SizedBox(height: 8.h),
        SizedBox(
          height: 70.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120.w,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(AppImages.cardbg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextWidget(
                      text: items[index]['value'].toString(),
                      textStyle: CustomTextStyles.textFontBold(
                          size: 22.sp,
                          color: black,
                          textOverflow: TextOverflow.ellipsis),
                    ),
                    CustomTextWidget(
                      text: items[index]['label'],
                      textStyle: CustomTextStyles.textFontMedium(size: 12.sp),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(width: 5.w),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Obx(() => DropdownButtonFormField<Branch>(
          value: controller.selectedBranch.value,
          decoration: const InputDecoration(
              labelText: 'Branch *', border: OutlineInputBorder()),
          items: controller.branchList
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (v) {
            controller.selectedBranch.value = v;
            // Recall APIs to update dashboard and chart data for selected branch
            controller.getDashbordData();
            controller.getChartData();
          },
          validator: (v) => v == null ? 'Required' : null,
        ));
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Obx(() {
      final range = controller.selectedDateRange.value;
      String label;
      if (range != null) {
        label =
            '${DateFormat('yyyy-MM-dd').format(range.start)} - ${DateFormat('yyyy-MM-dd').format(range.end)}';
      } else {
        label = 'Select Date Range';
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: OutlinedButton.icon(
          icon: Icon(Icons.date_range),
          label: Text(label),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              initialDateRange: range,
            );
            if (picked != null) {
              controller.setDateRange(picked);
            }
          },
        ),
      );
    });
  }

  // Add a method to show current filter status
  Widget _buildFilterStatus() {
    return Obx(() {
      final hasBranchFilter = controller.selectedBranch.value != null;
      final hasDateFilter = controller.selectedDateRange.value != null;

      if (!hasBranchFilter && !hasDateFilter) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(8.h),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, color: primaryColor, size: 16),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasBranchFilter)
                    Text(
                      'Branch: ${controller.selectedBranch.value?.name ?? ''}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  if (hasDateFilter)
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(controller.selectedDateRange.value!.start)} - ${DateFormat('yyyy-MM-dd').format(controller.selectedDateRange.value!.end)}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear, color: primaryColor, size: 16),
              onPressed: () {
                controller.selectedBranch.value = null;
                controller.selectedDateRange.value = null;
                controller.CalllApis();
              },
              tooltip: 'Clear Filters',
            ),
          ],
        ),
      );
    });
  }

  // Add branch selection dialog
  void _showBranchSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Branch'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.branchList.length,
                  itemBuilder: (context, index) {
                    final branch = controller.branchList[index];
                    final isSelected =
                        controller.selectedBranch.value?.id == branch.id;

                    return ListTile(
                      title: Text(branch.name ?? ''),
                      trailing: isSelected
                          ? Icon(Icons.check, color: primaryColor)
                          : null,
                      onTap: () {
                        controller.selectedBranch.value = branch;
                        controller.getDashbordData();
                        controller.getChartData();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                )),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget lineChart(DashboardController controller) {
    final List<LineChartDataPoint> revenueData =
        controller.chartData.value.lineChart ?? [];
    final List<String> dateLabels =
        revenueData.map((e) => e.date ?? '').toList();
    final List<FlSpot> spots = List.generate(
      revenueData.length,
      (index) => FlSpot(
        index.toDouble(),
        (revenueData[index].sales ?? 0).toDouble(),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 150.h,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              getDrawingVerticalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.2),
                strokeWidth: 1,
              ),
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < dateLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: CustomTextWidget(
                          text: dateLabels[index],
                          textStyle: CustomTextStyles.textFontMedium(
                              size: 10.sp, color: black),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => primaryColor,
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot spot) {
                    return LineTooltipItem(
                      // Custom text format
                      'Sales: ₹${spot.y.toInt()}',
                      const TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.brown,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.brown,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget upcomming_booking(DashboardController controller) {
    final dashboard = controller.dashboardData.value;
    final items = dashboard.upcomingAppointments ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              text: 'Upcoming Booking',
              textStyle: CustomTextStyles.textFontSemiBold(
                size: 15.sp,
                color: black,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(
                    () => UpcomingBookingsScreen(upcomingAppointments: items));
              },
              child: CustomTextWidget(
                text: 'View All',
                textStyle: CustomTextStyles.textFontRegular(
                  size: 14.sp,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 230.h,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              String formattedDate = '';
              if (item.appointmentDate != null &&
                  item.appointmentDate!.isNotEmpty) {
                try {
                  final dt = DateTime.parse(item.appointmentDate!);
                  formattedDate = DateFormat('yyyy-MM-dd').format(dt);
                } catch (e) {
                  formattedDate = item.appointmentDate!;
                }
              }
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      size: 35.h,
                    ),
                    trailing: GestureDetector(
                        onTap: () => Get.to(() => UpcomingBookingsScreen(
                            upcomingAppointments: items)),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15.h,
                          color: primaryColor,
                        )),
                    title: CustomTextWidget(
                        text: item.customerName ?? '-',
                        textStyle: CustomTextStyles.textFontBold(
                            size: 14.sp,
                            color: black,
                            textOverflow: TextOverflow.ellipsis)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                            text:
                                '$formattedDate | ${item.appointmentTime ?? ''} | ${item.serviceName ?? ''}',
                            textStyle: CustomTextStyles.textFontRegular(
                                size: 12.sp, color: grey)),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 12.h, color: primaryColor),
                            CustomTextWidget(
                                text: '', // You can add time diff logic here
                                textStyle: CustomTextStyles.textFontMedium(
                                    size: 12.sp, color: primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget combinedChart(DashboardController controller) {
    final List<BarChartDataPoint> data =
        controller.chartData.value.barChart ?? [];
    final List<String> dateLabels = data.map((e) => e.date ?? '').toList();
    final List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
      int index = entry.key;
      final sales = (entry.value.sales ?? 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sales,
            color: primaryColor,
            width: 12,
          ),
        ],
      );
    }).toList();
    final List<FlSpot> lineSpots = data
        .asMap()
        .entries
        .where((entry) => (entry.value.appointments ?? 0) != 0)
        .map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value.appointments ?? 0).toDouble(),
      );
    }).toList();
    return Container(
      height: 210.h,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomTextWidget(
              text: 'Revenue & Sales',
              textStyle:
                  CustomTextStyles.textFontSemiBold(size: 15.sp, color: black),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 160.h,
            child: Stack(
              children: [
                BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < dateLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: CustomTextWidget(
                                  text: dateLabels[index],
                                  textStyle: CustomTextStyles.textFontMedium(
                                      size: 10.sp, color: black),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
                LineChart(LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: lineSpots,
                      isCurved: true,
                      color: secondaryColor,
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.brown,
                          );
                        },
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => primaryColor,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          return LineTooltipItem(
                            // Custom text format
                            'Appointments: ${spot.y.toInt()}',
                            const TextStyle(
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < dateLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: CustomTextWidget(
                                text: dateLabels[index],
                                textStyle: CustomTextStyles.textFontMedium(
                                    size: 10.sp, color: Colors.transparent),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget total_revenue(DashboardController controller) {
    final dashboard = controller.dashboardData.value;
    final List<String> headers = ['Service', 'Total Count', 'Total Amount'];
    final List<dynamic> services = dashboard.topServices ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
            text: 'Toal Revenue',
            textStyle:
                CustomTextStyles.textFontSemiBold(size: 15.sp, color: black)),
        SizedBox(height: 8.h),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                color: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: headers.map((header) {
                    return Expanded(
                      flex: 1,
                      child: Center(
                        child: CustomTextWidget(
                          text: header,
                          textStyle: CustomTextStyles.textFontRegular(
                            size: 13.sp,
                          ).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 5),

              // Data Rows
              ...services.map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomTextWidget(
                          textAlign: TextAlign.center,
                          text: service.serviceName ?? '-',
                          textStyle:
                              CustomTextStyles.textFontRegular(size: 12.sp),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: CustomTextWidget(
                            textAlign: TextAlign.center,
                            text: (service.count ?? service.totalCount ?? '-')
                                .toString(),
                            textStyle:
                                CustomTextStyles.textFontRegular(size: 12.sp),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CustomTextWidget(
                          textAlign: TextAlign.center,
                          text: (service.totalAmount ?? '-').toString(),
                          textStyle:
                              CustomTextStyles.textFontRegular(size: 12.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
