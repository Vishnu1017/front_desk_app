import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'visitor.dart';

class VisitorDetailScreen extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitor\'s Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700], // Dark green for AppBar
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width:
              MediaQuery.of(context).size.width * 0.96, // 90% of screen width
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 10.0,
            shadowColor: Colors.green[300], // Green shadow
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Name: ${visitor.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green[800], // Dark green text
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone: ${visitor.phone}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    Text(
                      'Email: ${visitor.email}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    Text(
                      'Purpose: ${visitor.purpose}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    Text(
                      'Person to Meet: ${visitor.personToMeet}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    Text(
                      'Checked In: ${_formatDate(visitor.checkInTime)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    if (visitor.checkOutTime != null)
                      Text(
                        'Checked Out: ${_formatDate(visitor.checkOutTime!)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.green[700],
                            ),
                      ),
                    const SizedBox(height: 20),
                    if (visitor.photoPath != null)
                      Image.file(
                        File(visitor.photoPath!),
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 20),
                    if (visitor.idProofPath != null)
                      Image.file(
                        File(visitor.idProofPath!),
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter =
        DateFormat('dd-MM-yyyy hh:mm a'); // 12-hour format with AM/PM
    return formatter.format(dateTime);
  }
}
