import 'package:hive/hive.dart';

part 'visitor.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class Visitor extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String purpose;

  @HiveField(3)
  final DateTime checkInTime;

  @HiveField(4)
  DateTime? checkOutTime;

  @HiveField(5)
  final String personToMeet;

  @HiveField(6)
  final String? photoPath;

  @HiveField(7)
  final String? idProofPath;

  @HiveField(8) // Add the Hive field for email
  final String? email; // Add the email field, make it nullable

  Visitor({
    required this.name,
    required this.phone,
    required this.purpose,
    required this.checkInTime,
    this.checkOutTime,
    required this.personToMeet,
    this.photoPath,
    this.idProofPath,
    this.email, // Add email to the constructor
  });
}
