import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
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
        final data = response.data['report']['records'] as List<dynamic>;
        setState(() {
          _recordsByDate = _groupRecordsByDate(data);
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
    // Check if the day is in the future
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
      case 'missing_punch':
        return Colors.orange;
      case 'missing_punch_out':
        return Colors.yellow;
      case 'on_leave':
        return Colors.blue;
      case 'future':
        return Colors.grey; // Color for future dates
      case 'absent':
      default:
        return Colors.red;
    }
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
                    // Legend
                    Container(
                      padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem('Present', Colors.green),
                            _buildLegendItem(
                                'Missing Punch Out', Colors.yellow),
                            _buildLegendItem('On Leave', Colors.blue),
                            _buildLegendItem('Absent', Colors.red),
                            _buildLegendItem(
                                'Future', Colors.grey), // New legend item
                          ],
                        ),
                      ),
                    ),
                    // Calendar
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: today, // Restrict calendar to today
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          // Only allow selection of non-future dates
                          final selected = DateTime(selectedDay.year,
                              selectedDay.month, selectedDay.day);
                          if (!selected.isAfter(today)) {
                            setState(() {
                              _selectedDay = selectedDay;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          // Only fetch data if the focused day is not in the future
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
                    // Details Panel
                    if (_selectedDay != null)
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Details for ${DateFormat('dd MMM yyyy').format(_selectedDay!)}',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: _buildDetailsContent(_selectedDay!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  // Details content (handles absent vs. present)
  Widget _buildDetailsContent(DateTime selectedDate) {
    final events = _getEventsForDay(selectedDate);
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'No attendance record',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Status: Absent',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
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
      },
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
