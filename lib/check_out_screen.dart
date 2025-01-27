import 'package:flutter/material.dart';
import 'package:front_desk_app/visitor.dart';
import 'package:provider/provider.dart';
import 'visitor_manager.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  String _filter = 'Today'; // Default filter
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check-Out',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent, // Bright red theme for AppBar
      ),
      body: Consumer<VisitorManager>(
        builder: (context, visitorManager, child) {
          // Filter and sort visitors based on selected filter
          List<Visitor> filteredVisitors =
              _getFilteredVisitors(visitorManager.visitors);

          return Column(
            children: [
              // Customized DropdownButton
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.redAccent, width: 2.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      items: <String>['Today', 'Yesterday', 'Custom Dates']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filter = newValue!;
                          if (_filter == 'Custom Dates') {
                            _selectDateRange();
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.redAccent,
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
              ),
              // ListView to display visitors
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = filteredVisitors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 8.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade100, Colors.red.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            visitor.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors
                                      .red[900], // Dark red color for title
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          subtitle: Text(
                            visitor.purpose,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.red[
                                          700], // Medium red color for subtitle
                                      fontStyle: FontStyle.italic,
                                      fontSize: 18,
                                    ),
                          ),
                          trailing: visitor.checkOutTime == null
                              ? ElevatedButton(
                                  onPressed: () {
                                    visitorManager.checkOut(visitor);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Colors.red, // White text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 10.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'Check-Out',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Checked Out',
                                  style: TextStyle(
                                    color: Colors.red[
                                        800], // Dark red color for 'Checked Out'
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Filter visitors based on the selected filter
  List<Visitor> _getFilteredVisitors(List<Visitor> visitors) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_filter) {
      case 'Yesterday':
        startDate = now.subtract(const Duration(days: 1)).startOfDay();
        endDate = now.subtract(const Duration(days: 1)).endOfDay();
        break;
      case 'Custom Dates':
        if (_startDate == null || _endDate == null) {
          return []; // No custom date range selected
        }
        startDate = _startDate!.startOfDay();
        endDate = _endDate!.endOfDay();
        break;
      case 'Today':
      default:
        startDate = now.startOfDay();
        endDate = now.endOfDay();
        break;
    }

    // Filter visitors based on the start and end dates
    List<Visitor> sortedVisitors = visitors.where((visitor) {
      return visitor.checkInTime
              .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          visitor.checkInTime.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    sortedVisitors.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    return sortedVisitors;
  }

  // Select custom date range
  Future<void> _selectDateRange() async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    }
  }
}

// Extension methods to get start and end of day
extension DateTimeStartEnd on DateTime {
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}
