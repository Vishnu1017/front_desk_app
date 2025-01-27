// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitorAdapter extends TypeAdapter<Visitor> {
  @override
  final int typeId = 0;

  @override
  Visitor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Visitor(
      name: fields[0] as String,
      phone: fields[1] as String,
      purpose: fields[2] as String,
      checkInTime: fields[3] as DateTime,
      checkOutTime: fields[4] as DateTime?,
      personToMeet: fields[5] as String,
      photoPath: fields[6] as String?,
      idProofPath: fields[7] as String?,
      email: fields[8] as String?, // Add email field
    );
  }

  @override
  void write(BinaryWriter writer, Visitor obj) {
    writer
      ..writeByte(9) // Incremented byte count to 9
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.purpose)
      ..writeByte(3)
      ..write(obj.checkInTime)
      ..writeByte(4)
      ..write(obj.checkOutTime)
      ..writeByte(5)
      ..write(obj.personToMeet)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.idProofPath)
      ..writeByte(8) // Write email field
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
