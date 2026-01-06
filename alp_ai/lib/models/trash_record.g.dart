// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrashRecordAdapter extends TypeAdapter<TrashRecord> {
  @override
  final int typeId = 0;

  @override
  TrashRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrashRecord(
      category: fields[0] as String,
      recommendations: fields[1] as String,
      timestamp: fields[2] as DateTime,
      imagePath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrashRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.recommendations)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrashRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
