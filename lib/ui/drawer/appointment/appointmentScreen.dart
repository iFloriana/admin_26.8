import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/appointment/addNewAppointment/newAppointmentScreen.dart'
    show Newappointmentscreen;
import 'package:flutter_template/ui/drawer/appointment/appointmentController.dart';
import 'package:flutter_template/ui/drawer/appointment/payment_sheet.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';

import '../../../wiget/appbar/commen_appbar.dart';
import '../../../wiget/loading.dart';
import '../drawer_screen.dart';

class Appointmentscreen extends StatelessWidget {
  Appointmentscreen({super.key});
  final AppointmentController getController = Get.put(AppointmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: CustomAppBar(
          title: 'Appointments',
          backgroundColor: primaryColor,
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
                    getController.selectDate(picked);
                  }
                } else if (value == 'range') {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    getController.selectDateRange(picked);
                  }
                } else if (value == 'sort_asc') {
                  getController.setSortOrder('asc');
                } else if (value == 'sort_desc') {
                  getController.setSortOrder('desc');
                } else if (value == 'clear') {
                  getController.clearFilters();
                } else if (value == 'export') {
                  _showExportDialog(context, getController);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'date',
                  child: Text('Filter by Date'),
                ),
                const PopupMenuItem<String>(
                  value: 'range',
                  child: Text('Filter by Date Range'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'sort_asc',
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Sort Oldest First'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'sort_desc',
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Sort Newest First'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_download,
                        size: 16,
                        color: grey,
                      ),
                      SizedBox(width: 8),
                      Text('Export Data'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: DrawerScreen(),
      body: Container(
        
        child: Obx(() {
          if (getController.isLoading.value) {
            return Center(child: CustomLoadingAvatar());
          }
          if (getController.appointments.isEmpty) {
            return Center(
                child: Text('No appointments found',
                    style: TextStyle(color: Colors.black)));
          }
          if (getController.filteredAppointments.isEmpty) {
            return const Center(
                child: Text('No appointments found with the current filters.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  // headingRowColor: MaterialStateProperty.all(secondaryColor),
                  columns: const [
                    DataColumn(
                        label: Text('Date & Time',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Client',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Amount',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Staff Name',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Services',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Membership',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Package',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Payment Status',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Action',
                            style: TextStyle(color: Colors.black))),
                  ],
                  rows: getController.filteredAppointments.map((a) {
                    return DataRow(cells: [
                      DataCell(Text('${a.date} - ${a.time}',
                          style: TextStyle(color: Colors.black))),
                      DataCell(Row(
                        children: [
                          // CircleAvatar(
                          //   backgroundImage: a.clientImage != null &&
                          //           a.clientImage!.isNotEmpty
                          //       ? NetworkImage(a.clientImage!)
                          //       : null,
                          //   child: (a.clientImage == null ||
                          //           a.clientImage!.isEmpty)
                          //       ? Icon(Icons.person, color: Colors.black)
                          //       : null,
                          // ),
                          // SizedBox(width: 8),
                          Flexible(
                              child: Text(a.clientName,
                                  style: TextStyle(color: Colors.black))),
                        ],
                      )),
                      DataCell(Text('₹ ${a.amount}',
                          style: TextStyle(color: Colors.black))),
                      DataCell(Row(
                        children: [
                          // CircleAvatar(
                          //   backgroundImage: a.staffImage != null &&
                          //           a.staffImage!.isNotEmpty
                          //       ? NetworkImage(a.staffImage!)
                          //       : null,
                          //   child: (a.staffImage == null ||
                          //           a.staffImage!.isEmpty)
                          //       ? Icon(Icons.person, color: Colors.black)
                          //       : null,
                          // ),
                          // SizedBox(width: 8),
                          Flexible(
                              child: Text(a.staffName,
                                  style: TextStyle(color: Colors.black))),
                        ],
                      )),
                      DataCell(Text(a.serviceName,
                          style: TextStyle(color: Colors.black))),
                      DataCell(a.membership == '-'
                          ? Text('-', style: TextStyle(color: Colors.black))
                          : Chip(
                              label: Text(
                                'Yes',
                                style: TextStyle(color: white),
                              ),
                              backgroundColor: Colors.grey[700],
                              labelStyle: TextStyle(color: Colors.black))),
                      DataCell(a.package == '-'
                          ? Text('-', style: TextStyle(color: Colors.black))
                          : Chip(
                              label: Text(
                                'Yes',
                                style: TextStyle(color: white),
                              ),
                              backgroundColor: Colors.grey[700],
                              labelStyle: TextStyle(color: Colors.black))),
                      DataCell(
                        GestureDetector(
                            onTap: () {
                              if (a.status.toLowerCase() == 'upcoming' ||
                                  a.status.toLowerCase() == 'check in')
                                _showCancelAppointmentDialog(context, a);
                            },
                            child: Chip(
                              label: Text(
                                a.status.toLowerCase() == 'upcoming'
                                    ? 'Upcoming'
                                    : a.status.toLowerCase() == 'cancelled'
                                        ? 'Cancelled'
                                        : a.status.toLowerCase() == 'check in'
                                            ? 'Check In'
                                            : 'Check-out',
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: a.status.toLowerCase() ==
                                      'upcoming'
                                  ? const Color.fromARGB(255, 166, 94, 179)
                                  : a.status.toLowerCase() == 'cancelled'
                                      ? const Color.fromARGB(255, 243, 88, 77)
                                      : a.status.toLowerCase() == 'check in'
                                          ? Colors.yellow
                                          : Colors.green,
                            )),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: a.paymentStatus != 'Paid'
                              ? () {
                                  final controller = getController;
                                  // Set initial values for the payment summary state
                                  controller.paymentSummaryState.tips.value =
                                      '0';
                                  controller.paymentSummaryState.paymentMethod
                                      .value = 'UPI';
                                  controller.paymentSummaryState.selectedTax
                                          .value =
                                      controller.taxes.isNotEmpty
                                          ? controller.taxes.first
                                          : null;
                                  controller.paymentSummaryState.couponCode
                                      .value = '';
                                  controller.paymentSummaryState.appliedCoupon
                                      .value = null;
                                  controller.paymentSummaryState
                                      .addAdditionalDiscount.value = false;
                                  controller.paymentSummaryState.discountType
                                      .value = 'percentage';
                                  controller.paymentSummaryState.discountValue
                                      .value = '0';
                                  // Calculate initial grand total
                                  controller.calculateGrandTotal(
                                    servicePrice: a.amount.toDouble(),
                                    memberDiscount:
                                        a.branchMembershipDiscount ?? 0.0,
                                    taxValue: controller.taxes.isNotEmpty
                                        ? controller.taxes.first.value *
                                            a.amount /
                                            100
                                        : 0.0,
                                    tip: 0.0,
                                  );
                                  Get.to(() => PaymentSummaryScreen(a: a));
                                }
                              : null,
                          child: Chip(
                            label: Text(a.paymentStatus,
                                style: TextStyle(color: Colors.black)),
                            backgroundColor: a.paymentStatus == 'Paid'
                                ? Colors.green
                                : Colors.yellow,
                          ),
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.receipt,
                                color: a.paymentStatus == 'Paid'
                                    ? primaryColor
                                    : Colors.grey),
                            onPressed: a.paymentStatus == 'Paid'
                                ? () async {
                                    await getController
                                        .openAppointmentPdf(a.appointmentId);
                                  }
                                : null,
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.edit_outlined,
                          //       color: primaryColor),
                          //   onPressed: () {},
                          // ),
                          // Show cancel button only for upcoming or check in appointments
                          // if (a.status.toLowerCase() == 'upcoming' ||
                          //     a.status.toLowerCase() == 'check in')
                          //   IconButton(
                          //     icon: Icon(Icons.cancel_outlined,
                          //         color: Colors.red),
                          //     onPressed: () {
                          //       _showCancelAppointmentDialog(context, a);
                          //     },
                          //   ),
                          IconButton(
                            icon:
                                Icon(Icons.delete_outline, color: primaryColor),
                            onPressed: () {
                              _showDeleteAppointmentDialog(context, a);
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                )),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(
            Icons.add,
            color: white,
          ),
          onPressed: () {
            Get.to(() => Newappointmentscreen());
          }),
    );
  }

  void _showCancelAppointmentDialog(
      BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text(
            'Cancel Appointment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to cancel this appointment?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${appointment.clientName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${appointment.date}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${appointment.time}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Service: ${appointment.serviceName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'No, Keep It',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await getController
                    .cancelAppointment(appointment.appointmentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAppointmentDialog(
      BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text(
            'Delete Appointment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete this appointment?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${appointment.clientName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${appointment.date}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${appointment.time}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Service: ${appointment.serviceName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⚠️ This action cannot be undone!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await getController
                    .deleteAppointment(appointment.appointmentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(
      BuildContext context, AppointmentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text(
            'Export Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your preferred export format:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportOption(
                    context,
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToExcel();
                    },
                  ),
                  _buildExportOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.exportToPdf();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
