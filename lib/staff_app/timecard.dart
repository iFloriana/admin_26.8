import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/network/network_const.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  @override
  _AttendanceCalendarScreenState createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  // final Dio _dio = Dio();
  Map<String, List<Map<String, dynamic>>> _recordsByDate = {};
  DateTime _focusedDay = DateTime(2025, 9, 1);
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await dioClient.dio.get(
        '${Apis.baseUrl}/attendance/6889de7f4dfda6dd03c10143/report/timecard',
        queryParameters: {'year': '2025', 'month': '09'},
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
    final events = _getEventsForDay(day);
    if (events.isEmpty) {
      return 'absent'; // No record = absent
    }
    // Use the status from the first record (you can customize logic for multiple records if needed)
    return events.first['status'] as String;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'missing_punch':
        return Colors.orange;
      case 'on_leave': // If you have leave status in future data
        return Colors.blue;
      case 'absent':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Calendar - September 2025'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAttendanceData, // Refresh button
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
                        onPressed: _fetchAttendanceData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Legend for colors
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem('Present', Colors.green),
                          _buildLegendItem('Missing Punch', Colors.orange),
                          _buildLegendItem('Absent', Colors.red),
                          _buildLegendItem('On Leave', Colors.blue),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime(2025, 9, 1),
                        lastDay: DateTime(2025, 9, 30),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final status = _getDayStatus(date);
                            final color = _getStatusColor(status);
                            return Container(
                              margin: EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color.withOpacity(
                                    0.3), // Semi-transparent for better readability
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: status == 'present'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_selectedDay != null &&
                        _getEventsForDay(_selectedDay!).isNotEmpty)
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Details for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        _getEventsForDay(_selectedDay!).length,
                                    itemBuilder: (context, index) {
                                      final event = _getEventsForDay(
                                          _selectedDay!)[index];
                                      return Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: _getStatusColor(
                                                event['status']),
                                            child: Text('${index + 1}'),
                                          ),
                                          title: Text(
                                              'Status: ${event['status'].toUpperCase()}'),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Punch In: ${event['punch_in']}'),
                                              Text(
                                                  'Punch Out: ${event['punch_out']}'),
                                              Text(
                                                  'Working Hours: ${event['working_hours']}'),
                                              if (event['warnings'] != null &&
                                                  (event['warnings'] as List)
                                                      .isNotEmpty)
                                                Text(
                                                  'Warnings: ${(event['warnings'] as List).join(', ')}',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
