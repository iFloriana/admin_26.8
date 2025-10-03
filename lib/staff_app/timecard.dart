import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final String staffId;

  AttendanceCalendarScreen({required this.staffId});

  @override
  _AttendanceCalendarScreenState createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  Map<String, List<Map<String, dynamic>>> _recordsByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _error;
  int _totalDaysPresent = 0;
  int _totalDaysAbsent = 0;
  int _totalDaysOnLeave = 0;
  String _totalHoursWorked = "0.00";
  Map<String, int> _warnings = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAttendanceData(_focusedDay);
  }

  Future<void> _fetchAttendanceData(DateTime date) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _recordsByDate.clear();
    });

    try {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');

      final response = await dioClient.dio.get(
        '${Apis.baseUrl}/attendance/${widget.staffId}/report/timecard',
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200) {
        final report = response.data['report'];
        final data = report['records'] as List<dynamic>;
        setState(() {
          _recordsByDate = _groupRecordsByDate(data);
          _totalDaysPresent = report['total_days_present'] ?? 0;
          _totalDaysAbsent = report['total_days_absent'] ?? 0;
          _totalDaysOnLeave = report['total_days_on_leave'] ?? 0;
          _totalHoursWorked = report['total_hours_worked'] ?? "0.00";
          _warnings = Map<String, int>.from(report['warnings'] ?? {});
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupRecordsByDate(
      List<dynamic> records) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var record in records) {
      final date = record['date'] as String;
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(record as Map<String, dynamic>);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _recordsByDate[dateStr] ?? [];
  }

  String _getDayStatus(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(day.year, day.month, day.day);

    if (selected.isAfter(today)) {
      return 'future';
    }

    final events = _getEventsForDay(day);
    if (events.isEmpty) {
      return 'absent';
    }
    return events.first['status'] as String;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'missing_punch_out':
        return Colors.yellow;
      case 'on_leave':
        return Colors.blue;
      case 'future':
        return Colors.grey;
      case 'absent':
      default:
        return Colors.red;
    }
  }

  Future<void> _showAttendanceRequestBottomSheet(DateTime selectedDate) async {
    TimeOfDay? punchInTime;
    TimeOfDay? punchOutTime;
    final reasonController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Attendance Request'),
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setModalState(() {
                                  punchInTime = time;
                                });
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: Text(
                              punchInTime == null
                                  ? 'Punch In'
                                  : punchInTime!.format(context),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setModalState(() {
                                  punchOutTime = time;
                                });
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(
                              punchOutTime == null
                                  ? 'Punch Out'
                                  : punchOutTime!.format(context),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: (punchInTime != null &&
                                punchOutTime != null &&
                                reasonController.text.isNotEmpty)
                            ? () async {
                                try {
                                  final requestDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );

                                  final response = await dioClient.dio.post(
                                    '${Apis.baseUrl}/attendance/${widget.staffId}/request/full_day_attendance',
                                    data: {
                                      'date': DateFormat('yyyy-MM-dd')
                                          .format(requestDate),
                                      'punch_in_time':
                                          punchInTime!.format(context),
                                      'punch_out_time':
                                          punchOutTime!.format(context),
                                      'reason': reasonController.text,
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Request submitted successfully 🎉'),
                                      ),
                                    );
                                    Get.back();
                                    await _fetchAttendanceData(_focusedDay);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error submitting request: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: const Text(
                          'Submit Request',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLeaveRequestBottomSheet(DateTime selectedDate) async {
    final reasonController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text('Leave Request'),
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: reasonController.text.isNotEmpty
                            ? () async {
                                try {
                                  final requestDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );

                                  final response = await dioClient.dio.post(
                                    '${Apis.baseUrl}/attendance/${widget.staffId}/request/leave',
                                    data: {
                                      'date': DateFormat('yyyy-MM-dd')
                                          .format(requestDate),
                                      'reason': reasonController.text,
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Leave request submitted 🎉'),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    await _fetchAttendanceData(_focusedDay);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error submitting request: $e'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Submit Request',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDetailsBottomSheet(DateTime selectedDate) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Details for ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailsContent(selectedDate),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Attendance Calendar - ${DateFormat('MMMM yyyy').format(_focusedDay)}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _fetchAttendanceData(_focusedDay),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                        onPressed: () => _fetchAttendanceData(_focusedDay),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem('Present', Colors.green),
                            _buildLegendItem(
                                'Missing Punch Out', Colors.yellow),
                            _buildLegendItem('On Leave', Colors.blue),
                            _buildLegendItem('Absent', Colors.red),
                            _buildLegendItem('Future', Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: today,
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          final selected = DateTime(selectedDay.year,
                              selectedDay.month, selectedDay.day);
                          if (!selected.isAfter(today)) {
                            setState(() {
                              _selectedDay = selectedDay;
                            });
                            _showDetailsBottomSheet(selectedDay);
                          }
                        },
                        onPageChanged: (focusedDay) {
                          final focused = DateTime(focusedDay.year,
                              focusedDay.month, focusedDay.day);
                          if (!focused.isAfter(today)) {
                            _focusedDay = focusedDay;
                            _fetchAttendanceData(focusedDay);
                          }
                        },
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final status = _getDayStatus(date);
                            final color = _getStatusColor(status);
                            final isFuture = status == 'future';
                            return Container(
                              margin: EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color.withOpacity(isFuture ? 0.1 : 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: status == 'present'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      color.withOpacity(isFuture ? 0.5 : 1.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    _buildSummary(),
                  ],
                ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildSummaryRow(
                      "✅ Total Days Present", "$_totalDaysPresent"),
                  _buildSummaryRow("❌ Total Days Absent", "$_totalDaysAbsent"),
                  _buildSummaryRow(
                      "📝 Total Days On Leave", "$_totalDaysOnLeave"),
                  _buildSummaryRow(
                      "⏱ Total Hours Worked", "$_totalHoursWorked"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Warnings section
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠️ Warnings",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Late In", "${_warnings['late_in'] ?? 0}"),
                  _buildSummaryRow(
                      "Early Out", "${_warnings['early_out'] ?? 0}"),
                  _buildSummaryRow(
                      "Missing Punch", "${_warnings['missing_punch'] ?? 0}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(DateTime selectedDate) {
    final events = _getEventsForDay(selectedDate);
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () =>
                        _showAttendanceRequestBottomSheet(selectedDate),
                    icon: const Icon(Icons.access_time),
                    label: const Text(
                      'Request Attendance',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _showLeaveRequestBottomSheet(selectedDate),
                    icon: const Icon(Icons.beach_access),
                    label: const Text(
                      'Request Leave',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(event['status']),
              child: Text('${index + 1}'),
            ),
            title: Text('Status: ${event['status'].toUpperCase()}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Punch In: ${event['punch_in']}'),
                Text('Punch Out: ${event['punch_out']}'),
                Text('Working Hours: ${event['working_hours']}'),
                if (event['warnings'] != null &&
                    (event['warnings'] as List).isNotEmpty)
                  Text(
                    'Warnings: ${(event['warnings'] as List).join(', ')}',
                    style: TextStyle(color: Colors.orange),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
