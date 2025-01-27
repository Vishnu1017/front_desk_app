import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'visitor.dart';
import 'visitor_manager.dart';
import 'visitor_detail_screen.dart';

class VisitorHistoryScreen extends StatefulWidget {
  const VisitorHistoryScreen({super.key});

  @override
  State<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  String _filter = 'Today'; // Default filter
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitor History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 4.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildFilterDropdown(),
            Expanded(child: _buildVisitorList(context)),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.green[800]!, width: 2.0),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filter,
                  items: ['Today', 'Yesterday', 'Custom Dates']
                      .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _filter = newValue!;
                      if (_filter == 'Custom Dates') {
                        _showDateRangePicker();
                      }
                    });
                  },
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.green[800],
                  ),
                  dropdownColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorList(BuildContext context) {
    return Consumer<VisitorManager>(
      builder: (context, visitorManager, child) {
        final filteredVisitors = _getFilteredVisitors(visitorManager.visitors);
        filteredVisitors.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredVisitors.length,
          itemBuilder: (context, index) {
            return _buildVisitorCard(context, filteredVisitors[index]);
          },
        );
      },
    );
  }

  List<Visitor> _getFilteredVisitors(List<Visitor> visitors) {
    final now = DateTime.now();

    if (_filter == 'Custom Dates' && _startDate != null && _endDate != null) {
      return visitors.where((visitor) {
        return visitor.checkInTime
                .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            visitor.checkInTime
                .isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_filter == 'Yesterday') {
      final yesterday = now.subtract(const Duration(days: 1));
      return visitors.where((visitor) {
        return visitor.checkInTime.year == yesterday.year &&
            visitor.checkInTime.month == yesterday.month &&
            visitor.checkInTime.day == yesterday.day;
      }).toList();
    }

    if (_filter == 'Today') {
      return visitors.where((visitor) {
        return visitor.checkInTime.year == now.year &&
            visitor.checkInTime.month == now.month &&
            visitor.checkInTime.day == now.day;
      }).toList();
    }

    return visitors;
  }

  Widget _buildVisitorCard(BuildContext context, Visitor visitor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      shadowColor: Colors.green[300],
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          visitor.name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.green[800]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisitorDetail('Phone', visitor.phone),
            _buildVisitorDetail('Email', visitor.email ?? 'N/A'), // Fixed
            _buildVisitorDetail('Purpose', visitor.purpose),
            _buildVisitorDetail('Person to Meet', visitor.personToMeet),
            _buildVisitorDetail('Checked In', _formatDate(visitor.checkInTime)),
            if (visitor.checkOutTime != null)
              _buildVisitorDetail(
                  'Checked Out', _formatDate(visitor.checkOutTime!)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitorDetailScreen(visitor: visitor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitorDetail(String title, String detail) {
    return Text(
      '$title: $detail',
      style: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(color: Colors.green[700]),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _downloadData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'Download Data',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter =
        DateFormat('dd-MM-yyyy hh:mm a'); // 12-hour format with AM/PM
    return formatter.format(dateTime);
  }

  Future<void> _showDateRangePicker() async {
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
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

  Future<void> _downloadData() async {
    try {
      final visitorManager =
          Provider.of<VisitorManager>(context, listen: false);
      final filteredVisitors = _getFilteredVisitors(visitorManager.visitors);
      await _exportToCSV(filteredVisitors);
    } catch (e) {
      _showSnackBar('Error exporting data: $e');
    }
  }

  Future<void> _exportToCSV(List<Visitor> visitors) async {
    try {
      final csvRows = [
        [
          'NAME',
          'EMAIL', // Capitalized email
          'PHONE',
          'PURPOSE',
          'PERSON TO MEET',
          'CHECK-IN TIME',
          'CHECK-OUT TIME',
          ''
        ],
        ...visitors.map((visitor) {
          return [
            visitor.name,
            visitor.email ?? 'N/A', // Fixed to include email
            visitor.phone,
            visitor.purpose,
            visitor.personToMeet,
            _formatDate(visitor.checkInTime),
            visitor.checkOutTime != null
                ? _formatDate(visitor.checkOutTime!)
                : '',
          ];
        }),
      ];

      final csvData = const ListToCsvConverter().convert(csvRows);
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final filePath =
            '$selectedDirectory/visitor_history_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File(filePath);
        await file.writeAsString(csvData);
        _showSnackBar('CSV file saved successfully');
      }
    } catch (e) {
      _showSnackBar('Error saving CSV file: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
